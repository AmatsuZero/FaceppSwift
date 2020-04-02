//
//  Face.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/3/16.
//

import Foundation

@objc(FppFaceSetUserIdOption)
@objcMembers public final class FaceSetUserIdOption: NSObject, RequestProtocol {

    public var timeoutInterval: TimeInterval = 60

    public var needCheckParams: Bool = true

    @nonobjc public var metricsReporter: FaceppMetricsReporter?

    /// 人脸标识face_token
    public var faceToken: String

    /// 用户自定义的user_id，不超过255个字符，不能包括^@,&=*'"建议将同一个人的多个face_token设置同样的user_id。
    public var userId: String

    public init(token: String, id: String) {
        self.faceToken = token
        self.userId = id
        super.init()
    }

    required public init(params: [String: Any]) {
        if let value = params["need_check_params"] as? Bool {
            needCheckParams = value
        } else {
            needCheckParams = true
        }
        if let value = params["timeout_interval"] as? TimeInterval {
            timeoutInterval = value
        } else {
            timeoutInterval = 60
        }
        if let value = params["face_token"] as? String {
            faceToken = value
        } else {
            faceToken = ""
        }
        if let id = params["user_id"] as? String {
            userId = id
        } else {
            userId = ""
        }
        super.init()
    }

    var requsetURL: URL? {
        return kFaceppV3URL?
            .appendingPathComponent("face")
            .appendingPathComponent("setuserid")
    }

    func paramsCheck() throws -> Bool {
        guard needCheckParams else {
            return true
        }
        guard userId.allSatisfy({ !kInvalidUserDataCharacters.contains($0) }) else {
            throw FaceppRequestError.argumentsError(.invalidArguments(desc :"userData不能包括字符^@,&=*'"))
        }
        return true
    }

    func params() throws -> (Params, [Params]?) {
        var params: Params = [
            "face_token": faceToken
        ]
        params["user_id"] = userId
        return (params, nil)
    }
}

@objc(FppFaceSetUserIdResponse)
@objcMembers public final class FaceSetUserIdResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。除非发生404（API_NOT_FOUND ) 或403 （AUTHORIZATION_ERROR）错误，此字段必定返回。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。除非发生404（API_NOT_FOUND )或403 （AUTHORIZATION_ERROR）错误，此字段必定返回。
    public var timeUsed: Int?
    /// 用户自定义的标识信息
    public let userId: String?
    /// 人脸token
    public let faceToken: String?
}

extension FaceSetUserIdOption: FppDataRequestProtocol {
    @objc public func request(completionHandler: @escaping (Error?, FaceSetUserIdResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

@objc(FppFaceGetDetailOption)
@objcMembers public final class FaceGetDetailOption: NSObject, RequestProtocol {
    public var timeoutInterval: TimeInterval = 60

    public var needCheckParams: Bool = false

    @nonobjc public var metricsReporter: FaceppMetricsReporter?

    public var faceToken: String

    public init(token: String) {
        self.faceToken = token
    }

    required public init(params: [String: Any]) {
        if let value = params["need_check_params"] as? Bool {
            needCheckParams = value
        } else {
            needCheckParams = true
        }
        if let value = params["timeout_interval"] as? TimeInterval {
            timeoutInterval = value
        } else {
            timeoutInterval = 60
        }
        if let value = params["face_token"] as? String {
            faceToken = value
        } else {
            faceToken = ""
        }
        super.init()
    }

    var requsetURL: URL? {
        return kFaceppV3URL?
            .appendingPathComponent("face")
            .appendingPathComponent("getdetail")
    }

    func params() throws -> (Params, [Params]?) {
        return (["face_token": faceToken], nil)
    }
}

@objc(FppFaceGetDetailResponse)
@objcMembers public final class FaceGetDetailResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// face_token所属图片在系统中的标识
    public let imageId: String?
    /// 人脸标识face_token
    public let faceToken: String?
    /// 用户自定义的标签，如果未提供则为空
    public let userId: String?
    /// 人脸矩形框
    public let faceRectangle: FaceppRectangle?
    /// 包含该face_token的FaceSet数组
    public let facesets: [FaceSet]?
}

extension FaceGetDetailOption: FppDataRequestProtocol {
    @objc public func request(completionHandler: @escaping (Error?, FaceGetDetailResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

@objc(FppFaceAnalyzeOption)
@objcMembers public class FaceAnalyzeOption: NSObject, RequestProtocol {
    public var timeoutInterval: TimeInterval = 60

    public var needCheckParams: Bool = true

    public var metricsReporter: FaceppMetricsReporter?
    /// 一个字符串，由一个或多个人脸标识组成，用逗号分隔。最多支持 5 个 face_token。
    public var faceTokens: [String]
    /// 是否检测并返回人脸关键点
    public var returnLandmark = FaceDetectOption.ReturnLandmark.no
    /// 是否检测并返回根据人脸特征判断出的年龄、性别、情绪等属性
    @nonobjc public var returnAttributes: Set<FaceDetectOption.ReturnAttributes> = [.none]

    public var returnAttributesString: Set<String> {
        set {
            returnAttributes = Set(newValue.compactMap { FaceDetectOption.ReturnAttributes(rawValue: $0) })
        }
        get {
            Set(returnAttributes.map { $0.rawValue })
        }
    }

    /// 颜值评分分数区间的最小值。默认为0
    public var beautyScoreMin = 0
    /// 颜值评分分数区间的最大值。默认为100
    public var beautyScoreMax = 100

    var requsetURL: URL? {
        return kFaceppV3URL?
            .appendingPathComponent("face")
            .appendingPathComponent("analyze")
    }

    public init(tokens: [String]) {
        self.faceTokens = tokens
    }

    required public init(params: [String: Any]) {
        if let value = params["need_check_params"] as? Bool {
            needCheckParams = value
        } else {
            needCheckParams = true
        }
        if let value = params["timeout_interval"] as? TimeInterval {
            timeoutInterval = value
        } else {
            timeoutInterval = 60
        }
        if let value = params["face_tokens"] as? String {
            faceTokens = value.components(separatedBy: ",")
        } else {
            faceTokens = []
        }
        if let value = params["beauty_score_min"] as? Int {
            beautyScoreMin = value
        } else {
            beautyScoreMin = 0
        }
        if let value = params["beauty_score_max"] as? Int {
            beautyScoreMax = value
        } else {
            beautyScoreMax = 100
        }
        if let value = params["return_landmark"] as? Int {
            returnLandmark = FaceDetectOption.ReturnLandmark(rawValue: value) ?? .no
        } else {
            returnLandmark = .no
        }
        if let value = params["return_attributes"] as? String {
            returnAttributes = Set(value
                .components(separatedBy: ",")
                .compactMap {FaceDetectOption.ReturnAttributes(rawValue: $0) })
        } else {
            returnAttributes = [.none]
        }
        super.init()
    }

    func paramsCheck() throws -> Bool {
        guard needCheckParams else {
            return true
        }
        if returnAttributes == [.none] && returnLandmark == .no {
            throw FaceppRequestError
                .argumentsError(.invalidArguments(desc :"returnAttributes 和 returnLandmark 必须设置一个"))
        }
        return !faceTokens.isEmpty && faceTokens.count < 6
    }

    func params() throws -> (Params, [Params]?) {
        var params = Params()
        params["return_landmark"] = returnLandmark.rawValue
        params["return_attributes"] = returnAttributes.map { $0.rawValue }.joined(separator: ",")
        params["beauty_score_min"] = beautyScoreMin
        params["beauty_score_max"] = beautyScoreMax
        params["face_tokens"] = faceTokens.joined(separator: ",")
        return (params, nil)
    }
}

@objc(FppFaceAnalyzeResponse)
@objcMembers public final class FaceAnalyzeResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 经过分析的人脸数组
    public let faces: [Face]?
}

extension FaceAnalyzeOption: FppDataRequestProtocol {
    @objc public func request(completionHandler: @escaping (Error?, FaceAnalyzeResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}
