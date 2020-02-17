//
//  Imagepp.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/13.
//

import Foundation

public enum Imagepp: UseFaceppClientProtocol {
    case licensePlate(option: ImageppLicensePlateOption,
        handler: (Error?, ImageppLicensePlateResponse?) -> Void)
    case mergeFace(option: ImageppMergeFaceOption,
        handler: (Error?, ImageppMergeFaceResponse?) -> Void)
    case recognizeText(option: ImageppRecognizeTextOption,
        handler: (Error?, ImagepprecognizeTextResponse?) -> Void)
    case detectsceneandobject(option: ImageppDetectScenceAndObjectOption,
        handler: (Error?, ImageppDetectScenceAndObjectResponse?) -> Void)

    @discardableResult
    public func request() -> URLSessionTask? {
        switch self {
        case .licensePlate(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .mergeFace(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .recognizeText(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .detectsceneandobject(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        }
    }
}
