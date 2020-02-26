//
//  FaceSet.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/4.
//

import Foundation

let kFaceSetBaseURL = kFaceppV3URL?.appendingPathComponent("faceset")

// MARK: - 人脸集合
public struct FaceSet: Codable, UseFaceppClientProtocol {
    /// FaceSet 的标识
    public let facesetToken: String?
    /// 用户提供的FaceSet标识，如果未提供为""
    public var outerId: String?
    /// FaceSet的名字，如果未提供为""
    public var displayName: String?
    /// FaceSet的标签，如果未提供为""
    public var tags: [String]?

    public init(facesetToken: String?,
                outerId: String?,
                displayName: String?,
                tags: [String]?) {
        self.facesetToken = facesetToken
        self.outerId = outerId
        self.displayName = displayName
        self.tags = tags
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.facesetToken) {
            facesetToken = try container.decode(String.self, forKey: .facesetToken)
        } else {
            facesetToken = nil
        }
        if container.contains(.outerId) {
            outerId = try container.decode(String.self, forKey: .outerId)
        } else {
            outerId = nil
        }
        if container.contains(.displayName) {
            displayName = try container.decode(String.self, forKey: .displayName)
        } else {
            displayName = nil
        }
        if container.contains(.tags) {
            let str = try container.decode(String.self, forKey: .tags)
            tags = str.components(separatedBy: ",")
        } else {
            tags = nil
        }
    }
}

// MARK: - 获取某一 API Key 下的 FaceSet 列表及其 faceset_token、outer_id、display_name 和 tags 等信息。
/**
 获取某一 API Key 下的 FaceSet 列表及其 faceset_token、outer_id、display_name 和 tags 等信息。
 
 Wiki: https://console.faceplusplus.com.cn/documents/4888397
 */
public struct FaceSetGetOption: RequestProtocol {
    public var needCheckParams: Bool = true
    /// 超时时间
    public var timeoutInterval: TimeInterval = 60

    public var tags: [String]?
    /**
     一个数字 n，表示开始返回的 faceset_token 在传入的 API Key 下的序号。
     
     通过传入数字 n，可以控制本 API 从第 n 个 faceset_token 开始返回。返回的 faceset_token 按照创建时间排序。每次返回1000个FaceSets。
     
     默认值为1。
     */
    public var start: Int

    public init(start: Int = 1, tags: [String]?) {
        self.start = start
        self.tags = tags
    }

    var requsetURL: URL? {
        return kFaceSetBaseURL?.appendingPathComponent("getfacesets")
    }

    func params() throws -> (Params, [Params]?) {
        var params: Params = [
            "start": start
        ]
        params["tags"] = tags?.joined(separator: ",")
        return (params, nil)
    }
}

public struct FaceSetsGetResponse: ResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public let requestId: String?
    /**
     该 API Key 下的 FaceSet 信息。包含的元素见下文。
     
     注：如果该 API Key 下没有 FaceSet，则返回空数组。
     */
    public let facesets: [FaceSet]?
    /**
     用于进行下一次请求。返回值表示排在此次返回的所有 faceset_token 之后的下一个 faceset_token 的序号。
     
     如果返回此字段，则说明未返回完此 API Key 下的所有 faceset_token。可以将此字段的返回值，在下一次调用时传入 start 字段中，获取接下来的 faceset_token。
     
     如果没有返回该字段，则说明已经返回此 API Key 下的所有 faceset_token。
     */
    public let next: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public let timeUsed: Int?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public let errorMessage: String?
}

public extension FaceSet {
    @discardableResult
    static func getFaceSets(tags: [String] = [],
                            start: Int = 1,
                            completionHanlder: @escaping (Error?, [FaceSet]?) -> Void) -> URLSessionTask? {
        let option = FaceSetGetOption(start: start, tags: tags)
        return getFaceSets(option: option) { (error, resp) in
            if let err = error {
                completionHanlder(err, nil)
            } else {
                completionHanlder(nil, resp?.facesets)
            }
        }
    }

    @discardableResult
    static func getFaceSets(option: FaceSetGetOption,
                            completionHanlder: @escaping (Error?, FaceSetsGetResponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHanlder)
    }
}

// MARK: - 删除一个人脸集合
/**
 删除一个人脸集合。
 
 Wiki: https://console.faceplusplus.com.cn/documents/4888393
 */
public class FaceSetBaseRequest: RequestProtocol {
    public var needCheckParams: Bool = true
    /// 超时时间
    public var timeoutInterval: TimeInterval = 60
    /// FaceSet的标识
    public var facesetToken: String?
    /// 用户提供的FaceSet标识
    public var outerId: String?

    convenience init(faceset: FaceSet) {
        self.init(facesetToken: faceset.facesetToken, outerId: faceset.outerId)
    }

    public init(facesetToken: String?, outerId: String?) {
        self.facesetToken = facesetToken
        self.outerId = outerId
    }

    var requsetURL: URL? {
        return kFaceSetBaseURL
    }

    func paramsCheck() throws -> Bool {
        guard needCheckParams else {
            return true
        }
        return facesetToken != nil || outerId != nil
    }

    func params() throws -> (Params, [Params]?) {
        var params = Params()
        params["faceset_token"] = facesetToken
        params["outer_id"] = outerId
        return (params, nil)
    }
}

public class FaceSetsDeleteOption: FaceSetBaseRequest {
    /// 删除时是否检查FaceSet中是否存在face_token
    public var checkEmpty = true

    public init(facesetToken: String?, outerId: String?, checkEmpty: Bool = true) {
        super.init(facesetToken: facesetToken, outerId: outerId)
        self.checkEmpty = checkEmpty
    }

    override var requsetURL: URL? {
        return super.requsetURL?.appendingPathComponent("delete")
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, _) = try super.params()
        params["check_empty"] = checkEmpty ? 1 : 0
        return (params, nil)
    }
}

public struct FacesetDeleteResponse: ResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// FaceSet的标识
    public let facesetToken: String?
    /// 用户自定义的FaceSet标识，如果未定义则返回值为空
    public var outerId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
}

public extension FaceSet {
    @discardableResult
    func delete(completionHanlder: @escaping (Error?, FacesetDeleteResponse?) -> Void) -> URLSessionTask? {
        return Self.delete(option: .init(facesetToken: facesetToken, outerId: outerId),
                           completionHanlder: completionHanlder)
    }
    @discardableResult
    static func delete(option: FaceSetsDeleteOption,
                       completionHanlder: @escaping (Error?, FacesetDeleteResponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHanlder)
    }
}

// MARK: - 获取一个 FaceSet 的所有信息，包括此 FaceSet 的 faceset_token, outer_id, display_name 的信息，以及此 FaceSet 中存放的 face_token 数量与列表。
/**
 获取一个 FaceSet 的所有信息，包括此 FaceSet 的 faceset_token, outer_id, display_name 的信息，以及此 FaceSet 中存放的 face_token 数量与列表。
 
 Wiki: https://console.faceplusplus.com.cn/documents/4888395
 */
public class FacesetGetDetailOption: FaceSetBaseRequest {
    /**
     一个数字 n，表示开始返回的 face_token 在本 FaceSet 中的序号， n 是 [1,10000] 间的一个整数。
     
     通过传入数字 n，可以控制本 API 从第 n 个 face_token 开始返回。返回的 face_token 按照创建时间排序，每次返回 100 个 face_token。
     
     默认值为 1。
     
     您可以输入上一次请求本 API 返回的 next 值，用以获得接下来的 100 个 face_token。
     */
    public var start = 1

    public init(facesetToken: String?, outerId: String?, start: Int = 1) {
        super.init(facesetToken: facesetToken, outerId: outerId)
        self.start = start
    }

    override var requsetURL: URL? {
        return super.requsetURL?.appendingPathComponent("getdetail")
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, _) = try super.params()
        params["start"] = 1
        return (params, nil)
    }
}

public struct FacesetGetDetailResponse: ResponseProtocol {
    // 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// FaceSet的标识
    public var facesetToken: String?
    /// 用户自定义的FaceSet标识，如果未定义则返回值为空
    public var outerId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 人脸集合的名字
    public let displayName: String?
    /// 自定义用户信息
    public let userData: String?
    /// 自定义标签
    public let tags: String?
    /// FaceSet中的face_token总数量
    public let faceCount: Int?
    /**
     用于进行下一次请求。返回值表示排在此次返回的所有 face_token 之后的下一个 face_token 的序号。
     
     如果返回此字段，则说明未返回完此 FaceSet 下的所有 face_token。可以将此字段的返回值，在下一次调用时传入 start 字段中，获取接下来的 face_token。
     
     如果没有返回该字段，则说明已经返回此 FaceSet 下的所有 face_token。
     */
    public let next: String?
}

public extension FaceSet {
    @discardableResult
    func detail(start: Int = 1, completionHandler: @escaping (Error?, FacesetGetDetailResponse?) -> Void) -> URLSessionTask? {
        let option = FacesetGetDetailOption(facesetToken: facesetToken, outerId: outerId, start: start)
        option.start = start
        return Self.detail(option: option, completionHandler: completionHandler)
    }

    @discardableResult
    static func detail(option: FacesetGetDetailOption,
                       completionHandler: @escaping (Error?, FacesetGetDetailResponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHandler)
    }
}

// MARK: - 更新一个人脸集合的属性
/**
 更新一个人脸集合的属性
 
 Wiki: https://console.faceplusplus.com.cn/documents/4888401
 */
public class FacesetUpdateOption: FaceSetBaseRequest {
    /// 在api_key下全局唯一的FaceSet自定义标识，可以用来管理FaceSet对象。最长255个字符，不能包括字符^@,&=*'"
    public var newOuterId: String?
    /// 人脸集合的名字，256个字符
    public var displayName: String?
    /// 自定义用户信息，不大于16KB, 1KB=1024B 且不能包括字符^@,&=*'"
    public var userData: String?
    /// FaceSet自定义标签组成的字符串，用来对FaceSet分组。最长255个字符，多个tag用逗号分隔，每个tag不能包括字符^@,&=*'"
    public var tags: [String]?

    static let invalidUserDataCharacters = Set("^@,&=*'\"")

    override func paramsCheck() throws -> Bool {
        guard needCheckParams else {
            return true
        }
        guard (facesetToken != nil || outerId != nil)
            && (newOuterId != nil || displayName != nil || userData != nil || tags != nil) else {
                return false
        }
        if let userData = userData {
            guard userData.allSatisfy({ !FacesetUpdateOption.invalidUserDataCharacters.contains($0) }) else {
                throw FaceppRequestError.argumentsError(.invalidArguments(desc :"userData不能包括字符^@,&=*'"))
            }

            guard let data = userData.data(using: .utf8), data.count <= 16 * 1024 else {
                throw FaceppRequestError.argumentsError(.invalidArguments(desc :"userData不能包超过16KB"))
            }
        }

        if let tags = tags, !tags.isEmpty {
            guard tags.allSatisfy({ $0.allSatisfy({ !FacesetUpdateOption.invalidUserDataCharacters.contains($0)})}) else {
                throw FaceppRequestError.argumentsError(.invalidArguments(desc :"tag不能包括字符^@,&=*'"))
            }
            if tags.joined(separator: ",").unicodeScalars.count > 255 {
                throw FaceppRequestError.argumentsError(.invalidArguments(desc :"tags不能超过255字符"))
            }
        }

        return true
    }

    override var requsetURL: URL? {
        return super.requsetURL?.appendingPathComponent("update")
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, _) = try super.params()
        params["new_outer_id"] = newOuterId
        params["display_name"] = displayName
        params["user_data"] = userData
        params["tags"] = tags?.joined(separator: ",")
        return (params, nil)
    }
}

public struct FaceSetUpdateResponse: ResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 用户自定义的FaceSet标识，如果未定义则返回值为空
    public let outerId: String?
    /// FaceSet的标识
    public let facesetToken: String?
}

public extension FaceSet {
    @discardableResult
    func update(displayName: String?,
                userData: String?,
                tags: [String]?,
                completionHandler: @escaping (Error?, FaceSetUpdateResponse?) -> Void) -> URLSessionTask? {
        let option = FacesetUpdateOption(faceset: self)
        option.displayName = displayName
        option.userData = userData
        option.tags = tags
        return Self.update(option: option, completionHandler: completionHandler)
    }
    @discardableResult
    static func update(option: FacesetUpdateOption,
                       completionHandler: @escaping (Error?, FaceSetUpdateResponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHandler)
    }
}

// MARK: - 移除一个FaceSet中的某些或者全部face_token
/**
 移除一个FaceSet中的某些或者全部face_token
 
 Wiki: https://console.faceplusplus.com.cn/documents/4888399
 */
public class FaceSetRemoveOption: FaceSetBaseRequest {
    /// 是否删除全部
    fileprivate var removeAll = false
    /**
     需要移除的人脸标识字符串，可以是一个或者多个face_token组成，用逗号分隔。最多不能超过1,000个face_token
     
     注：face_tokens字符串传入“RemoveAllFaceTokens”则会移除FaceSet内所有的face_token
     */
    public var faceTokens = [String]()

    public init(facesetToken: String?, outerId: String?, tokens: [String] = []) {
        super.init(facesetToken: facesetToken, outerId: outerId)
        faceTokens = tokens
    }

    override var requsetURL: URL? {
        return kFaceSetBaseURL?.appendingPathComponent("removeface")
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, _) = try super.params()
        params["face_tokens"] = removeAll ? "RemoveAllFaceTokens" : faceTokens.joined(separator: ",")
        return (params, nil)
    }

    override func paramsCheck() -> Bool {
        guard needCheckParams else {
            return true
        }
        return removeAll || (!faceTokens.isEmpty && faceTokens.count <= 1000)
    }
}

public struct FaceSetOpFailureDetail: Codable {
    /// 人脸标识
    public let faceToken: String
    /// 操作失败的原因
    public let reason: String
}

public struct FaceSetRemoveResponse: ResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。除非发生404（API_NOT_FOUND ) 或403 （AUTHORIZATION_ERROR）错误，此字段必定返回。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。除非发生404（API_NOT_FOUND )或403 （AUTHORIZATION_ERROR）错误，此字段必定返回。
    public var timeUsed: Int?
    /// FaceSet的标识
    public let facesetToken: String?
    /// 用户自定义的FaceSet标识，如果未定义则返回值为空
    public let outerId: String?
    /// 成功从FaceSet中移除的face_token数量
    public let faceRemoved: Int?
    /// 操作完成后FaceSet中的face_token数量
    public let faceCount: Int?
    /// 无法从FaceSet中移除的face_token以及原因
    public let failureDetail: [FaceSetOpFailureDetail]?
}

public extension FaceSet {
    @discardableResult
    func remove(faceTokens: [String],
                completionHandler: @escaping (Error?, FaceSetRemoveResponse?) -> Void) -> URLSessionTask? {
        return Self.remove(option: .init(facesetToken: facesetToken, outerId: outerId, tokens: faceTokens),
                           completionHandler: completionHandler)
    }

    @discardableResult
    func removeAll(completionHandler: @escaping (Error?, FaceSetRemoveResponse?) -> Void) -> URLSessionTask? {
        let option = FaceSetRemoveOption(facesetToken: facesetToken, outerId: outerId)
        option.removeAll = true
        return Self.remove(option: option, completionHandler: completionHandler)
    }

    @discardableResult
    static func remove(option: FaceSetRemoveOption,
                       completionHandler: @escaping (Error?, FaceSetRemoveResponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHandler)
    }
}

// MARK: - 为一个已经创建的 FaceSet 添加人脸标识 face_token。一个 FaceSet 最多存储1,000个 face_token。
/**
 为一个已经创建的 FaceSet 添加人脸标识 face_token。一个 FaceSet 最多存储1,000个 face_token。
 
 Wiki: https://console.faceplusplus.com.cn/documents/4888389
 */
public class FaceSetAddFaceOption: FaceSetBaseRequest {
    /**
     人脸标识 face_token 组成的字符串，可以是一个或者多个，用逗号分隔。最多不超过5个face_token
     */
    public var faceTokens: [String]

    public init(facesetToken: String?, outerId: String?, tokens: [String]) {
        faceTokens = tokens
        super.init(facesetToken: facesetToken, outerId: outerId)

    }

    public init(faceset: FaceSet, tokens: [String]) {
        faceTokens = tokens
        super.init(facesetToken: faceset.facesetToken, outerId: faceset.outerId)
    }

    override var requsetURL: URL? {
        return super.requsetURL?.appendingPathComponent("addface")
    }

    override func paramsCheck() throws -> Bool {
        guard needCheckParams else {
            return true
        }
        guard faceTokens.count <= 5 else {
            throw FaceppRequestError.argumentsError(.invalidArguments(desc: "最多不超过5个faceToken"))
        }
        return (facesetToken != nil || outerId != nil)
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, _) = try super.params()
        params["face_tokens"] = faceTokens.joined(separator: ",")
        return (params, nil)
    }
}

public struct FaceSetAddFaceResponse: ResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，否则此字段不存在。具体返回内容见后续错误信息章节。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 成功加入 FaceSet 的 face_token 数量。
    public let faceAdded: Int?
    /// 操作结束后 FaceSet 中的 face_token 总数量。
    public let faceCount: Int?
    /// 无法被加入FaceSet的face_token以及原因
    public let failureDetail: [FaceSetOpFailureDetail]?
}

public extension FaceSet {
    @discardableResult
    func add(faceTokens: [String],
             completionHandler: @escaping (Error?, FaceSetAddFaceResponse?) -> Void) -> URLSessionTask? {
        return Self.add(option: .init(faceset: self, tokens: faceTokens), completionHandler: completionHandler)
    }

    @discardableResult
    static func add(option: FaceSetAddFaceOption,
                    completionHandler: @escaping (Error?, FaceSetAddFaceResponse?) -> Void) -> URLSessionTask? {
        parse(option: option, completionHandler: completionHandler)
    }
}

// MARK: - 创建一个人脸的集合 FaceSet，用于存储人脸标识 face_token。一个 FaceSet 能够存储10000个 face_token。
/**
 创建一个人脸的集合 FaceSet，用于存储人脸标识 face_token。一个 FaceSet 能够存储10000个 face_token。
 
 试用API Key可以创建1000个FaceSet，正式API Key可以创建10000个FaceSet。
 
 Wiki: https://console.faceplusplus.com.cn/documents/4888391
 */
public struct FaceSetCreateOption: RequestProtocol {
    public var needCheckParams: Bool = true
    /// 超时时间
    public var timeoutInterval: TimeInterval = 60
    /// 人脸集合的名字，最长256个字符，不能包括字符^@,&=*'"
    public var displayName: String?
    /// 账号下全局唯一的 FaceSet 自定义标识，可以用来管理 FaceSet 对象。最长255个字符，不能包括字符^@,&=*'"
    public var outerId: String?
    /// FaceSet 自定义标签组成的字符串，用来对 FaceSet 分组。最长255个字符，多个 tag 用逗号分隔，每个 tag 不能包括字符^@,&=*'"
    public var tags: [String]?
    /// 人脸标识 face_token，可以是一个或者多个，用逗号分隔。最多不超过5个 face_token
    public var faceTokens: [String]?
    /// 自定义用户信息，不大于16 KB，不能包括字符^@,&=*'"
    public var userData: String?
    /**
     在传入 outer_id 的情况下，如果 outer_id 已经存在，是否将 face_token 加入已经存在的 FaceSet 中
     
     0：不将 face_tokens 加入已存在的 FaceSet 中，直接返回 FACESET_EXIST 错误
     
     1：将 face_tokens 加入已存在的 FaceSet 中
     
     默认值为0
     */
    public var forceMerge = 1

    public init() {}

    func paramsCheck() throws -> Bool {
        guard needCheckParams else {
            return true
        }

        if let data = userData {
            guard data.allSatisfy({ !FacesetUpdateOption.invalidUserDataCharacters.contains($0) }) else {
                throw FaceppRequestError.argumentsError(.invalidArguments(desc: "userData不能包括字符^@,&=*'"))
            }

            guard let d = data.data(using: .utf8), d.count <= 16 * 1024 else {
                throw FaceppRequestError.argumentsError(.invalidArguments(desc: "userData不能超过16KB"))
            }
        }

        if let tags = tags, !tags.isEmpty {
            guard tags.allSatisfy({ $0.allSatisfy({ !FacesetUpdateOption.invalidUserDataCharacters.contains($0)})}) else {
                throw FaceppRequestError.argumentsError(.invalidArguments(desc: "tags不能包括字符^@,&=*'"))
            }
            if tags.joined(separator: ",").unicodeScalars.count > 255 {
                throw FaceppRequestError.argumentsError(.invalidArguments(desc: "tag不能超过255个字符"))
            }
        }

        return true
    }

    var requsetURL: URL? {
        return kFaceSetBaseURL?.appendingPathComponent("create")
    }

    func params() throws -> (Params, [Params]?) {
        var params = Params()
        params["outer_id"] = outerId
        params["tags"] = tags?.joined(separator: ",")
        params["face_tokens"] = faceTokens?.joined(separator: ",")
        params["user_data"] = userData
        params["force_merge"] = forceMerge
        return (params, nil)
    }
}

public struct FaceSetCreateResponse: ResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。除非发生404（API_NOT_FOUND ) 或403 （AUTHORIZATION_ERROR）错误，此字段必定返回。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。除非发生404（API_NOT_FOUND )或403 （AUTHORIZATION_ERROR）错误，此字段必定返回。
    public var timeUsed: Int?
    /// 用户自定义的 FaceSet 标识，如果未定义则返回值为空
    public let outerId: String?
    /// 本次操作成功加入 FaceSet的face_token 数量
    public let faceAdded: Int?
    /// 操作结束后 FaceSet 中的 face_token 总数量
    public let faceCount: Int?
    /// FaceSet 的标识
    public let facesetToken: String?
    /**
     无法被加入 FaceSet 的 face_token 以及原因
     
     face_token：人脸标识
     
     reason：不能被添加的原因，包括 INVALID_FACE_TOKEN 人脸表示不存在 ，QUOTA_EXCEEDED 已达到 FaceSet 存储上限
     */
    public var failureDetail: [FaceSetOpFailureDetail]?
}

public extension FaceSet {
    @discardableResult
    static func new(option: FaceSetCreateOption,
                    completionHandler: @escaping (Error?, FaceSet?) -> Void) -> URLSessionTask? {
        return create(option: option) { error, response in
            if error != nil {
                completionHandler(error, nil)
            } else if let resp = response {
                completionHandler(nil,
                    .init(facesetToken: resp.facesetToken,
                          outerId: resp.outerId,
                          displayName: option.displayName,
                          tags: option.tags))
            } else {
                completionHandler(nil, nil)
            }
        }
    }
    @discardableResult
    static func create(option: FaceSetCreateOption,
                       completionHandler: @escaping (Error?, FaceSetCreateResponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHandler)
    }
}

// MARK: - 查询之前调用的异步添加/删除人脸请求，异步任务当前的状态
let kBaseFaceSetAsyncTaskURL = kFaceSetBaseURL?.appendingPathComponent("async")
/**
 查询之前调用的异步添加/删除人脸请求，异步任务当前的状态
 
 Wiki: https://console.faceplusplus.com.cn/documents/40622157
 */
public struct FaceSetTaskQueryOption: RequestProtocol {
    var needCheckParams: Bool = false
    /// 超时时间
    public var timeoutInterval: TimeInterval = 60
    /// 异步任务的唯一标识
    public var taskId: String

    public init(taskId: String) {
        self.taskId = taskId
    }

    var requsetURL: URL? {
        return kBaseFaceSetAsyncTaskURL?.appendingPathComponent("task_status")
    }

    func params() throws -> (Params, [Params]?) {
        return (["task_id": taskId], nil)
    }
}

public struct FaceSetTaskQueryResponse: ResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    // MARK: - 任务完成返回
    /// 1: 标示当前异步任务已经完成
    public let status: Int?
    /// FaceSet 的标识
    public let facesetToken: String?
    /// 用户自定义的 FaceSet 标识，如果未定义则返回值为空
    public let outerId: String?
    /// 成功加入 FaceSet 的 face_token 数量（如果当前任务类型为添加人脸，返回此字段）
    public var faceAdded: Int?
    /// 成功从FaceSet中移除的face_token数量（如果当前任务类型为删除人脸，返回此字段）
    public let faceRemoved: Int?
    /// 操作结束后 FaceSet 中的 face_token 总数量
    public let faceCount: Int?
    /**
     无法被加入/删除FaceSet的face_token以及原因
     
     face_token：人脸标识不存在
     
     reason：不能被添加的原因，包括 INVALID_FACE_TOKEN 人脸标识不存在 ，QUOTA_EXCEEDED 已达到FaceSet存储上限
     */
    public let failureDetail: [FaceSetOpFailureDetail]?
}

public extension FaceSet {
    @discardableResult
    static func asyncQuery(taskId: String,
                           completionHandler: @escaping (Error?, FaceSetTaskQueryResponse?) -> Void) -> URLSessionTask? {
        return asyncQuery(option: .init(taskId: taskId), completionHandler: completionHandler)
    }
    @discardableResult
    static func asyncQuery(option: FaceSetTaskQueryOption,
                           completionHandler: @escaping (Error?, FaceSetTaskQueryResponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHandler)
    }
}

// MARK: - (异步) 为一个已经创建的 FaceSet 添加人脸标识 face_token。一个 FaceSet 最多存储1,000个 face_token。
/**
 为一个已经创建的 FaceSet 添加人脸标识 face_token。一个 FaceSet 最多存储1,000个 face_token。
 
 Wiki: https://console.faceplusplus.com.cn/documents/40622166
 */
public class FaceSetAsyncAddFaceOption: FaceSetAddFaceOption {
    override var requsetURL: URL? {
        return kBaseFaceSetAsyncTaskURL?.appendingPathComponent("addface")
    }
}

public struct FaceSetAsyncOperationResponse: ResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 标示当前异步请求的唯一task标识，之后调用任务状态查询接口时，使用当前值作为参数，如果发生错误，此字段不返回。
    public let taskId: String?
}

public extension FaceSet {
    @discardableResult
    func asyncAdd(faceTokens: [String],
                  completionHandler: @escaping (Error?, String?) -> Void) -> URLSessionTask? {
        return Self.asyncAdd(option: .init(faceset: self, tokens: faceTokens)) { error, resp in
            if let err = error {
                completionHandler(err, nil)
            } else {
                completionHandler(nil, resp?.taskId)
            }
        }
    }
    @discardableResult
    static func asyncAdd(option: FaceSetAsyncAddFaceOption,
                         completionHandler: @escaping (Error?, FaceSetAsyncOperationResponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHandler)
    }
}

// MARK: - （异步）移除一个FaceSet中的某些或者全部face_token
/**
 移除一个FaceSet中的某些或者全部face_token
 
 Wiki: https://console.faceplusplus.com.cn/documents/40622169
 */
public class FaceSetAsyncRemoveOption: FaceSetRemoveOption {
    override var requsetURL: URL? {
        return kBaseFaceSetAsyncTaskURL?.appendingPathComponent("removeface")
    }
}

public extension FaceSet {
    @discardableResult
    func asyncRemove(faceTokens: [String], completionHandler: @escaping (Error?, String?) -> Void) -> URLSessionTask? {
        return Self.asyncAdd(option: .init(faceset: self, tokens: faceTokens)) { error, resp in
            if let err = error {
                completionHandler(err, nil)
            } else {
                completionHandler(nil, resp?.taskId)
            }
        }
    }
    @discardableResult
    static func asyncRemove(option: FaceSetAsyncRemoveOption,
                            completionHandler: @escaping (Error?, FaceSetAsyncOperationResponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHandler)
    }
}
