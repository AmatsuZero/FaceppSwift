//
//  DetectSceneAndObject.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/17.
//  Wiki: https://console.faceplusplus.com.cn/documents/5671708
//

import Foundation

public class ImageppDetectScenceAndObjectOption: FaceppBaseRequest {
    override var requsetURL: URL? {
        return kImageppBetaURL?.appendingPathComponent("detectsceneandobject")
    }
}

public struct ImageppDetectScenceAndObjectResponse: ResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?

    public struct Value: Codable {
        /// 名称
        public let value: String
        /// 置信度，是一个浮点数，范围[0,100]，小数点后3位有效数字
        public let confidence: Float
    }
    /// 识别出的图片场景信息数组
    public let scenes: [Value]?
    /// 检测出的图片物体信息数组
    public let objects: [Value]?
    /// 被检测的图片在系统中的标识
    public let imageId: String?
}
