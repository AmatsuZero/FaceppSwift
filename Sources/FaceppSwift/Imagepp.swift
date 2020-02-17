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
    
    @discardableResult
    public func request() -> URLSessionTask? {
        switch self {
        case .licensePlate(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .mergeFace(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        }
    }
}
