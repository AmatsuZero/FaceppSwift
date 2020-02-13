//
//  Beautify.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/7.
// - Wiki: https://console.faceplusplus.com.cn/documents/34878217
//

import Foundation

public class BeautifyOption: FaceppBaseRequest {
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

    override var requsetURL: URL? {
       return kFaceappV1URL?.appendingPathComponent("beautify")
    }

    override func paramsCheck() -> Bool {
        guard whitening >= 0 && whitening <= 100 else {
            return false
        }
        guard smoothing >= 0 && smoothing <= 100 else {
            return false
        }
        return imageURL != nil || imageFile != nil || imageBase64 != nil
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
