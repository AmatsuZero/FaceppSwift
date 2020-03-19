//
//  UIImage+Humanbody.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/3/13.
//

import UIKit

public extension UIImage {
    @discardableResult
    func detectBody(attributes: Set<HumanBodyDetectOption.ReturnAttributes> = [.none],
                    completionHandler: ((Error?, HumanBodyDetectResponse?) -> Void)? = nil) -> URLSessionTask? {
        let option = HumanBodyDetectOption(image: self)
        option.returnAttributes = attributes
        let task = FaceppHumanBody.bodyDetect(option: option) { error, resp in
            guard let block = completionHandler else {
                self.fppDelegate?.image(self, taskDidEndWithEror: error, response: resp)
                return
            }
            block(error, resp)
        }.request()
        fppDelegate?.image(self, option: option, taskDidBeigin: task)
        return task
    }

    @discardableResult
    func skeleton(completionHandler: ((Error?, SkeletonDetectResponse?) -> Void)? = nil) -> URLSessionTask? {
        let option = SkeletonDetectOption(image: self)
        let task = FaceppHumanBody.skeleton(option: option) { error, resp in
            guard let block = completionHandler else {
                self.fppDelegate?.image(self, taskDidEndWithEror: error, response: resp)
                return
            }
            block(error, resp)
        }.request()
        fppDelegate?.image(self, option: option, taskDidBeigin: task)
        return task
    }

    @discardableResult
    func gesture(returnGesture: Bool = true,
                 completionHandler: ((Error?, HumanBodyGestureResponse?) -> Void)? = nil) -> URLSessionTask? {
        let option = HumanBodyGestureOption(image: self)
        option.returnGesture = returnGesture
        let task = FaceppHumanBody.gesture(option: option) { error, resp in
            guard let block = completionHandler else {
                self.fppDelegate?.image(self, taskDidEndWithEror: error, response: resp)
                return
            }
            block(error, resp)
        }.request()
        fppDelegate?.image(self, option: option, taskDidBeigin: task)
        return task
    }

    @discardableResult
    func segmentV1(completionHandler: ((Error?, HumanBodySegmentResponse?) -> Void)? = nil) -> URLSessionTask? {
        let option = HumanBodySegmentV1Option(image: self)
        let task = FaceppHumanBody.segmentV1(option: option) { error, resp in
            guard let block = completionHandler else {
                self.fppDelegate?.image(self, taskDidEndWithEror: error, response: resp)
                return
            }
            block(error, resp)
        }.request()
        fppDelegate?.image(self, option: option, taskDidBeigin: task)
        return task
    }

    @discardableResult
    func segmentV2(returnGrayScale: HumanBodySegmentV2Option.ReturnGrayScale = .grayScaleAndFigure,
                   completionHandler: ((Error?, HumanBodySegmentResponse?) -> Void)? = nil) -> URLSessionTask? {
        let option = HumanBodySegmentV2Option(image: self)
        option.returnGrayScale = returnGrayScale
        let task = FaceppHumanBody.segmentV2(option: option) { error, resp in
            guard let block = completionHandler else {
                self.fppDelegate?.image(self, taskDidEndWithEror: error, response: resp)
                return
            }
            block(error, resp)
        }.request()
        fppDelegate?.image(self, option: option, taskDidBeigin: task)
        return task
    }
}
