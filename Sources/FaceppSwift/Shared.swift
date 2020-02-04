//
//  Shared.swift
//  facepp
//
//  Created by 姜振华 on 2020/2/3.
//

import Foundation

let kFaceppBaseURL = URL(string: "https://api-cn.faceplusplus.com/facepp/v3")

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
    case NoPic
    case FaceppError(String)
}
