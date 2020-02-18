//
//  FaceAlbum.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/17.
//  Wiki: https://console.faceplusplus.com.cn/documents/51345189
//

import Foundation

let kFaceAlbumBaseURL: URL? = {
    return kImageppV1URL?.appendingPathComponent("facealbum")
}()

public struct FaceAlbum: Codable, UseFaceppClientProtocol {
    /// faceAlbum 的标识
    public let facealbumToken: String
}

public class FaceAlbumBaseRequest: RequestProtocol {
    /// 是否检查参数
    public var needCheckParams: Bool

    /// FaceAlbum 标识
    public var facealbumToken: String

    public init(facealbumToken: String) {
        self.facealbumToken = facealbumToken
        needCheckParams = false
    }

    public convenience init(album: FaceAlbum) {
        self.init(facealbumToken: album.facealbumToken)
    }

    var requsetURL: URL? {
        return kFaceAlbumBaseURL
    }

    func params(apiKey: String, apiSecret: String) throws -> (Params, [Params]?) {
        return ([
            "api_key": apiKey,
            "api_secret": apiSecret,
            "facealbum_token": facealbumToken
        ], nil)
    }
}
/**
 创建一个人脸相册 FaceAlbum，用于存储相片的image_id、相片中人脸标识face_token、以及人脸标识对应的聚类分组group_id。一个FaceAlbum能够存储10000个face_token。
 注意：免费用户可最多创建10个FaceAlbum，而付费用户没有相册数量限制。免费用户的相册自创建后会保存100天，然后会被删除。
 如果付费用户透支账户余额后，创建的FaceAlbum会保留30天，然后被删除。
 */
public struct CreateFaceAlbumOption: RequestProtocol {
    var needCheckParams: Bool = false

    var requsetURL: URL? {
        return kFaceAlbumBaseURL?.appendingPathComponent("createalbum")
    }

    func params(apiKey: String, apiSecret: String) throws -> (Params, [Params]?) {
        return ([
            "api_key": apiKey,
            "api_secret": apiSecret
        ], nil)
    }
}

public struct FaceAlbumBaseReeponse: ResponseProtocol {
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
    static func create(completionHandler: @escaping (Error?, FaceAlbumBaseReeponse?) -> Void) -> URLSessionTask? {
        return parse(option: CreateFaceAlbumOption(), completionHandler: completionHandler)
    }

    @discardableResult
    static func createAlbum(completionHandler: @escaping (Error?, FaceAlbum?) -> Void) -> URLSessionTask? {
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
public class FaceAlbumDeleteOption: FaceAlbumBaseRequest {
    /// 删除时是否检查 FaceAlbum 中是否存在 face_token
    public var checkEmpty = false

    override func params(apiKey: String, apiSecret: String) throws -> (Params, [Params]?) {
        var (params, _) = try super.params(apiKey: apiKey, apiSecret: apiSecret)
        params["check_empty"] = checkEmpty ? 1 : 0
        return (params, nil)
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
        return FaceAlbum.delete(option: option, completionHandler: completionHandler)
    }
}

/// 查找与某一分组相似的分组，用于在同一个人的人脸被分为多个组的情况下，提示用户确认两个分组的人脸是否属于同一个人。
public class FaceAlbumFindCandidateOption: FaceAlbumBaseRequest {
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

    override func params(apiKey: String, apiSecret: String) throws -> (Params, [Params]?) {
        var (params, _) = try super.params(apiKey: apiKey, apiSecret: apiSecret)
        params["group_id"] = groupId
        return (params, nil)
    }
}

public struct FaceAlbumFindCandidateResponse: ResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，否则此字段不存在。具体返回内容见后续错误信息章节。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 创建的 FaceAlbum 的标识。
    public let facealbumToken: String?

    public struct CandidateGroup: Codable {
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

public class FaceAlbumFindSearchImageOption: FaceppBaseRequest {
    /// FaceAlbum标识
    public var facealbumToken: String
    /**
     一个URL。API任务完成后会调用该url，通知用户任务完成。
     注：任务完成后，会向传入的 callback_url 发送一个 GET 请求，将 task_id 作为 querystring 中的 task_id 参数传递给用户.
     例：http://cburl?task_id=xxxxxxx
     */
    public var callbackURL: URL?

    public init(token: String) {
        self.facealbumToken = token
        super.init()
    }

    public convenience init(album: FaceAlbum) {
        self.init(token: album.facealbumToken)
    }

    override var requsetURL: URL? {
        return kFaceAlbumBaseURL?.appendingPathComponent("searchimage")
    }

    override func params(apiKey: String, apiSecret: String) throws -> (Params, [Params]?) {
        var (params, files) = try super.params(apiKey: apiKey, apiSecret: apiSecret)
        params["facealbum_token"] = facealbumToken
        params["callback_url"] = callbackURL
        return (params, files)
    }
}

public struct FaceAlbumSearchImageResponse: ResponseProtocol {
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
    static func searchImage(option: FaceAlbumFindSearchImageOption,
                            completionHandler:@escaping (Error?, FaceAlbumSearchImageResponse?) -> Void) -> URLSessionTask? {
        return parse(option: option, completionHandler: completionHandler)
    }
}

public struct FaceAlbumSearchImageTaskQueryOption: RequestProtocol {
    /// 异步任务的唯一标识
    public let taskId: String

    var needCheckParams: Bool = false

    var requsetURL: URL? {
        return kFaceAlbumBaseURL?.appendingPathComponent("searchimagetaskquery")
    }

    func params(apiKey: String, apiSecret: String) throws -> (Params, [Params]?) {
        return ([
            "api_key": apiKey,
            "api_secret": apiSecret,
            "task_id": taskId
        ], nil)
    }
}

public struct FaceAlbumSearchImageTaskQueryResponse: ResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，否则此字段不存在。具体返回内容见后续错误信息章节。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 标示异步请求的唯一task标识
    public let taskId: String?
    /// 是否完成
    public let status: Bool?

    public struct SearchResult: Codable {
        /// 该face在提供图片中的位置
        public let faceRectangle: FaceppRectangle
        /// 相册中拥有该相同face的相片image_id的String, 多个用逗号分隔
        public let imageIdSet: Set<String>

        public init(from decoder: Decoder) throws {
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
        requestId = try container.decode(String.self, forKey: .requestId)
        errorMessage = try container.decode(String.self, forKey: .errorMessage)
        timeUsed = try container.decode(Int.self, forKey: .timeUsed)
        if container.contains(.status) {
            let result = try container.decode(Int.self, forKey: .status)
            status = result == 1
        } else {
            status = nil
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
    }
}

public class FaceAlbumUpdateFaceOption: FaceAlbumBaseRequest {
    /// 由人脸标识 face_token 组成的字符串。至少传入一个 face_token，最多不超过10个
    public var faceTokens: [String]
    /**
     人脸的新的分组信息。可以传入三类值：
     如果传入一个已经存在的 group_id，则人脸会被分到相应的组中。
     如果传入“CreateNewGroup”，则会为传入人脸创建一个新的分组，并返回新的 group_id。
     如果传入 -1，则人脸会被置为“未分组”状态。
     */
    public var newGroupId: String

    public init(faceTokens: [String], newGroupId: String, faceAlbumToken: String) {
        self.faceTokens = faceTokens
        self.newGroupId = newGroupId
        super.init(facealbumToken: faceAlbumToken)
        needCheckParams = true
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

    override func params(apiKey: String, apiSecret: String) throws -> (Params, [Params]?) {
        var (params, _) = try super.params(apiKey: apiKey, apiSecret: apiSecret)
        params["face_tokens"] = faceTokens.joined(separator: ",")
        params["new_group_id"] = newGroupId
        return (params, nil)
    }
}

public struct FaceAlbumUpdateFaceResponse: ResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，否则此字段不存在。具体返回内容见后续错误信息章节。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?

    public struct FailureDetail: Codable {
        /// 人脸标识
        public let faceToken: String
        /// 不能被更新的原因，包括 INVALID_FACE_TOKEN 人脸标识不存在
        public let reason: String
    }
    /// 无法更新 group_id 的 face_token 以及原因
    public let failureDetail: [FailureDetail]?
}

public extension FaceAlbum {

}
