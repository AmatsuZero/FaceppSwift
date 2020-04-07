//
//  FaceAlbum.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/17.
//  Wiki: https://console.faceplusplus.com.cn/documents/51345189
//

import Foundation
#if os(Linux)
import FoundationNetworking
#endif

let kFaceAlbumBaseURL: URL? = {
    return kImageppV1URL?.appendingPathComponent("facealbum")
}()

@objc(FppFaceAlbum)
public final class FaceAlbum: NSObject, Codable, UseFaceppClientProtocol {
    /// faceAlbum 的标识
    public let facealbumToken: String

    public init(facealbumToken: String) {
        self.facealbumToken = facealbumToken
        super.init()
    }
}

@objc(FppFaceAlbumBaseRequest)
@objcMembers public class FaceAlbumBaseRequest: NSObject, RequestProtocol {
    /// 是否检查参数
    public var needCheckParams: Bool
    /// 超时时间
    public var timeoutInterval: TimeInterval = 60
    /// FaceAlbum 标识
    public var facealbumToken: String

    public weak var metricsReporter: FaceppMetricsReporter?

    public init(facealbumToken: String) {
        self.facealbumToken = facealbumToken
        needCheckParams = false
        super.init()
    }

    public convenience init(album: FaceAlbum) {
        self.init(facealbumToken: album.facealbumToken)
    }

    public required init(params: [String: Any]) {
        if let value = params["need_check_params"] as? Bool {
            needCheckParams = value
        } else {
            needCheckParams = false
        }
        if let value = params["timeout_interval"] as? TimeInterval {
            timeoutInterval = value
        } else {
            timeoutInterval = 60
        }
        if let token = params["facealbum_token"] as? String {
            facealbumToken = token
        } else {
            facealbumToken = ""
        }
        super.init()
    }

    var requsetURL: URL? {
        return kFaceAlbumBaseURL
    }

    func params() throws -> (Params, [Params]?) {
        return (["facealbum_token": facealbumToken], nil)
    }
}
/**
 创建一个人脸相册 FaceAlbum，用于存储相片的image_id、相片中人脸标识face_token、以及人脸标识对应的聚类分组group_id。一个FaceAlbum能够存储10000个face_token。
 注意：免费用户可最多创建10个FaceAlbum，而付费用户没有相册数量限制。免费用户的相册自创建后会保存100天，然后会被删除。
 如果付费用户透支账户余额后，创建的FaceAlbum会保留30天，然后被删除。
 */
@objc(FppCreateFaceAlbumOption)
@objcMembers public final class CreateFaceAlbumOption: NSObject, RequestProtocol {

    public var needCheckParams: Bool = false
    /// 超时时间
    public var timeoutInterval: TimeInterval = 60
    var requsetURL: URL? {
        return kFaceAlbumBaseURL?.appendingPathComponent("createalbum")
    }

    public weak var metricsReporter: FaceppMetricsReporter?

    public override init() {
        super.init()
    }

    required public init(params: [String: Any]) {
        if let value = params["need_check_params"] as? Bool {
            needCheckParams = value
        }
        if let value = params["timeout_interval"] as? TimeInterval {
            timeoutInterval = value
        }
        super.init()
    }

    func params() throws -> (Params, [Params]?) {
        return ([:], nil)
    }
}

extension CreateFaceAlbumOption: FppDataRequestProtocol {
    @objc public func request(completionHandler: @escaping (Error?, FaceAlbumBaseReeponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumBaseReeponse)
@objcMembers public final class FaceAlbumBaseReeponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，否则此字段不存在。具体返回内容见后续错误信息章节。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 创建的 FaceAlbum 的标识。
    public let facealbumToken: String?
}

public extension FaceAlbum {
    @discardableResult
    static func create(option: CreateFaceAlbumOption = CreateFaceAlbumOption(),
                       completionHandler: @escaping (Error?, FaceAlbumBaseReeponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHandler)
    }

    @discardableResult
    static func
        createAlbum(completionHandler: @escaping (Error?, FaceAlbum?) -> Void) -> URLSessionTask? {
        return create { error, resp in
            if let token = resp?.facealbumToken {
                completionHandler(error, FaceAlbum(facealbumToken: token))
            } else {
                completionHandler(nil, nil)
            }
        }
    }
}

/// 删除 FaceAlbum，该相册对应的image_id, face_token，face_token对应的group_id也都会被删除。
@objc(FppFaceAlbumDeleteOption)
@objcMembers public class FaceAlbumDeleteOption: FaceAlbumBaseRequest {
    /// 删除时是否检查 FaceAlbum 中是否存在 face_token
    public var checkEmpty = false

    override func params() throws -> (Params, [Params]?) {
        var (params, _) = try super.params()
        params["check_empty"] = checkEmpty ? 1 : 0
        return (params, nil)
    }
}

extension FaceAlbumDeleteOption: FppDataRequestProtocol {
    @objc public func request(completionHandler: @escaping (Error?, FaceAlbumBaseReeponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

public extension FaceAlbum {
    @discardableResult
    static func delete(option: FaceAlbumDeleteOption,
                       completionHandler: @escaping (Error?, FaceAlbumBaseReeponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHandler)
    }

    @discardableResult
    static func deleteAlbum(option: FaceAlbumDeleteOption,
                            completionHandler: @escaping (Error?, FaceAlbum?) -> Void) -> URLSessionTask? {
        return delete(option: option) { error, resp in
            if let token = resp?.facealbumToken {
                completionHandler(error, FaceAlbum(facealbumToken: token))
            } else {
                completionHandler(nil, nil)
            }
        }
    }

    @discardableResult
    func delete(checkEmpty: Bool = false,
                completionHandler: @escaping (Error?, FaceAlbumBaseReeponse?) -> Void) -> URLSessionTask? {
        let option = FaceAlbumDeleteOption(album: self)
        option.checkEmpty = checkEmpty
        return Self.delete(option: option, completionHandler: completionHandler)
    }
}

/// 查找与某一分组相似的分组，用于在同一个人的人脸被分为多个组的情况下，提示用户确认两个分组的人脸是否属于同一个人。
@objc(FppFaceAlbumFindCandidateOption)
@objcMembers public class FaceAlbumFindCandidateOption: FaceAlbumBaseRequest {
    /// 用以查找相似分组的人脸分组的标识GroupID 不能为 0 或者 -1
    public var groupId: String

    public init(token: String, groupId: String) {
        self.groupId = groupId
        super.init(facealbumToken: token)
        needCheckParams = true
    }

    public convenience init(album: FaceAlbum, groupId: String) {
        self.init(token: album.facealbumToken, groupId: groupId)
    }

    public required init(params: [String: Any]) {
        if let value = params["group_id"] as? String {
            groupId = value
        } else {
            groupId = ""
        }
        super.init(params: params)
    }

    override var requsetURL: URL? {
        return kFaceAlbumBaseURL?.appendingPathComponent("findcandidate")
    }

    func paramsCheck() throws -> Bool {
        guard needCheckParams else {
            return true
        }
        guard groupId != "0" || groupId != "-1" else {
            throw FaceppRequestError.argumentsError(.invalidArguments(desc: "groupId不能为0或-1：\(groupId)"))
        }
        return true
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, _) = try super.params()
        params["group_id"] = groupId
        return (params, nil)
    }
}

extension FaceAlbumFindCandidateOption: FppDataRequestProtocol {
    @objc public func request(completionHandler: @escaping (Error?, FaceAlbumFindCandidateResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumFindCandidateResponse)
@objcMembers public final class FaceAlbumFindCandidateResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，否则此字段不存在。具体返回内容见后续错误信息章节。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 创建的 FaceAlbum 的标识。
    public let facealbumToken: String?

    @objc(FppCandidateGroup)
    @objcMembers public class CandidateGroup: NSObject, Codable {
        public let groupId: String
        /// 置信度
        public let similarity: Float
    }
    /**
     与指定的 group_id 内人脸相似的人脸分组列表，以及相似性的置信度Similarity。
     置信度最高的排在最前面
     */
    public let candidateGroups: [CandidateGroup]?
}

public extension FaceAlbum {
    @discardableResult
    static func findCandidate(option: FaceAlbumFindCandidateOption,
                              completionHandler: @escaping (Error?, FaceAlbumFindCandidateResponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHandler)
    }

    @discardableResult
    func findCandidate(groupId: String,
                       completionHandler: @escaping (Error?, [FaceAlbumFindCandidateResponse.CandidateGroup]?) -> Void)
        -> URLSessionTask? {
            let option = FaceAlbumFindCandidateOption(album: self, groupId: groupId)
            return FaceAlbum.findCandidate(option: option) { error, response in
                if let groups = response?.candidateGroups {
                    completionHandler(nil, groups)
                } else {
                    completionHandler(error, nil)
                }
            }
    }
}

@objc(FppFaceAlbumSearchImageOption)
@objcMembers public class FaceAlbumSearchImageOption: FaceppBaseRequest {
    /// FaceAlbum标识
    public var facealbumToken: String
    /**
     一个URL。API任务完成后会调用该url，通知用户任务完成。
     注：任务完成后，会向传入的 callback_url 发送一个 GET 请求，将 task_id 作为 querystring 中的 task_id 参数传递给用户.
     例：http://cburl?task_id=xxxxxxx
     */
    public var callbackURL: URL?

    public init(facealbumToken: String) {
        self.facealbumToken = facealbumToken
        super.init()
    }

    public convenience init(album: FaceAlbum) {
        self.init(facealbumToken: album.facealbumToken)
    }

    required public init(params: [String: Any]) {
        if let value = params["facealbum_token"] as? String {
            facealbumToken = value
        } else {
            facealbumToken = ""
        }
        if let value = params["callback_url"] as? String {
            callbackURL = URL(string: value)
        }
        super.init(params: params)
    }

    override var requsetURL: URL? {
        return kFaceAlbumBaseURL?.appendingPathComponent("searchimage")
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, files) = try super.params()
        params["facealbum_token"] = facealbumToken
        params["callback_url"] = callbackURL
        return (params, files)
    }
}

extension FaceAlbumSearchImageOption: FppDataRequestProtocol {
    @objc public func request(completionHandler: @escaping (Error?, FaceAlbumSearchImageResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumSearchImageResponse)
@objcMembers public final class FaceAlbumSearchImageResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，否则此字段不存在。具体返回内容见后续错误信息章节。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /**
     标示当前异步请求的唯一task标识，之后调用任务状态查询接口时，使用当前值作为参数，如果发生错误，此字段不返回。
     注意：该task_id及其结果只会保存24小时，之后会被服务器删除。
     */
    public let taskId: String?
    /// FaceAlbum标识
    public let facealbumToken: String?
}

public extension FaceAlbum {
    @discardableResult
    static func searchImage(option: FaceAlbumSearchImageOption,
                            completionHandler:@escaping (Error?, FaceAlbumSearchImageResponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHandler)
    }

    @discardableResult
    func searchImage(imageURL: URL?,
                     imageFile: URL?,
                     imageBase64: String?,
                     completionHandler: @escaping (Error?, FaceAlbumSearchImageResponse?) -> Void) -> URLSessionTask? {
        let option = FaceAlbumSearchImageOption(album: self)
        option.imageURL = imageURL
        option.imageFile = imageFile
        option.imageBase64 = imageBase64
        return Self.searchImage(option: option, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumTaskQueryBaseOption)
@objcMembers public class FaceAlbumTaskQueryBaseOption: NSObject, RequestProtocol {
    /// 异步任务的唯一标识
    public let taskId: String
    /// 超时时间
    public var timeoutInterval: TimeInterval = 60

    public var needCheckParams: Bool = false

    public weak var metricsReporter: FaceppMetricsReporter?

    public init(taskId: String) {
        self.taskId = taskId
    }

    public required init(params: [String: Any]) {
        if let value = params["need_check_params"] as? Bool {
            needCheckParams = value
        }
        if let value = params["timeout_interval"] as? TimeInterval {
            timeoutInterval = value
        }
        if let value = params["task_id"] as? String {
            taskId = value
        } else {
            taskId = ""
        }
    }

    var requsetURL: URL? {
        return kFaceAlbumBaseURL
    }

    func params() throws -> (Params, [Params]?) {
        return (["task_id": taskId], nil)
    }
}

@objc(FppFaceAlbumSearchImageTaskQueryOption)
public class FaceAlbumSearchImageTaskQueryOption: FaceAlbumTaskQueryBaseOption {
    override var requsetURL: URL? {
        return super.requsetURL?.appendingPathComponent("searchimagetaskquery")
    }
}

extension FaceAlbumSearchImageTaskQueryOption: FppDataRequestProtocol {
    @objc public func request(completionHandler:
        @escaping (Error?, FaceAlbumSearchImageTaskQueryResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumSearchImageTaskQueryResponse)
@objcMembers public final class FaceAlbumSearchImageTaskQueryResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，否则此字段不存在。具体返回内容见后续错误信息章节。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 标示异步请求的唯一task标识
    public let taskId: String?
    /// 是否完成
    public let isCompleted: Bool?
    /// FaceAlbum 标识
    public let facealbumToken: String?

    private enum CodingKeys: String, CodingKey {
        case requestId, errorMessage, timeUsed, taskId
        case searchResult, taskFailureMessage, facealbumToken
        case isCompleted = "status"
    }

    @objc(FppSearchResult)
    @objcMembers public class SearchResult: NSObject, Codable {
        /// 该face在提供图片中的位置
        public let faceRectangle: FaceppRectangle
        /// 相册中拥有该相同face的相片image_id的String, 多个用逗号分隔
        public let imageIdSet: Set<String>

        required public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            faceRectangle = try container.decode(FaceppRectangle.self, forKey: .faceRectangle)
            let tokens = try container.decode(String.self, forKey: .imageIdSet).components(separatedBy: ",")
            imageIdSet = Set(tokens)
        }
    }
    /// 提供图片中每个人脸返回一个搜索结果
    public let searchResult: [SearchResult]?

    /// 当异步任务失败时才会返回此字符串，否则此字段不存在
    public let taskFailureMessage: String?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.requestId) {
            requestId = try container.decode(String.self, forKey: .requestId)
        } else {
            requestId = nil
        }
        if container.contains(.errorMessage) {
            errorMessage = try container.decode(String.self, forKey: .errorMessage)
        } else {
            errorMessage = nil
        }
        if container.contains(.timeUsed) {
            timeUsed = try container.decode(Int.self, forKey: .timeUsed)
        } else {
            timeUsed = nil
        }
        if container.contains(.isCompleted) {
            let result = try container.decode(Int.self, forKey: .isCompleted)
            isCompleted = result == 1
        } else {
            isCompleted = nil
        }
        if container.contains(.searchResult) {
            searchResult = try container.decode([SearchResult].self, forKey: .searchResult)
        } else {
            searchResult = nil
        }
        if container.contains(.taskFailureMessage) {
            taskFailureMessage = try container.decode(String.self, forKey: .taskFailureMessage)
        } else {
            taskFailureMessage = nil
        }
        if container.contains(.taskId) {
            taskId = try container.decode(String.self, forKey: .taskId)
        } else {
            taskId = nil
        }
        if container.contains(.facealbumToken) {
            facealbumToken = try container.decode(String.self, forKey: .facealbumToken)
        } else {
            facealbumToken = nil
        }
    }
}

public extension FaceAlbum {
    @discardableResult
    static func searchImageTaskQuery(option: FaceAlbumSearchImageTaskQueryOption,
                                     completionHandler: @escaping (Error?, FaceAlbumSearchImageTaskQueryResponse?) -> Void)
        -> URLSessionTask? {
            return parse(option: option, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumUpdateFaceOption)
@objcMembers public class FaceAlbumUpdateFaceOption: FaceAlbumBaseRequest {
    /// 由人脸标识 face_token 组成的字符串。至少传入一个 face_token，最多不超过10个
    public var faceTokens: [String]
    /**
     人脸的新的分组信息。可以传入三类值：
     如果传入一个已经存在的 group_id，则人脸会被分到相应的组中。
     如果传入“CreateNewGroup”，则会为传入人脸创建一个新的分组，并返回新的 group_id。
     如果传入 -1，则人脸会被置为“未分组”状态。
     */
    public var newGroupId: String

    override var requsetURL: URL? {
        return super.requsetURL?.appendingPathComponent("updateface")
    }

    public init(faceTokens: [String], newGroupId: String, faceAlbumToken: String) {
        self.faceTokens = faceTokens
        self.newGroupId = newGroupId
        super.init(facealbumToken: faceAlbumToken)
        needCheckParams = true
    }

    public required init(params: [String: Any]) {
        if let tokens = params["face_tokens"] as? String {
            faceTokens = tokens.components(separatedBy: ",")
        } else {
            faceTokens = []
        }
        if let id = params["new_group_id"] as? String {
            newGroupId = id
        } else {
            newGroupId = ""
        }
        super.init(params: params)
    }

    func paramsCheck() throws -> Bool {
        guard needCheckParams else {
            return true
        }
        guard faceTokens.count <= 10, !faceTokens.isEmpty else {
            throw FaceppRequestError.argumentsError(.invalidArguments(desc: "faceTokens数量应为[1, 10]"))
        }
        return try super.paramsCheck()
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, _) = try super.params()
        params["face_tokens"] = faceTokens.joined(separator: ",")
        params["new_group_id"] = newGroupId
        return (params, nil)
    }
}

extension FaceAlbumUpdateFaceOption: FppDataRequestProtocol {
    @objc public func request(completionHandler: @escaping (Error?, FaceAlbumUpdateFaceResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumUpdateFaceResponse)
@objcMembers public final class FaceAlbumUpdateFaceResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，否则此字段不存在。具体返回内容见后续错误信息章节。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 分组修改成功的face_tokens
    public let faceTokensSuccess: [String]?

    @objc(FppFaceAlbumUpdateFailureDetail)
    @objcMembers public final class FailureDetail: NSObject, Codable {
        /// 人脸标识
        public let faceToken: String
        /// 不能被更新的原因，包括 INVALID_FACE_TOKEN 人脸标识不存在
        public let reason: String
    }
    /// 无法更新 group_id 的 face_token 以及原因
    public let failureDetail: [FailureDetail]?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.requestId) {
            requestId = try container.decode(String.self, forKey: .requestId)
        } else {
            requestId = nil
        }
        if container.contains(.errorMessage) {
            errorMessage = try container.decode(String.self, forKey: .errorMessage)
        } else {
            errorMessage = nil
        }
        if container.contains(.timeUsed) {
            timeUsed = try container.decode(Int.self, forKey: .timeUsed)
        } else {
            timeUsed = nil
        }
        if container.contains(.faceTokensSuccess) {
            let string = try container.decode(String.self, forKey: .faceTokensSuccess)
            faceTokensSuccess = string.components(separatedBy: ",")
        } else {
            faceTokensSuccess = nil
        }
        if container.contains(.failureDetail) {
            failureDetail = try container.decode([FailureDetail].self, forKey: .failureDetail)
        } else {
            failureDetail = nil
        }
    }
}

public extension FaceAlbum {
    @discardableResult
    static func updateFace(option: FaceAlbumUpdateFaceOption,
                           completionHandler:@escaping (Error?, FaceAlbumUpdateFaceResponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHandler)
    }

    @discardableResult
    func updateFace(faceTokens: [String],
                    newGroupId: String,
                    completionHandler:@escaping (Error?, FaceAlbumUpdateFaceResponse?) -> Void) -> URLSessionTask? {
        let option = FaceAlbumUpdateFaceOption(faceTokens: faceTokens,
                                               newGroupId: newGroupId,
                                               faceAlbumToken: facealbumToken)
        return Self.updateFace(option: option, completionHandler: completionHandler)
    }
}

@objc(FppFaceAblbumGetFaceDetailOption)
@objcMembers public class FaceAblbumGetFaceDetailOption: FaceAlbumBaseRequest {
    /// 人脸标识face_token字符串
    public let faceToken: String

    override var requsetURL: URL? {
        return super.requsetURL?.appendingPathComponent("getfacedetail")
    }

    public init(faceAlbumToken: String, faceToken: String) {
        self.faceToken = faceToken
        super.init(facealbumToken: faceAlbumToken)
    }

    public required init(params: [String: Any]) {
        if let token = params["face_token"] as? String {
            faceToken = token
        } else {
            faceToken = ""
        }
        super.init(params: params)
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, _) = try super.params()
        params["face_token"] = faceToken
        return (params, nil)
    }
}

@objc(FppFaceAlbumUngroupedReason)
public enum FaceAlbumUngroupedReason: Int, Codable {
    /// 人脸图像质量过低
    case qualityTooLow = 0
    /// 人脸图像尺寸过小（高度或宽度）
    case sizeTooSmall
    /// 人脸角度过大
    case angleTooLarge
    /// 人脸图像太模糊
    case tooBlur
    /// 孤立人脸（无法找到相似人脸）
    case noSimilarPortrait
    /// 其他原因
    case otherReason
}

@objc(FppFaceAblbumGetFaceDetailResponse)
@objcMembers public final class FaceAblbumGetFaceDetailResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，否则此字段不存在。具体返回内容见后续错误信息章节。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 人脸的标识
    public let faceToken: String?
    /// 所属FaceAlbum 标识
    public let facealbumToken: String?
    /// 人脸矩形框的位置
    public let faceRectangle: FaceppRectangle?
    /// 人脸对应的图片在系统中的标识
    public let imageId: String?
    /// 分组信息
    public let groupId: String?
    /// 人脸未被分组的原因。只有当该人脸的 group_id = 0 时，才会返回此字段。否则不返回
    public let ungroupedReason: FaceAlbumUngroupedReason?
}

extension FaceAblbumGetFaceDetailOption: FppDataRequestProtocol {
    @objc public func request(completionHandler:
        @escaping (Error?, FaceAblbumGetFaceDetailResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

public extension FaceAlbum {
    @discardableResult
    static func getFaceDetail(option: FaceAblbumGetFaceDetailOption,
                              completionHandler:@escaping (Error?, FaceAblbumGetFaceDetailResponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHandler)
    }

    @discardableResult
    func getFaceDetail(faceToken: String,
                       completionHandler:@escaping (Error?, FaceAblbumGetFaceDetailResponse?) -> Void) -> URLSessionTask? {
        let option = FaceAblbumGetFaceDetailOption(faceAlbumToken: faceToken, faceToken: faceToken)
        return FaceAlbum.getFaceDetail(option: option, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumGetImageDetailOption)
@objcMembers public class FaceAlbumGetImageDetailOption: FaceAlbumBaseRequest {
    /// 要查看图片在系统中的标识
    public let imageId: String

    override var requsetURL: URL? {
        return super.requsetURL?.appendingPathComponent("getimagedetail")
    }

    public init(faceAlbumToken: String, imageId: String) {
        self.imageId = imageId
        super.init(facealbumToken: faceAlbumToken)
    }

    public required init(params: [String: Any]) {
        if let value = params["image_id"] as? String {
            imageId = value
        } else {
            imageId = ""
        }
        super.init(params: params)
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, _) = try super.params()
        params["image_id"] = imageId
        return (params, nil)
    }
}

extension FaceAlbumGetImageDetailOption: FppDataRequestProtocol {
    @objc public func request(completionHandler:
        @escaping (Error?, FaceAlbumGetImageDetailResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumGetImageDetailResponse)
@objcMembers public final class FaceAlbumGetImageDetailResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，否则此字段不存在。具体返回内容见后续错误信息章节。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 查询的图片标识
    public let imageId: String?
    /// 所属FaceAlbum 标识
    public let facealbumToken: String?
    /// 该图片所拥有的face_token的String
    public let faceTokens: [String]?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.requestId) {
            requestId = try container.decode(String.self, forKey: .requestId)
        } else {
            requestId = nil
        }
        if container.contains(.timeUsed) {
            timeUsed = try container.decode(Int.self, forKey: .timeUsed)
        } else {
            timeUsed = nil
        }
        if container.contains(.errorMessage) {
            errorMessage = try container.decode(String.self, forKey: .errorMessage)
        } else {
            errorMessage = nil
        }
        if container.contains(.imageId) {
            imageId = try container.decode(String.self, forKey: .imageId)
        } else {
            imageId = nil
        }
        if container.contains(.facealbumToken) {
            facealbumToken = try container.decode(String.self, forKey: .facealbumToken)
        } else {
            facealbumToken = nil
        }
        if container.contains(.faceTokens) {
            let string = try container.decode(String.self, forKey: .faceTokens)
            faceTokens = string.components(separatedBy: ",")
        } else {
            faceTokens = nil
        }
    }
}

public extension FaceAlbum {
    @discardableResult
    static func getImageDetail(option: FaceAlbumGetImageDetailOption,
                               completionHandler: @escaping (Error?, FaceAlbumGetImageDetailResponse?) -> Void)
        -> URLSessionTask? {
            return parse(option: option, completionHandler: completionHandler)
    }

    @discardableResult
    func getImageDetail(imageId: String,
                        completionHandler: @escaping (Error?, FaceAlbumGetImageDetailResponse?) -> Void) -> URLSessionTask? {
        let option = FaceAlbumGetImageDetailOption(faceAlbumToken: facealbumToken,
                                                   imageId: imageId)
        return Self.getImageDetail(option: option, completionHandler: completionHandler)
    }
}

@objc(FppFaceAblumGetAllOption)
@objcMembers public final class FaceAblumGetAllOption: NSObject, RequestProtocol {
    /// 超时时间
    public var timeoutInterval: TimeInterval = 60
    public var needCheckParams: Bool = false
    /**
     一个数字 n，表示开始返回的 faceset_token 在传入的 API Key 下的序号。 n 是 [1,9999999] 间的一个整数。
     通过传入数字 n，可以控制本 API 从第 n 个 faceset_token 开始返回。
     返回的 faceset_token 按照创建时间排序，每次返回 100 个 faceset_token。
     默认值为 1。
     您可以输入之前请求本 API 返回的 next 值，用以获得接下来的 100 个 faceset_token。
     */
    public var start: Int

    public weak var metricsReporter: FaceppMetricsReporter?

    public init(start: Int = 1) {
        self.start = start
    }

    public init(params: [String: Any]) {
        if let value = params["need_check_params"] as? Bool {
            needCheckParams = value
        } else {
            needCheckParams = false
        }
        if let value = params["timeout_interval"] as? TimeInterval {
            timeoutInterval = value
        } else {
            timeoutInterval = 60
        }
        if let value = params["start"] as? Int {
            start = value
        } else {
            start = 1
        }
    }

    var requsetURL: URL? {
        return kFaceAlbumBaseURL?.appendingPathComponent("getfacealbums")
    }

    func params() throws -> (Params, [Params]?) {
        return (["start": start], nil)
    }
}

extension FaceAblumGetAllOption: FppDataRequestProtocol {
    @objc public func request(completionHandler: @escaping (Error?, FaceAblumGetAllResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

@objc(FppFaceAblumGetAllResponse)
@objcMembers public class FaceAblumGetAllResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /**
     用于进行下一次请求。返回值表示排在此次返回的所有 facealbum_token 之后的下一个 facealbum_token 的序号。
     如果返回此字段，则说明未返回完此 API Key 下的所有 facealbum_token。
     可以将此字段的返回值，在下一次调用时传入 start 字段中，获取接下来的 facealbum_token。
     如果没有返回该字段，则说明已经返回此 API Key 下的所有 facealbum_token。
     */
    public let next: String?
    /**
     该 API Key 下的 FaceAlbum 信息。包含的元素见下文。
     注：如果该 API Key 下没有 FaceAlbum，则返回空数组
     */
    public let facealbums: [FaceAlbum]?
}

public extension FaceAlbum {
    @discardableResult
    static func getAll(option: FaceAblumGetAllOption,
                       completionHandler: @escaping (Error?, FaceAblumGetAllResponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumGetAlbumDetailOption)
@objcMembers public class FaceAlbumGetAlbumDetailOption: FaceAlbumBaseRequest {
    /// 之前请求本 API 返回的 next_token 标识，用来获取下100个 face_token。默认值为空，返回 FaceAlbum 下前100个 face_token。
    public var startToken: String?

    override var requsetURL: URL? {
        return super.requsetURL?.appendingPathComponent("getalbumdetail")
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, _) = try super.params()
        params["start_token"] = startToken
        return (params, nil)
    }
}

@objc(FppFaceAlbumFace)
@objcMembers public final class FaceAlbumFace: NSObject, Codable {
    public let faceToken: String
    public let groupId: String?
    public let imageId: String?
    public let faceRectangle: FaceppRectangle
    public let facealbumToken: String?
    public let timeUsed: Int?
}

@objc(FppFaceAlbumGetAlbumDetailResponse)
@objcMembers public final class FaceAlbumGetAlbumDetailResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，否则此字段不存在。具体返回内容见后续错误信息章节。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /**
     FaceAlbum 中人脸信息
     注：如果 FaceAlbum 没有储存人脸则返回空数组
     */
    public let faces: [FaceAlbumFace]?
    /**
     用于进行下一次请求。如果返回此字段，则在下一次调用时传入 start_token 中，获取剩余的 face_token。
     如果没有返回该字段，则代表已经返回 FaceAlbum 中的所有 face_token
     */
    public let nextToken: String?
}

extension FaceAlbumGetAlbumDetailOption: FppDataRequestProtocol {
    @objc public func request(completionHandler:
        @escaping (Error?, FaceAlbumGetAlbumDetailResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

public extension FaceAlbum {
    @discardableResult
    static func getAlbumDetail(option: FaceAlbumGetAlbumDetailOption,
                               completionHandler: @escaping (Error?, FaceAlbumGetAlbumDetailResponse?) -> Void)
        -> URLSessionTask? {
            return parse(option: option, completionHandler: completionHandler)
    }

    func getAlbumDetail(startToken: String? = nil,
                        completionHandler: @escaping (Error?, FaceAlbumGetAlbumDetailResponse?) -> Void) -> URLSessionTask? {
        let option = FaceAlbumGetAlbumDetailOption(album: self)
        option.startToken = startToken
        return Self.getAlbumDetail(option: option, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumAddImageOption)
@objcMembers public class FaceAlbumAddImageOption: FaceppBaseRequest {
    /// FaceAlbum标识
    public var facealbumToken: String

    public init(facealbumToken: String) {
        self.facealbumToken = facealbumToken
        super.init()
    }

    required public init(params: [String: Any]) {
        if let token = params["facealbum_token"] as? String {
            facealbumToken = token
        } else {
            facealbumToken = ""
        }
        super.init(params: params)
    }

    override var requsetURL: URL? {
        return kFaceAlbumBaseURL?.appendingPathComponent("addimage")
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, files) = try super.params()
        params["facealbum_token"] = facealbumToken
        return (params, files)
    }
}

extension FaceAlbumAddImageOption: FppDataRequestProtocol {
    @objc public func request(completionHandler: @escaping (Error?, FaceAlbumAddImageResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumAddImageResponse)
@objcMembers public final class FaceAlbumAddImageResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，否则此字段不存在。具体返回内容见后续错误信息章节。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /**
     检测出的人脸数组，并添加到对应FaceAlubm中
     注：如果没有检测出人脸则为空数组
     */
    public let faces: [FaceAlbumFace]?
    /// FaceAlbum标识
    public let facealbumToken: String?
}

public extension FaceAlbum {
    @discardableResult
    static func addImage(option: FaceAlbumAddImageOption,
                         completionHandler: @escaping (Error?, FaceAlbumAddImageResponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHandler)
    }

    @discardableResult
    func addImage(imageURL: URL? = nil,
                  imageFile: URL? = nil,
                  imageBase64: String? = nil,
                  completionHandler: @escaping (Error?, FaceAlbumAddImageResponse?) -> Void) -> URLSessionTask? {
        let option = FaceAlbumAddImageOption(facealbumToken: facealbumToken)
        option.imageURL = imageURL
        option.imageFile = imageFile
        option.imageBase64 = imageBase64
        return Self.addImage(option: option, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumAddImageAsyncOption)
@objcMembers public class FaceAlbumAddImageAsyncOption: FaceppBaseRequest {
    /**
     一个URL。API任务完成后会调用该url，通知用户任务完成。
     注：任务完成后，会向传入的 callback_url 发送一个 GET 请求，将 task_id 作为 querystring 中的 task_id 参数传递给用户，
     例：http://cburl?task_id=xxxxxxx
     */
    public var callbackURL: URL?

     /// FaceAlbum标识
    public var facealbumToken: String

    public init(facealbumToken: String) {
        self.facealbumToken = facealbumToken
        super.init()
    }

    required public init(params: [String: Any]) {
        if let token = params["facealbum_token"] as? String {
            facealbumToken = token
        } else {
            facealbumToken = ""
        }
        if let value = params["callback_url"] as? String {
            callbackURL = URL(string: value)
        }
        super.init(params: params)
    }

    override var requsetURL: URL? {
        return kFaceAlbumBaseURL?.appendingPathComponent("addimageasync")
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, files) = try super.params()
        params["facealbum_token"] = facealbumToken
        params["callback_url"] = callbackURL
        return (params, files)
    }
}

extension FaceAlbumAddImageAsyncOption: FppDataRequestProtocol {
    @objc public func request(completionHandler: @escaping (Error?, FaceAlbumAddImageAsyncResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumAddImageAsyncResponse)
@objcMembers public final class FaceAlbumAddImageAsyncResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，否则此字段不存在。具体返回内容见后续错误信息章节。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// FaceAlbum标识
    public let facealbumToken: String?
    /**
     标示当前异步请求的唯一task标识，之后调用任务状态查询接口时，使用当前值作为参数，如果发生错误，此字段不返回。
     注意：该task_id及其结果只会保存24小时，之后会被服务器删除。
     */
    public let taskId: String?
}

public extension FaceAlbum {
    @discardableResult
    static func addImageAsync(option: FaceAlbumAddImageAsyncOption,
                              completionHandler: @escaping (Error?, FaceAlbumAddImageAsyncResponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHandler)
    }

    @discardableResult
    func addImageAsync(imageURL: URL? = nil,
                       imageFile: URL? = nil,
                       imageBase64: String? = nil,
                       callbackURL: URL? = nil,
                       completionHandler: @escaping (Error?, FaceAlbumAddImageAsyncResponse?) -> Void) -> URLSessionTask? {
        let option = FaceAlbumAddImageAsyncOption(facealbumToken: facealbumToken)
        option.imageURL = imageURL
        option.imageFile = imageFile
        option.imageBase64 = imageBase64
        option.callbackURL = callbackURL
        return Self.addImageAsync(option: option, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumAddImageTaskQueryOption)
@objcMembers public class FaceAlbumAddImageTaskQueryOption: FaceAlbumTaskQueryBaseOption {
    override var requsetURL: URL? {
        return super.requsetURL?.appendingPathComponent("addimagetaskquery")
    }
}

extension FaceAlbumAddImageTaskQueryOption: FppDataRequestProtocol {
    @objc public func request(completionHandler:
        @escaping (Error?, FaceAlbumAddImageTaskQueryResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumAddImageTaskQueryResponse)
@objcMembers public final class FaceAlbumAddImageTaskQueryResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，否则此字段不存在。具体返回内容见后续错误信息章节。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// FaceAlbum 标识
    public let facealbumToken: String?
    /// 标示异步请求的唯一task标识
    public let taskId: String?
    /// 当前异步任务是否在进行中
    public let isCompleted: Bool?
    /// 被检测的图片在系统中的标识
    public let imageId: String?

    @objc(FppFaceAlbumAddImageTaskQueryFace)
    @objcMembers public final class Face: NSObject, Codable {
        public let faceToken: String
        public let faceRectangle: FaceppRectangle
    }
    /// 检测出的人脸数组
    public let faces: [Face]?
    /// 当异步任务失败时才会返回此字符串，否则此字段不存在。具体返回内容见后续错误信息章节。
    public let taskFailureMessage: String?

    private enum CodingKeys: String, CodingKey {
        case requestId, errorMessage, timeUsed, taskId
        case taskFailureMessage, faces, imageId, facealbumToken
        case isCompleted = "status"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.requestId) {
            requestId = try container.decode(String.self, forKey: .requestId)
        } else {
            requestId = nil
        }
        if container.contains(.errorMessage) {
            errorMessage = try container.decode(String.self, forKey: .errorMessage)
        } else {
            errorMessage = nil
        }
        if container.contains(.timeUsed) {
            timeUsed = try container.decode(Int.self, forKey: .timeUsed)
        } else {
            timeUsed = nil
        }
        if container.contains(.isCompleted) {
            let result = try container.decode(Int.self, forKey: .isCompleted)
            isCompleted = result == 1
        } else {
            isCompleted = nil
        }
        if container.contains(.taskFailureMessage) {
            taskFailureMessage = try container.decode(String.self, forKey: .taskFailureMessage)
        } else {
            taskFailureMessage = nil
        }
        if container.contains(.taskId) {
            taskId = try container.decode(String.self, forKey: .taskId)
        } else {
            taskId = nil
        }
        if container.contains(.faces) {
            faces = try container.decode([Face].self, forKey: .faces)
        } else {
            faces = nil
        }
        if container.contains(.facealbumToken) {
            facealbumToken = try container.decode(String.self, forKey: .facealbumToken)
        } else {
            facealbumToken = nil
        }
        if container.contains(.imageId) {
            imageId = try container.decode(String.self, forKey: .imageId)
        } else {
            imageId = nil
        }
    }
}

public extension FaceAlbum {
    @discardableResult
    static func addImageTaskQuery(option: FaceAlbumAddImageTaskQueryOption,
                                  completionHandler:@escaping (Error?, FaceAlbumAddImageTaskQueryResponse?) -> Void)
        -> URLSessionTask? {
            return parse(option: option, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumDeleteFaceOption)
@objcMembers public class FaceAlbumDeleteFaceOption: FaceAlbumBaseRequest {
    /// 需要移除的人脸标识字符串，至少传入一个 face_token，最多不超过10个
    public var faceTokens: [String]?
    /// 需要移除的一个图片id字符串，删除该image_id拥有的所有face_token。
    public var imageId: String?

    override var requsetURL: URL? {
        return super.requsetURL?.appendingPathComponent("deleteface")
    }

    public override init(facealbumToken: String) {
        super.init(facealbumToken: facealbumToken)
        needCheckParams = true
    }

    public required init(params: [String: Any]) {
        if let value = params["face_tokens"] as? String {
            faceTokens = value.components(separatedBy: ",")
        }
        if let value = params["image_id"] as? String {
            imageId = value
        }
        super.init(params: params)
    }

    func paramsCheck() throws -> Bool {
        guard needCheckParams else {
            return true
        }
        if let count = faceTokens?.count {
            guard count >= 1 && count <= 10 else {
                throw FaceppRequestError.argumentsError(.invalidArguments(desc: "faceToken数量应为[1,10]"))
            }
            return true
        }
        return imageId != nil
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, _) = try super.params()
        params["face_tokens"] = faceTokens?.joined(separator: ",")
        params["Image_id"] = imageId
        return (params, nil)
    }
}

extension FaceAlbumDeleteFaceOption: FppDataRequestProtocol {
    @objc public func request(completionHandler: @escaping (Error?, FaceAlbumDeleteFaceResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumDeleteFaceResponse)
@objcMembers public final class FaceAlbumDeleteFaceResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，否则此字段不存在。具体返回内容见后续错误信息章节。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 成功从 FaceAlbum 中移除的 face_token 数量
    public let faceRemovedCount: Int?
    /**
     一个 face_token 的数组，包括所有成功移除的face_token
     */
    public let faceRemovedDetail: [String]?

    @objc(FppFaceAlbumDeleteFaceReason)
    @objcMembers public final class Reason: NSObject, Codable {
        /// 人脸标识
        public let faceToken: String
        /// 不能被移除的原因
        public let reason: String
    }
    /// 无法从 FaceAlbum 中移除的 face_token 以及原因
    public let faceFailureDetail: [String]?
}

public extension FaceAlbum {
    @discardableResult
    static func deleteFace(option: FaceAlbumDeleteFaceOption,
                           completionHandler:@escaping (Error?, FaceAlbumDeleteFaceResponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHandler)
    }

    @discardableResult
    func deleteFace(faceTokens: [String]? = nil,
                    imageId: String? = nil,
                    completionHandler:@escaping (Error?, FaceAlbumDeleteFaceResponse?) -> Void) -> URLSessionTask? {
        let option = FaceAlbumDeleteFaceOption(album: self)
        option.faceTokens = faceTokens
        option.imageId = imageId
        return Self.parse(option: option, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumGroupFaceOption)
@objcMembers public class FaceAlbumGroupFaceOption: FaceAlbumBaseRequest {
    public enum OperationType: String {
        /// 增量操作
        case incremental
        /// 全量操作
        case entirefacealbum
    }
    /// 人脸分组操作类型
    @nonobjc public var operationType = OperationType.incremental

    public var operationTypeString: String {
        set {
            operationType = OperationType(rawValue: newValue) ?? .incremental
        }
        get {
            operationType.rawValue
        }
    }
    /**
     一个URL。API任务完成后会调用该url，通知用户任务完成。
     注：任务完成后，会向传入的 callback_url 发送一个 GET 请求，将 task_id 作为 querystring 中的 task_id 参数传递给用户，
     例：http://cburl?task_id=xxxxxxx
     */
    public var callbackURL: URL?

    override var requsetURL: URL? {
        return super.requsetURL?.appendingPathComponent("groupface")
    }

    public required init(params: [String: Any]) {
        if let value = params["operation_type"] as? String {
            operationType = OperationType(rawValue: value) ?? .incremental
        } else {
            operationType = .incremental
        }
        if let value = params["callback_url"] as? String {
            callbackURL = URL(string: value)
        }
        super.init(params: params)
    }

    public override init(facealbumToken: String) {
        super.init(facealbumToken: facealbumToken)
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, _) = try super.params()
        params["operation_type"] = operationType.rawValue
        params["callback_url"] = callbackURL
        return (params, nil)
    }
}

extension FaceAlbumGroupFaceOption: FppDataRequestProtocol {
    @objc public func request(completionHandler: @escaping (Error?, FaceAlbumGroupFaceResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumGroupFaceResponse)
@objcMembers public final class FaceAlbumGroupFaceResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，否则此字段不存在。具体返回内容见后续错误信息章节。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// FaceAlbum 标识
    public let facealbumToken: String?
    /**
     标示当前异步请求的唯一task标识，之后调用任务状态查询接口时，使用当前值作为参数，如果发生错误，此字段不返回。
     注意：该task_id及其结果只会保存24小时，之后会被服务器删除。
     */
    public let taskId: String?
}

public extension FaceAlbum {
    @discardableResult
    static func groupFace(option: FaceAlbumGroupFaceOption,
                          completionHandler:@escaping (Error?, FaceAlbumGroupFaceResponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHandler)
    }

    func groupFace(operationType: FaceAlbumGroupFaceOption.OperationType = .incremental,
                   callbackURL: URL? = nil,
                   completionHandler:@escaping (Error?, FaceAlbumGroupFaceResponse?) -> Void) -> URLSessionTask? {
        let option = FaceAlbumGroupFaceOption(album: self)
        option.operationType = operationType
        option.callbackURL = callbackURL
        return Self.parse(option: option, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumGroupFaceTaskQueryOption)
public class FaceAlbumGroupFaceTaskQueryOption: FaceAlbumTaskQueryBaseOption {
    override var requsetURL: URL? {
        return super.requsetURL?.appendingPathComponent("groupfacetaskquery")
    }
}

extension FaceAlbumGroupFaceTaskQueryOption: FppDataRequestProtocol {
    @objc public func request(completionHandler:
        @escaping (Error?, FaceAlbumGroupFaceTaskQueryResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

@objc(FppFaceAlbumGroupFaceTaskQueryResponse)
@objcMembers public final class FaceAlbumGroupFaceTaskQueryResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，否则此字段不存在。具体返回内容见后续错误信息章节。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 标示异步请求的唯一task标识
    public let taskId: String?
    /// 当异步任务失败时才会返回此字符串，否则此字段不存在。具体返回内容见后续错误信息章节。
    public let taskFailureMessage: String?
    /// 当前异步任务是否还在进行中
    public let isCompleted: Bool?
    /// FaceAlbum 标识
    public let facealbumToken: String?

    @objc(FppFaceAlbumGroupResult)
    @objcMembers public final class GroupResult: NSObject, Codable {
        /// 分组信息
        public let groupId: String
        /// 人脸的标识
        public let faceToken: String
        /// 人脸未被分组的原因。只有当该人脸的 group_id = 0 时，才会返回此字段。否则不返回
        public let ungroupedReason: FaceAlbumUngroupedReason?
    }
    /// 人脸分组结果，当任务还在进行中时，不返回该字符串
    public let groupResult: [GroupResult]?

    private enum CodingKeys: String, CodingKey {
        case requestId, errorMessage, timeUsed, taskId
        case taskFailureMessage, groupResult, facealbumToken
        case isCompleted = "status"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.requestId) {
            requestId = try container.decode(String.self, forKey: .requestId)
        } else {
            requestId = nil
        }
        if container.contains(.errorMessage) {
            errorMessage = try container.decode(String.self, forKey: .errorMessage)
        } else {
            errorMessage = nil
        }
        if container.contains(.timeUsed) {
            timeUsed = try container.decode(Int.self, forKey: .timeUsed)
        } else {
            timeUsed = nil
        }
        if container.contains(.isCompleted) {
            let result = try container.decode(Int.self, forKey: .isCompleted)
            isCompleted = result == 1
        } else {
            isCompleted = nil
        }
        if container.contains(.taskFailureMessage) {
            taskFailureMessage = try container.decode(String.self, forKey: .taskFailureMessage)
        } else {
            taskFailureMessage = nil
        }
        if container.contains(.taskId) {
            taskId = try container.decode(String.self, forKey: .taskId)
        } else {
            taskId = nil
        }
        if container.contains(.facealbumToken) {
            facealbumToken = try container.decode(String.self, forKey: .facealbumToken)
        } else {
            facealbumToken = nil
        }
        if container.contains(.groupResult) {
            groupResult = try container.decode([GroupResult].self, forKey: .groupResult)
        } else {
            groupResult = nil
        }
    }
}

public extension FaceAlbum {
    @discardableResult
    static func groupFaceTaskQuery(option: FaceAlbumGroupFaceTaskQueryOption,
                                   completionHandler:@escaping (Error?, FaceAlbumGroupFaceTaskQueryResponse?) -> Void)
        -> URLSessionTask? {
            return parse(option: option, completionHandler: completionHandler)
    }
}
