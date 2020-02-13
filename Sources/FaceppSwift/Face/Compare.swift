//
//  Compare.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/4.
// - Wiki: https://console.faceplusplus.com.cn/documents/4887586
//

import Foundation

public struct CompareOption: RequestProtocol {
    /// 第一个人脸标识 face_token，优先使用该参数
    public var faceToken1: String?
    /// 第一张图片的 URL
    public var imageURL1: URL?
    /// 第一张图片，二进制文件，需要用 post multipart/form-data 的方式上传。
    public var imageFile1: URL?
    /// base64 编码的二进制图片数据。如果同时传入了 image_url1、image_file1 和 image_base64_1 参数，本 API 使用顺序为image_file1 优先，image_url1 最低。
    public var imageBase641: String?

    /// 第二个人脸标识 face_token，优先使用该参数
    public var faceToken2: String?
    /// 第二张图片的 URL
    public var imageURL2: URL?
    /// 第二张图片，二进制文件，需要用 post multipart/form-data 的方式上传。
    public var imageFile2: URL?
    /// base64 编码的二进制图片数据。如果同时传入了 image_url2、image_file2 和 image_base64_2 参数，本API 使用顺序为 image_file2优先，image_url2 最低。
    public var imageBase642: String?

    /**
     当传入图片进行人脸检测时，是否指定人脸框位置进行检测。
     
     如果此参数传入值为空，或不传入此参数，则不使用此功能。本 API 会自动检测图片内所有区域的所有人脸。
     
     如果使用正式 API Key 对此参数传入符合格式要求的值，则使用此功能。
     需要传入一个字符串代表人脸框位置，系统会根据此坐标对框内的图像进行人脸检测，以及人脸关键点和人脸属性等后续操作。
     系统返回的人脸矩形框位置会与传入的 face_rectangle 完全一致。对于此人脸框之外的区域，系统不会进行人脸检测，也不会返回任何其他的人脸信息。
     参数规格：四个正整数，用逗号分隔，依次代表人脸框左上角纵坐标（top），左上角横坐标（left），人脸框宽度（width），人脸框高度（height）。例如：70,80,100,100
     
     注：只有在传入 image_url1、image_file1 和 image_base64_1 三个参数中任意一个时，本参数才生效。
     */
    public var faceRectangle1: FaceppRectangle?
    /**
     当传入图片进行人脸检测时，是否指定人脸框位置进行检测。
     
     如果此参数传入值为空，或不传入此参数，则不使用此功能。本 API 会自动检测图片内所有区域的所有人脸。
     
     如果使用正式 API Key 对此参数传入符合格式要求的值，则使用此功能。
     需要传入一个字符串代表人脸框位置，系统会根据此坐标对框内的图像进行人脸检测，以及人脸关键点和人脸属性等后续操作。
     系统返回的人脸矩形框位置会与传入的 face_rectangle 完全一致。对于此人脸框之外的区域，系统不会进行人脸检测，也不会返回任何其他的人脸信息。
     
     参数规格：四个正整数，用逗号分隔，依次代表人脸框左上角纵坐标（top），左上角横坐标（left），人脸框宽度（width），人脸框高度（height）。
     例如：70,80,100,100
     
     注：只有在传入image_url2、image_file2 和image_base64_2 三个参数中任意一个后本参数才生效。
     */
    public var faceRectangle2: FaceppRectangle?

    var requsetURL: URL? {
        return kFaceppV3URL?.appendingPathComponent("compare")
    }

    func paramsCheck() -> Bool {
        return (faceToken1 != nil || imageURL1 != nil || imageBase641 != nil || imageFile1 != nil)
        && (faceToken2 != nil || imageURL2 != nil || imageBase642 != nil || imageFile2 != nil)
    }

    func params(apiKey: String, apiSecret: String) -> (Params, [Params]?) {
        var params: Params = [
            "api_key": apiKey,
            "api_secret": apiSecret
        ]

        var files = [Params]()
        params["face_token1"] = faceToken1
        params["image_url1"] = imageURL1
        params["image_base64_1"] = imageBase641
        if let url = imageFile1,
            let data = try? Data(contentsOf: url) {
            files.append([
                "fieldName": "image_file1",
                "fileType": url.pathExtension,
                "data": data
            ])
        }

        params["face_token2"] = faceToken2
        params["image_url2"] = imageURL2
        params["image_base64_2"] = imageBase642
        if let url = imageFile2,
            let data = try? Data(contentsOf: url) {
            files.append([
                "fieldName": "image_file2",
                "fileType": url.pathExtension,
                "data": data
            ])
        }

        if let rectangle = faceRectangle1 {
            params["face_rectangle1"] = "\(rectangle)"
        }

        if let rectangle = faceRectangle2 {
            params["face_rectangle2"] = "\(rectangle)"
        }
        return (params, files)
    }
}

public struct CompareResponse: ResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public let requestId: String?
    /**
     比对结果置信度，范围 [0,100]，小数点后3位有效数字，数字越大表示两个人脸越可能是同一个人。
     
     注：如果传入图片但图片中未检测到人脸，则无法进行比对，本字段不返回。
     */
    public let confidence: Float?
    /**
     一组用于参考的置信度阈值，包含以下三个字段。每个字段的值为一个 [0,100] 的浮点数，小数点后 3 位有效数字。
     
     1e-3：误识率为千分之一的置信度阈值；
     1e-4：误识率为万分之一的置信度阈值；
     
     1e-5：误识率为十万分之一的置信度阈值；
     如果置信值低于“千分之一”阈值则不建议认为是同一个人；如果置信值超过“十万分之一”阈值，则是同一个人的几率非常高。
     
     请注意：阈值不是静态的，每次比对返回的阈值不保证相同，所以没有持久化保存阈值的必要，更不要将当前调用返回的 confidence 与之前调用返回的阈值比较。
     
     注：如果传入图片但图片中未检测到人脸，则无法进行比对，本字段不返回。
     */
    public let thresholds: FacialThreshHolds?
    /**
     通过 image_url1、image_file1 或 image_base64_1 传入的图片在系统中的标识。
     
     注：如果未传入图片，本字段不返回。
     */
    public let imageId1: String?
    /**
     通过 image_url2、image_file2 或 image_base64_2 传入的图片在系统中的标识。
     
     注：如果未传入图片，本字段不返回。
     */
    public let imageId2: String?
    /**
     通过 image_url1、image_file1 或 image_base64_1 传入的图片中检测出的人脸数组，采用数组中的第一个人脸进行人脸比对。

     注：如果未传入图片，本字段不返回。如果没有检测出人脸则为空数组
     */
    public let faces1: [Face]?
    /**
     通过 image_url2、image_file2 或 image_base64_2 传入的图片中检测出的人脸数组，采用数组中的第一个人脸进行人脸比对。

     注：如果未传入图片，本字段不返回。如果没有检测出人脸则为空数组
     */
    public let faces2: [Face]?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 当请求失败时才会返回此字符串
    public var errorMessage: String?
}
