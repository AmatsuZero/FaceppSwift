//
//  ThreeDimensionFace.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/9.
// - Wiki: https://console.faceplusplus.com.cn/documents/124332617
//

import Foundation

public struct ThreeDimensionFaceOption: RequestProtocol {
    public var needCheckParams: Bool = true
    /// 超时时间
    public var timeoutInterval: TimeInterval = 60
    /**
     人脸正脸图片的 URL
     
     注：在下载图片时可能由于网络等原因导致下载图片时间过长，建议使用 image_file 或 image_base64 参数直接上传图片。
     */
    public var imageURL1: URL?
    /// 人脸正脸图片的二进制文件，需要用 post multipart/form-data 的方式上传。
    public var imageFile1: URL?
    /**
     base64 编码的二进制图片数据
     
     如果同时传入了 image_url、image_file 和 image_base64参数，本 API 使用顺序为image_file 优先，image_url最低。
     */
    public var imageBase641: String?
    /// 第二张图片的 URL，建议传入左侧侧脸图片
    public var imageURL2: URL?
    /// 第二张图片，二进制文件，需要用 post multipart/form-data 的方式上传。
    public var imageFile2: URL?
    /**
     base64 编码的二进制图片数据
     
     如果同时传入了 image_url_2、image_file_2和 image_base64_2参数，本API 使用顺序为 image_file_2优先，image_url_2最低。
     */
    public var imageBase642: String?
    /// 第三张图片的 URL，建议传入右侧侧脸图片
    public var imageURL3: URL?
    /// 第三张图片，二进制文件，需要用 post multipart/form-data 的方式上传。
    public var imageFile3: URL?
    /**
     base64 编码的二进制图片数据
     
     如果同时传入了 image_url_3、image_file_3 和 image_base64_3参数，本API 使用顺序为 image_file_3优先，image_url_3 最低。
     */
    public var imageBase643: String?
    /// 是否返回纹理图
    public var needTexture = false
    /// 是否返回mtl文件
    public var needMtl = false

    public init() {}

    func paramsCheck() throws -> Bool {
        guard needCheckParams else {
            return true
        }
        if let url = imageFile1, try !url.fileSizeNotExceed(mb: uploadFileMBSize) {
            throw FaceppRequestError.argumentsError(.fileTooLarge(size: uploadFileMBSize, path: url))
        }

        if let url = imageFile2, try !url.fileSizeNotExceed(mb: uploadFileMBSize) {
            throw FaceppRequestError.argumentsError(.fileTooLarge(size: uploadFileMBSize, path: url))
        }

        if let url = imageFile3, try !url.fileSizeNotExceed(mb: uploadFileMBSize) {
            throw FaceppRequestError.argumentsError(.fileTooLarge(size: uploadFileMBSize, path: url))
        }
        if let str = imageBase641,
            let count = Data(base64Encoded: str)?.count,
            Double(count) / 1024 / 1024 > uploadFileMBSize {
            throw FaceppRequestError.argumentsError(.invalidArguments(desc:
                "imageBase641大小不应超过\(uploadFileMBSize): \(count / 1024 / 1024)MB"))
        }
        if let str = imageBase642,
            let count = Data(base64Encoded: str)?.count,
            Double(count) / 1024 / 1024 > uploadFileMBSize {
            throw FaceppRequestError.argumentsError(.invalidArguments(desc:
                "imageBase642大小不应超过\(uploadFileMBSize): \(count / 1024 / 1024)MB"))
        }
        if let str = imageBase643,
            let count = Data(base64Encoded: str)?.count,
            Double(count) / 1024 / 1024 > uploadFileMBSize {
            throw FaceppRequestError.argumentsError(.invalidArguments(desc:
                "imageBase643大小不应超过\(uploadFileMBSize): \(count / 1024 / 1024)MB"))
        }
        return (imageURL1 != nil || imageFile1 != nil || imageBase641 != nil)
            && (imageURL2 != nil || imageFile2 != nil || imageBase642 != nil)
            && (imageURL3 != nil || imageFile3 != nil || imageBase643 != nil)
    }

    var requsetURL: URL? {
        return kFaceappV1URL?.appendingPathComponent("3dface")
    }

    func params() throws -> (Params, [Params]?) {
        var params = Params()
        params["texture"] = needTexture ? 1 : 0
        params["mtl"] = needMtl ? 1 : 0

        var files = [Params]()
        params["image_url_1"] = imageURL1
        params["image_base64_1"] = imageBase641
        if let url = imageFile1 {
            let data = try Data(contentsOf: url)
            files.append([
                "fieldName": "image_file_1",
                "fileType": url.pathExtension,
                "data": data
            ])
        }

        params["image_url_2"] = imageURL2
        params["image_base64_2"] = imageBase642
        if let url = imageFile2 {
            let data = try Data(contentsOf: url)
            files.append([
                "fieldName": "image_file_2",
                "fileType": url.pathExtension,
                "data": data
            ])
        }

        params["image_url_3"] = imageURL3
        params["image_base64_3"] = imageBase643
        if let url = imageFile3 {
            let data = try Data(contentsOf: url)
            files.append([
                "fieldName": "image_file_3",
                "fileType": url.pathExtension,
                "data": data
            ])
        }

        return (params, files)
    }
}

public struct ThreeDimensionFaceResponse: FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// obj文件，人脸3D模型文件
    public let objFile: String?
    /// 展开的纹理图，jpg格式。base64 编码的二进制图片数据。
    public let textureImg: String?
    /// mtl文件，材质库文件
    public let mtlFile: String?
    /**
     16*n变幻矩阵，n为传入图片的个数
     
     说明：输入图片视角对应的视变换矩阵（不含透视），obj文件对应的模型经过这个矩阵变化后跟图片中的视角一致
     */
    public let transferMatrix: [[Float]]?
}
