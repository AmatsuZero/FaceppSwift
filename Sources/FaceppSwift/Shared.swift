//
//  Shared.swift
//  facepp
//
//  Created by 姜振华 on 2020/2/3.
//

import Foundation

let kBaseURL = URL(string: "https://api-cn.faceplusplus.com/facepp")
let kFaceappV1BaseURL = kBaseURL?.appendingPathComponent("v1")
let kFaceppV3BaseURL = kBaseURL?.appendingPathComponent("v3")

protocol ResponseProtocol: Codable {
    // 用于区分每一次请求的唯一的字符串。
    var requestId: String? { get }
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    var errorMessage: String? { get }
    /// 整个请求所花费的时间，单位为毫秒。
    var timeUsed: Int? { get }
}

protocol RequestProtocol {
    var requsetURL: URL? { get }
    func paramsCheck() -> Bool
    func params(apiKey: String, apiSecret: String) -> (Params, [Params]?)
    func asRequest(apiKey: String, apiSecret: String) -> (URLRequest?, Data?)
}

extension RequestProtocol {
    func paramsCheck() -> Bool {
        return true
    }
    
    func asRequest(apiKey: String, apiSecret: String) -> (URLRequest?, Data?) {
        guard let url = requsetURL, paramsCheck() else {
            return (nil, nil)
        }
        let (params, files) = self.params(apiKey: apiKey, apiSecret: apiSecret)
        return URLRequest.postRequest(url: url, body: params, filesData: files ?? [])
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
            if let data = "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fieldName)\"\r\n".data(using: .utf8) {
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

public protocol Option: RawRepresentable, Hashable, CaseIterable {}

extension FaceRectangle: CustomStringConvertible {
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
    public class func once(token: String = UUID().uuidString, block: ()-> Void) {
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

public enum RequestError: Error {
    case NotInit
    case MissingArguments
    case FaceppError(String)
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
    static func postRequest(url:URL,  body:Params, filesData: [Params] = []) -> (URLRequest?, Data?) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=boundary", forHTTPHeaderField: "Content-Type")
        return (request, kBodyDataWithParams(params: body, fileData: filesData))
    }
}

public struct FacialThreshHolds: Codable {
    /// 误识率为千分之一的置信度阈值
    public let lowPrecision: Float
    /// 误识率为万分之一的置信度阈值
    public let middlePrecision: Float
    /// 误识率为十万分之一的置信度阈值
    public let hightPrecision: Float
    
    enum CodingKeys: String, CodingKey {
        case lowPrecision = "1e-3"
        case middlePrecision = "1e-4"
        case hightPrecision = "1e-5"
    }
}

public struct FacialHeadPose: Codable {
    /// 抬头
    public let pitchAngle: Double
    /// 旋转（平面旋转）
    public let rollAngle: Double
    /// 摇头
    public let yawAngle: Double
}
