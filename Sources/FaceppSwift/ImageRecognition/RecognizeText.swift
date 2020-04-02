//
//  RecognizeText.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/17.
//  Wiki: https://console.faceplusplus.com.cn/documents/7776484
//

import Foundation

/// 调用者提供图片文件或者图片URL，进行图片分析，找出图片中出现的文字信息。
@objc(FppecognizeTextOption)
public class ImageppRecognizeTextOption: FaceppBaseRequest {
    override var requsetURL: URL? {
        return kImageppV1URL?.appendingPathComponent("recognizetext")
    }
}

extension ImageppRecognizeTextOption: FppDataRequestProtocol {
    @objc public func request(completionHandler: @escaping (Error?, ImagepprecognizeTextResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

@objc(FppRecognizeTextResponse)
@objcMembers public final class ImagepprecognizeTextResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var timeUsed: Int?

    public enum DataType: String, Codable {
        /// 文档
        case document
        /// 段落
        case paragraph
        /// 一行文字
        case textline
        /// 词
        case word
        /// 字符
        case character
    }

    @objc(FppTextRecognizeResult)
    @objcMembers public final class Result: NSObject, Codable {
        /// data对象的类型
        public let type: DataType

        public var typeString: String {
            return type.rawValue
        }

        /// 识别出的文字，以UTF-8格式编码
        public let value: String
        /// 文字在图片中的坐标信息，是一个数组，包含文字的多个坐标点信息
        public let position: [FaceppPoint]

        public let childObjects: [Result]

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(DataType.self, forKey: .type)
            value = try container.decode(String.self, forKey: .value)
            position = try container.decode([FaceppPoint].self, forKey: .position)
            childObjects = try container.decode([Result].self, forKey: .childObjects)
        }
    }
    /**
     被检测出的文字信息，由一个或多个data对象组成。
     注：如果没有检测出文字则为空
     */
    public let result: [Result]?
}

extension ImagepprecognizeTextResponse.Result {
    private enum CodingKeys: String, CodingKey {
        case type, value, position
        case childObjects = "child-objects"
    }
}
