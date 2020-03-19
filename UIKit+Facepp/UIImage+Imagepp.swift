//
//  UIImage+Imagepp.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/3/13.
//

import UIKit

public extension UIImage {
    @discardableResult
    func licensePlate(completionHandler: ((Error?, ImageppLicensePlateResponse?) -> Void)?) -> URLSessionTask? {
        let option = ImageppLicensePlateOption(image: self)
        let task = Imagepp.licensePlate(option: option) { error, resp in
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
    func merge(with image: UIImage,
               templateRectangle rect1: CGRect? = nil,
               mergeRectangle rect2: CGRect? = nil,
               mergeRate: UInt = 50,
               featureRate: UInt = 45,
               completionHandler: ((Error?, ImageppMergeFaceResponse?) -> Void)?) -> URLSessionTask? {
        var option = ImageppMergeFaceOption()
        option.templateBase64 = base64String()
        option.templateRectangle = rect1?.asFaceppRectangle()
        option.mergeBase64 = image.base64String()
        option.mergeRectangle = rect2?.asFaceppRectangle()
        option.featureRate = featureRate
        option.mergeRate = mergeRate
        let task = Imagepp.mergeFace(option: option) { error, resp in
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
    func merge(templateImage image1: UIImage,
               templateRectangle rect1: CGRect? = nil,
               mergeImage image2: UIImage,
               mergeRectangle rect2: CGRect? = nil,
               featureRate: UInt = 45,
               mergeRate: UInt = 50,
               completionHandler: ((Error?, ImageppMergeFaceResponse?) -> Void)? = nil) -> URLSessionTask? {
        return image1.merge(with: image2, templateRectangle: rect1, mergeRectangle: rect2,
                            mergeRate: mergeRate, featureRate: featureRate, completionHandler: completionHandler)
    }

    @discardableResult
    func recognizeText(completionHandler: ((Error?, ImagepprecognizeTextResponse?) -> Void)?) -> URLSessionTask? {
        let option = ImageppRecognizeTextOption(image: self)
        let task = Imagepp.recognizeText(option: option) { error, resp in
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
    func detectSceneandObject(completionHandler: ((Error?, ImageppDetectScenceAndObjectResponse?) -> Void)?) -> URLSessionTask? {
        let option = ImageppDetectScenceAndObjectOption(image: self)
        let task = Imagepp.detectsceneandobject(option: option) { error, resp in
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
