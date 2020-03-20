//
//  Search.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/7.
// - Wiki: https://console.faceplusplus.com.cn/documents/4888381
//

import Foundation
#if os(Linux)
import FoundationNetworking
#endif

public class SearchOption: FaceppBaseRequest {
    /// 进行搜索的目标人脸的 face_token，优先使用该参数
    public var faceToken: String?
    /// 用来搜索的 FaceSet 的标识
    public var facesetToken: String?
    /// 用户自定义的 FaceSet 标识
    public var outerId: String?
    /// 控制返回比对置信度最高的结果的数量。合法值为一个范围 [1,5] 的整数。默认值为 1
    public var returnResultCount: UInt = 1
    /**
     当传入图片进行人脸检测时，是否指定人脸框位置进行检测。
     
     如果此参数传入值为空，或不传入此参数，则不使用此功能。本 API 会自动检测图片内所有区域的所有人脸。
     
     如果使用正式 API Key 对此参数传入符合格式要求的值，则使用此功能。
     需要传入一个字符串代表人脸框位置，系统会根据此坐标对框内的图像进行人脸检测，以及人脸关键点和人脸属性等后续操作。
     系统返回的人脸矩形框位置会与传入的 face_rectangle 完全一致。对于此人脸框之外的区域，系统不会进行人脸检测，也不会返回任何其他的人脸信息。
     参数规格：四个正整数，用逗号分隔，依次代表人脸框左上角纵坐标（top），左上角横坐标（left），人脸框宽度（width），人脸框高度（height）。例如：70,80,100,100
     
     注：只有在传入 image_url、image_file 和 image_base64 三个参数中任意一个时，本参数才生效。
     */
    public var faceRectangle: FaceppRectangle?

    override func paramsCheck() throws -> Bool {
        guard needCheckParams else {
            return true
        }
        guard returnResultCount >= 1, returnResultCount <= 5 else {
            throw FaceppRequestError.argumentsError(.invalidArguments(desc:
                "returnResultCount输入需要在[1, 5]: \(returnResultCount)"))
        }
        let result = try super.paramsCheck()
        return (faceToken != nil || result) && (facesetToken != nil || outerId != nil)
    }

    override var requsetURL: URL? {
        return kFaceppV3URL?.appendingPathComponent("search")
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, files) = try super.params()
        params["return_result_count"] = returnResultCount
        if let rectangle = faceRectangle {
            params["face_rectangle"] = "\(String(describing: rectangle))"
        }
        params["faceset_token"] = facesetToken
        params["outer_id"] = outerId
        return (params, files)
    }
}

public struct SearchResponse: FaceppResponseProtocol, Hashable {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /**
     传入的图片在系统中的标识。
     
     注：如果未传入图片，本字段不返回。
     */
    public let imageId: String?
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
     传入的图片中检测出的人脸数组，采用数组中的第一个人脸进行人脸搜索。

     注：如果未传入图片，本字段不返回。如果没有检测出人脸则为空数组
     */
    public let faces: [Face]?

    public struct Result: Codable, Hashable {
        /// 从 FaceSet 中搜索出的一个人脸标识 face_token。
        public let faceToken: String
        /// 比对结果置信度，范围 [0,100]，小数点后3位有效数字，数字越大表示两个人脸越可能是同一个人。
        public let confidence: Float
        /// 用户提供的人脸标识，如果未提供则为空。
        public let userId: String
    }
    /**
     搜索结果对象数组

     注：如果传入图片但图片中未检测到人脸，则无法进行人脸搜索，本字段不返回。
     */
    public let results: [Result]?
}

public extension FaceSet {
    @discardableResult
    func search(faceToken: String?,
                imageURL: URL? = nil,
                imageFile: URL? = nil,
                imageBase64: String? = nil,
                returnResultCount: UInt = 1,
                completionHanlder: @escaping (Error?, SearchResponse?) -> Void) -> URLSessionTask? {
        let option = SearchOption()
        option.facesetToken = facesetToken
        option.outerId = outerId
        option.imageURL = imageURL
        option.faceToken = faceToken
        option.imageFile = imageFile
        option.imageBase64 = imageBase64
        option.returnResultCount = returnResultCount
        return FaceSet.search(option: option, completionHanlder: completionHanlder)
    }
    @discardableResult
    static func search(option: SearchOption,
                       completionHanlder: @escaping (Error?, SearchResponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHanlder)
    }
}
