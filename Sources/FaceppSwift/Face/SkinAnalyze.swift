//
//  SkinAnalyze.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/9.
// - Wiki: https://console.faceplusplus.com.cn/documents/119745378
//

import Foundation

/// 该API可对人脸图片，进行面部皮肤状态检测分析。
@objc(FppSkinAnalyzeOption)
public class SkinAnalyzeOption: FaceppBaseRequest {
    override var requsetURL: URL? {
        return kFaceappV1URL?.appendingPathComponent("skinanalyze")
    }
}

@objc(FppSkinAnalyzeEyelids)
@objcMembers public final class SkinAnalyzeEyelids: NSObject, Codable {
    @objc(FppSkinAnalyzeEyelidType)
    public enum EyelidType: Int, Codable {
        /// 单眼皮
        case singleFoldEyelid = 0
        /// 平行双眼皮
        case parallelDoubleEyelid
        /// 扇形双眼皮
        case fanDoubleEyelid
    }
    public let type: EyelidType
    public let confidence: Double

    private enum CodingKeys: String, CodingKey {
        case type = "value"
        case confidence
    }
}

@objc(FppSkinAnalyzeHasResul)
@objcMembers public final class SkinAnalyzeHasResult: NSObject, Codable {
    public let doseExist: Bool
    public let confidence: Double

    private enum CodingKeys: String, CodingKey {
        case doseExist = "value"
        case confidence
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let value = try container.decode(Int.self, forKey: .doseExist)
        doseExist = value == 1
        confidence = try container.decode(Double.self, forKey: .confidence)
    }
}

extension SkinAnalyzeOption: FppDataRequestProtocol {
    @objc public func request(completionHandler: @escaping (Error?, SkinAnalyzeResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

@objc(FppSkinAnalyzeResponse)
@objcMembers public final class SkinAnalyzeResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /**
     人脸矩形框的位置，包括以下属性。每个属性的值都是整数：
     
     top：矩形框左上角像素点的纵坐标
     left：矩形框左上角像素点的横坐标
     width：矩形框的宽度
     height：矩形框的高度
     */
    public let faceRectangle: FaceppRectangle?
    /**
     表示影响计算结果的干扰因素.
     
     干扰因素可能有:
     
     imporper_headpose：头部角度不当 (判断条件roll,yaw,pitch超过[-45,45])
     
     当有影响因素存在时返回（有影响即返回相应字段）：["improper_headpose"]
     无影响因素的返回：[]
     */
    public let warning: [String]?

    @objc(FppSkinAnalyzeResult)
    @objcMembers public final class Result: NSObject, Codable {
        /// 左眼双眼皮检测结果：
        public let leftEyelids: SkinAnalyzeEyelids?
        /// 右眼双眼皮检测结果：
        public let rightEyelids: SkinAnalyzeEyelids?
        /// 眼袋检测结果
        public let eyePouch: SkinAnalyzeHasResult?
        /// 黑眼圈检测结果
        public let darkCircle: SkinAnalyzeHasResult?
        /// 抬头纹检测结果
        public let foreheadWrinkle: SkinAnalyzeHasResult?
        /// 鱼尾纹检测结果
        public let crowsFeet: SkinAnalyzeHasResult?
        /// 眼部细纹检测结果
        public let eyeFinelines: SkinAnalyzeHasResult?
        /// 眉间纹检测结果
        public let glabellaWrinkle: SkinAnalyzeHasResult?
        /// 法令纹检测结果
        public let nasolabialFold: SkinAnalyzeHasResult?
        /// 肤质检测结果
        public let skinType: SkinAnalyzeSkinType?
        /// 前额毛孔检测结果
        public let poresForehead: SkinAnalyzeHasResult?
        /// 左脸颊毛孔检测结果
        public let poresLeftCheek: SkinAnalyzeHasResult?
        /// 右脸颊毛孔检测结果
        public let poresRightCheek: SkinAnalyzeHasResult?
        /// 下巴毛孔检测结果
        public let poresJaw: SkinAnalyzeHasResult?
        /// 黑头检测结果
        public let blackhead: SkinAnalyzeHasResult?
        /// 痘痘检测结果
        public let acne: SkinAnalyzeHasResult?
        /// 斑点检测结果
        public let skinSpot: SkinAnalyzeHasResult?
    }
    /// 人脸皮肤分析的结果
    public let result: Result?
}

@objc(FppSkinAnalyzeSkinType)
@objcMembers public final class SkinAnalyzeSkinType: NSObject, Codable {

    @objc(FppSkinAnalyzeSkinEnum)
    public enum SkinType: Int, Codable {
        /// 油性皮肤
        case oilySkin = 0
        /// 干性皮肤
        case drySkin
        /// 中性皮肤
        case neutralSkin
        /// 混合性皮肤
        case combinationSkin
    }
    /// 皮肤类型
    public let skinType: SkinType

    public let details: SkinTypeResult

    @objc(FppSkinAnalyzeSkinTypeResult)
    @objcMembers public final class SkinTypeResult: NSObject, Codable {
        public let oilySkin: SkinAnalyzeHasResult
        public let drySkin: SkinAnalyzeHasResult
        public let neutralSkin: SkinAnalyzeHasResult
        public let combinationSkin: SkinAnalyzeHasResult
    }
}

extension SkinAnalyzeSkinType.SkinTypeResult {
    private enum CodingKeys: String, CodingKey {
        case oilySkin = "0"
        case drySkin = "1"
        case neutralSkin = "2"
        case combinationSkin = "3"
    }
}

/// 该API可对人脸图片，进行面部皮肤状态检测分析。
@objc(FppSkinAnalyzeAdvancedOption)
public class SkinAnalyzeAdvancedOption: FaceppBaseRequest {
    override var requsetURL: URL? {
        return kFaceappV1URL?.appendingPathComponent("skinanalyze_advanced")
    }
}

extension SkinAnalyzeAdvancedOption: FppDataRequestProtocol {
    @objc public func request(completionHandler: @escaping (Error?, SkinAnalyzeAdvancedResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

@objc(FppSkinAnalyzeAdvancedResponse)
@objcMembers public final class SkinAnalyzeAdvancedResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 人脸矩形框的位置
    public let faceRectangle: FaceppRectangle?
    /**
     表示影响计算结果的干扰因素.
     
     干扰因素可能有:
     
     imporper_headpose：头部角度不当 (判断条件roll,yaw,pitch超过[-45,45])
     
     当有影响因素存在时返回（有影响即返回相应字段）：["improper_headpose"]
     无影响因素的返回：[]
     */
    public let warning: [String]?

    /// 肤色
    @objc(FppSkinColorType)
    public enum SkinColorType: Int, Codable {
        /// 透白
        case seeThroughWhite = 0
        /// 白皙
        case fairSkinned
        /// 自然
        case natural
        /// 小麦色
        case wheat
        /// 黝黑
        case dark
    }

    @objc(FppSkinColor)
    @objcMembers public final class SkinColor: NSObject, Codable {
        /// 肤色
        public let value: SkinColorType
        /// 置信度
        public let confidence: Float
    }

    @objc(FppSkinAge)
    @objcMembers public final class SkinAge: NSObject, Codable {
        public let value: Int
    }

    @objc(FppBlackHeadDegree)
    public enum BlackHeadDegree: Int, Codable {
        /// 无
        case none = 0
        /// 轻度
        case mild
        /// 中度
        case moderate
        /// 重度
        case serious
    }

    @objc(FppBlackHead)
    @objcMembers public final class BlackHead: NSObject, Codable {
        public let value: BlackHeadDegree
        public let confidence: Double
    }

    @objc(FppSkinAnalysisSpot)
    @objcMembers public final class Spot: NSObject, Codable {
        public let rectangle: [FaceppRectangle]
    }

    @objc(FppSkinAnalysisResult)
    @objcMembers public final class Result: NSObject, Codable {
        /// 肤色
        public let skinColor: SkinColor?
        /// 肤龄
        public let skinAge: SkinAge?
        /// 左眼双眼皮检测结果：
        public let leftEyelids: SkinAnalyzeEyelids?
        /// 右眼双眼皮检测结果：
        public let rightEyelids: SkinAnalyzeEyelids?
        /// 眼袋检测结果
        public let eyePouch: SkinAnalyzeHasResult?
        /// 黑眼圈检测结果
        public let darkCircle: SkinAnalyzeHasResult?
        /// 抬头纹检测结果
        public let foreheadWrinkle: SkinAnalyzeHasResult?
        /// 鱼尾纹检测结果
        public let crowsFeet: SkinAnalyzeHasResult?
        /// 眼部细纹检测结果
        public let eyeFinelines: SkinAnalyzeHasResult?
        /// 眉间纹检测结果
        public let glabellaWrinkle: SkinAnalyzeHasResult?
        /// 法令纹检测结果
        public let nasolabialFold: SkinAnalyzeHasResult?
        /// 肤质检测结果
        public let skinType: SkinAnalyzeSkinType?
        /// 前额毛孔检测结果
        public let poresForehead: SkinAnalyzeHasResult?
        /// 左脸颊毛孔检测结果
        public let poresLeftCheek: SkinAnalyzeHasResult?
        /// 右脸颊毛孔检测结果
        public let poresRightCheek: SkinAnalyzeHasResult?
        /// 下巴毛孔检测结果
        public let poresJaw: SkinAnalyzeHasResult?
        /// 黑头检测结果
        public let blackhead: BlackHead?
        /// 青春痘
        public let acne: Spot?
        /// 痣
        public let mole: Spot?
        /// 斑点
        public let skinSpot: Spot?
    }

    /// 人脸皮肤分析的结果
    public let result: Result?
}
