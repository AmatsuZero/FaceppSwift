//
//  Imagepp.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/12.
//

import Foundation
#if os(Linux)
import FoundationNetworking
#endif

public enum FaceppHumanBody: UseFaceppClientProtocol {
    case bodyDetect(option: HumanBodyDetectOption,
        handler: (Error?, HumanBodyDetectResponse?) -> Void)
    case skeleton(option: SkeletonDetectOption,
        handler: (Error?, SkeletonDetectResponse?) -> Void)
    case segmentV1(option: HumanBodySegmentV1Option,
        handler: (Error?, HumanBodySegmentResponse?) -> Void)
    case segmentV2(option: HumanBodySegmentV2Option,
        handler: (Error?, HumanBodySegmentResponse?) -> Void)
    case gesture(option: HumanBodyGestureOption,
        handler: (Error?, HumanBodyGestureResponse?) -> Void)

    @discardableResult
    public func request() -> URLSessionTask? {
        switch self {
        case .bodyDetect(let option, let handler):
           return Self.parse(option: option, completionHandler: handler)
        case .skeleton(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .segmentV1(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .segmentV2(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .gesture(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        }
    }
}
