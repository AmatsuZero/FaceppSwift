//
//  HumanBodyDetect.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/12.
//  Wiki: https://console.faceplusplus.com.cn/documents/10071565
//

import Foundation

public class HumanBodyDetectOption: FaceppBaseRequest {

    public enum ReturnAttributes: String, Option {
        /// 不检测属性
        case none
        case gender
        case upperBodyCloth = "upper_body_cloth"
        case lower_body_cloth = "lower_body_cloth"
    }

    public var returnAttributes: Set<ReturnAttributes> = [.none]

    override var requsetURL: URL? {
        return kHumanBodyBaseV1URL?.appendingPathComponent("detect")
    }

    override func params(apiKey: String, apiSecret: String) throws -> (Params, [Params]?) {
        var (params, files) = try super.params(apiKey: apiKey, apiSecret: apiSecret)
        params["return_attributes"] = returnAttributes.map { $0.rawValue }.joined(separator: ",")
        return (params, files)
    }
}

extension Set where Element == HumanBodyDetectOption.ReturnAttributes {
    public static var all: Set<HumanBodyDetectOption.ReturnAttributes> {
        return Set(Element.allCases.filter { $0 != .none })
    }
}

public struct HumanBodyDetectResponse: ResponseProtocol {
    public var requestId: String?
    public var errorMessage: String?
    public var timeUsed: Int?

    public struct Gender: Codable {
        /// 性别为男性的置信度
        public let male: Float?
        /// 性别为女性的置信度
        public let female: Float?
    }

    public struct RGBColor: Codable {
        public let r: Float
        public let g: Float
        public let b: Float
    }

    public enum Color: String, Codable {
        case black, white, red, green, blue, yellow
        case magenta, cyan, gray, purple, orange
    }

    public struct UpperBodyCloth: Codable {
        /// 上身衣物颜色，值为下方颜色列表中与上身衣物颜色最接近的颜色值
        public let upperBodyClothColor: Color
        /// 上身衣物颜色 RGB 值
        public let upperBodyClothColorRgb: RGBColor
    }

    public struct LowerBodyCloth: Codable {
        /// 下身衣物颜色，值为下方颜色列表中与下身衣物颜色最接近的颜色值
        public let lowerBodyClothColor: Color
        /// 下身衣物颜色 RGB 值
        public let lowerBodyClothColorRgb: RGBColor
    }

    public struct Attributes: Codable {
        /// 性别分析结果，返回值包含以下字段。每个字段的值都是一个浮点数，范围 [0,100]，小数点后 3 位有效数字。字段值的总和等于 100。
        public let gender: Gender?
        /// 上身分析结果
        public let upperBodyCloth: UpperBodyCloth?
        /// 下身分析结果
        public let lowerBodyCloth: LowerBodyCloth?
    }

    public struct HumanBody: Codable {
        /// 人体检测的置信度，范围 [0,100]，小数点后3位有效数字，数字越大表示检测到的对象为人体的置信度越大
        public let confidence: Float
        /// 人体矩形框的位置
        public let humanbodyRectangle: FaceppRectangle
        /// 人体属性特征，具体包含的信息见下表
        public let attributes: Attributes?
    }
    /**
     被检测出的人体数组，具体包含内容见下文
     
     注：如果没有检测出的人体则为空数组
     */
    public let humanbodies: [HumanBody]?
    /// 被检测的图片在系统中的标识
    public let imageId: String?
}