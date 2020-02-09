//
//  Beautify.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/7.
// - Wiki: https://console.faceplusplus.com.cn/documents/34878217
//

import Foundation

public struct BeautifyOption: RequestProtocol {
    /**
     图片的URL。

     注：在下载图片时可能由于网络等原因导致下载图片时间过长，建议使用image_file参数直接上传图片。
     */
    public var imageURL: URL?
    /**
     一个图片，二进制文件，需要用post multipart/form-data的方式上传。
     */
    public var imageFile: URL?
    /**
     base64编码的二进制图片数据

     如果同时传入了image_url、image_file和image_base64参数，本API使用顺序为image_file优先，image_url最低。
     */
    public var imageBase64: String?
    /**
         
     美白程度，取值范围[0,100]

     0不美白，100代表最高程度

     本参数默认值为 100
     */
    public var whitening = 100
    /**
     磨皮程度，取值范围 [0,100]

     0不磨皮，100代表最高程度

     本参数默认值为 100
     */
    public var smoothing = 100
    
    var requsetURL: URL? {
       return kFaceappV1URL?.appendingPathComponent("beautify")
    }
    
    func paramsCheck() -> Bool {
        guard whitening >= 0 && whitening <= 100 else {
            return false
        }
        guard smoothing >= 0 && smoothing <= 100 else {
            return false
        }
        return imageURL != nil || imageFile != nil || imageBase64 != nil
    }
    
    func params(apiKey: String, apiSecret: String) -> (Params, [Params]?) {
        var params: Params = [
            "api_key": apiKey,
            "api_secret": apiSecret
        ]
        var files = [Params]()
        params["image_base64"] = imageBase64
        params["image_url"] = imageURL
        if let url = imageFile, let data = try? Data(contentsOf: url) {
            files.append([
                "fieldName": "image_file",
                "fileType": url.pathExtension,
                "data": data
            ])
        }
        return (params, nil)
    }
}

public struct BeautifyResponse: ResponseProtocol {
    var requestId: String?
    /// 当发生错误时才返回。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 美化后的图片，jpg格式。base64 编码的二进制图片数据。图片尺寸大小与底图一致。
    public let result: String?
}

