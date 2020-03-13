//
//  Shared.swift
//  facepp
//
//  Created by 姜振华 on 2020/2/3.
//

import Foundation

let kBaseURL = URL(string: "https://api-cn.faceplusplus.com")

let kBaseFaceppURL: URL? = {
    return kBaseURL?.appendingPathComponent("facepp")
}()

let kBaseCardppURL: URL? = {
    return kBaseURL?.appendingPathComponent("cardpp")
}()

let kFaceappV1URL: URL? = {
    return kBaseFaceppURL?.appendingPathComponent("v1")
}()

let kFaceappV2URL: URL? = {
    return kBaseFaceppURL?.appendingPathComponent("v2")
}()

let kFaceppV3URL: URL? = {
    return kBaseFaceppURL?.appendingPathComponent("v3")
}()

let kCardppV1URL: URL? = {
    return kBaseCardppURL?.appendingPathComponent("v1")
}()

let kCardppV2URL: URL? = {
    return kBaseCardppURL?.appendingPathComponent("v2")
}()

let kCardppBetaURL: URL? = {
    return kBaseCardppURL?.appendingPathComponent("beta")
}()

let kHumanBodyBaseURL: URL? = {
    return kBaseURL?.appendingPathComponent("humanbodypp")
}()

let kHumanBodyV1URL: URL? = {
    return kHumanBodyBaseURL?.appendingPathComponent("v1")
}()

let kHumanBodyV2URL: URL? = {
    return kHumanBodyBaseURL?.appendingPathComponent("v2")
}()

let kImageppBaseURL: URL? = {
    return kBaseURL?.appendingPathComponent("imagepp")
}()

let kImageppV1URL: URL? = {
    return kImageppBaseURL?.appendingPathComponent("v1")
}()

let kImageppBetaURL: URL? = {
    return kImageppBaseURL?.appendingPathComponent("beta")
}()

public protocol FaceppResponseBaseProtocol {
    // 用于区分每一次请求的唯一的字符串。
    var requestId: String? { get }
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    var errorMessage: String? { get }
    /// 整个请求所花费的时间，单位为毫秒。
    var timeUsed: Int? { get }
}

public protocol FaceppResponseProtocol: FaceppResponseBaseProtocol, Codable, Hashable {
    /// Decoder
    static func getDecoder() -> JSONDecoder
    /// Encoder
    static func getEncoder() -> JSONEncoder
}

public extension FaceppResponseProtocol {

    static func getEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }

    static func getDecoder() -> JSONDecoder {
        return FaceppClient.getDecoder()
    }

    /// 归档
    /// - Parameters:
    ///   - resp: 要保存的对象
    ///   - url: 保存路径
    static func archive(_ resp: Self, at url: URL) throws {
        let encoder = getEncoder()
        let data = try encoder.encode(resp)
        try data.write(to: url)
    }

    /// 归档
    /// - Parameter url: 保存路径
    func archive(at url: URL) throws {
        try Self.archive(self, at: url)
    }

    /// 解档
    /// - Parameter url: 归档文件路径
    static func unarchinve(at url: URL) throws -> Self {
        let data = try Data(contentsOf: url)
        let decoder = getDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}

typealias Params = [String: Any]

func kBodyDataWithParams(params: Params, fileData: [Params]) -> Data {
    var bodyData = Data()

    params.forEach { (key: String, obj: Any) in
        bodyData += Data.boundaryData

        if let data = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8) {
            bodyData += data
        }

        if let data = "\(obj)\r\n".data(using: .utf8) {
            bodyData += data
        }
    }

    fileData.forEach { dic in
        if let fieldName = dic["fieldName"] as? String,
            let fileData = dic["data"] as? Data,
            let fileType = dic["fileType"] as? String {
            bodyData += Data.boundaryData
            if let data = "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fieldName)\"\r\n"
                .data(using: .utf8) {
                bodyData += data
            }
            if let data = "Content-Type: \(fileType)\r\n\r\n".data(using: .utf8) {
                bodyData += data
            }
            bodyData += fileData
            if let data = "\r\n".data(using: .utf8) {
                bodyData += data
            }
        }
    }

    if let data = "--boundary--\r\n".data(using: .utf8) {
        bodyData += data
    }

    return bodyData
}

protocol Option: RawRepresentable, Hashable, CaseIterable {}

extension FaceppRectangle: CustomStringConvertible {
    public var description: String {
        return "\(top),\(left),\(width),\(height)"
    }
}

extension Data {
    static var boundaryData: Data {
        return "--boundary\r\n".data(using: .utf8)!
    }
}

extension DispatchQueue {
    private static var _onceTracker = [String]()
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    class func once(token: String = UUID().uuidString, block: () -> Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }

        if _onceTracker.contains(token) {
            return
        }

        _onceTracker.append(token)
        block()
    }
}

extension Set where Element: Option {
    var rawValue: Int {
        var rawValue = 0
        for (index, element) in Element.allCases.enumerated() {
            if self.contains(element) {
                rawValue |= (1 << index)
            }
        }
        return rawValue
    }
}

public enum FaceppRequestError: CustomNSError, LocalizedError {
    public enum ArgumentsError {
        case fileTooLarge(size: Double, path: URL)
        case missingArguments
        case invalidArguments(desc: String)
    }

    case notInit
    case argumentsError(ArgumentsError)
    case faceppError(reason: String)
    case parseError(error: Error, originalData: Data?)

    public static var errorDomain: String {
        return "com.daubert.faceapp"
    }

    public var errorDescription: String? {
        switch self {
        case .notInit:
            return "没有初始化"
        case .argumentsError(let err):
            switch err {
            case .missingArguments:
                return "缺少参数"
            case .invalidArguments(let desc):
                return desc
            case .fileTooLarge(let size, let path):
                return "文件\(path)超过\(size)MB"
            }
        case .faceppError(let reason):
            return "服务器错误：\(reason)"
        case .parseError(let error, _):
            return "数据解析失败: \(error)"
        }
    }

    public var failureReason: String? {
        switch self {
        case .notInit:
            return "没有初始化"
        case .argumentsError:
            return "参数检查失败"
        case .faceppError(let reason):
            return reason
        case .parseError(let error, _):
            return "数据解析失败: \(error.localizedDescription)"
        }
    }

    public var helpAnchor: String? {
        switch self {
        case .notInit: return "请重新调用初始化方法"
        case .argumentsError: return "请根据文档检查入参"
        case .faceppError(let reason): return "请根据 Wiki 排查失败原因：\(reason)"
        case .parseError:
            return "数据解析失败，可能是数据结构发生了变化，请尝试用originalData进行解析"
        }
    }

    public var errorCode: Int {
        switch self {
        case .notInit: return -100001
        case .argumentsError: return -100002
        case .faceppError: return -100003
        case .parseError: return -100004
        }
    }

    public var errorUserInfo: [String: Any] {
        return [
            NSLocalizedDescriptionKey: errorDescription ?? "Unknown"
        ]
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

extension URLRequest {
    static func postRequest(url: URL, body: Params, filesData: [Params] = []) -> (URLRequest?, Data?) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=boundary", forHTTPHeaderField: "Content-Type")
        return (request, kBodyDataWithParams(params: body, fileData: filesData))
    }
}

public struct FacialThreshHolds: Codable, Hashable {
    /// 误识率为千分之一的置信度阈值
    public let lowPrecision: Float
    /// 误识率为万分之一的置信度阈值
    public let middlePrecision: Float
    /// 误识率为十万分之一的置信度阈值
    public let hightPrecision: Float

    private enum CodingKeys: String, CodingKey {
        case lowPrecision = "1e-3"
        case middlePrecision = "1e-4"
        case hightPrecision = "1e-5"
    }
}

public struct FacialHeadPose: Codable, Hashable {
    /// 抬头
    public let pitchAngle: Double
    /// 旋转（平面旋转）
    public let rollAngle: Double
    /// 摇头
    public let yawAngle: Double
}

public enum OCRType: Int, Codable {
    /// 身份证
    case idCard = 1
    /// 驾驶证
    case driverLicense
    /// 行驶证
    case vehicleLicense
}

protocol UseFaceppClientProtocol {
    static func parse<R: FaceppResponseProtocol>(option: RequestProtocol,
                                                 completionHandler: @escaping (Error?, R?) -> Void) -> URLSessionTask?
    func request() -> URLSessionTask?
}

extension UseFaceppClientProtocol {
    func request() -> URLSessionTask? {
        return nil
    }

    static func parse<R: FaceppResponseProtocol>(option: RequestProtocol,
                                                 completionHandler: @escaping (Error?, R?) -> Void) -> URLSessionTask? {
        guard let client = FaceppClient.shared else {
            completionHandler(FaceppRequestError.notInit, nil)
            return nil
        }
        return client.parse(option: option, completionHandler: completionHandler)
    }
}

extension URL {
    func fileSizeNotExceed(mb: Double) throws -> Bool {
        guard let fileSize = try resourceValues(forKeys: [.fileSizeKey]).fileSize else {
            return false
        }
        return (Double(fileSize) / 1024 / 1024) <= mb
    }
}

public struct FaceppBound: Codable, Hashable {
    /// 右上角的像素点坐标
    public let rightTop: FaceppPoint
    /// 左上角的像素点坐标
    public let leftTop: FaceppPoint
    /// 右下角的像素点坐标
    public let rightBottom: FaceppPoint
    /// 左下角的像素点坐标
    public let leftBottom: FaceppPoint
}

public extension FaceppBound {
    func asFaceppRectangle() -> FaceppRectangle {
        return FaceppRectangle(top: Int(leftTop.y),
                               left: Int(leftTop.x),
                               width: Int(abs(rightTop.x - leftTop.x)) ,
                               height: Int(abs(rightBottom.y - rightTop.y)))
    }
}
