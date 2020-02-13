//
//  Imagepp.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/12.
//

import Foundation

public enum FaceppHumanBody: UseFaceppClientProtocol {
    case detect(option: HumanBodyDetectOption, handler: (Error?, HumanBodyDetectResponse?) -> Void)

    @discardableResult
    public func request() -> URLSessionTask? {
        switch self {
        case .detect(let option, let handler):
           return Self.parse(option: option, completionHandler: handler)
        }
    }
}
