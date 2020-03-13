//
//  UIImage+Cardpp.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/3/13.
//

import UIKit

public extension UIImage {
    @discardableResult
    func idcard(needLegality: Bool = false,
                completionHandler: ((Error?, OCRIDCardResponse?) -> Void)? = nil) -> URLSessionTask? {
        let option = OCRIDCardOption(image: self)
        option.needLegality = needLegality
        let task = Cardpp.idCard(option: option) { error, resp in
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
    func driverLicenseV2(needReturnScore: Bool = false,
                         mode: OCRDriverLicenseV2Option.Mode = .fast,
                         completionHandler: ( (Error?, OCRDriverLicenseV2Response?) -> Void)? = nil) -> URLSessionTask? {
        let option = OCRDriverLicenseV2Option(image: self)
        option.needReturnScore = needReturnScore
        option.mode = mode
        let task = Cardpp.driverLicenseV2(option: option) { error, resp in
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
    func driverLicenseV1(completionHandler: ((Error?, OCRDriverLicenseV1Response?) -> Void)? = nil) -> URLSessionTask? {
        let option = OCRDriverLicenseV1Option(image: self)
        let task = Cardpp.driverLicenseV1(option: option) { error, resp in
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
    func bankcardV1(completionHandler: ((Error?, OCRBankCardResponse?) -> Void)?) -> URLSessionTask? {
        let option = OCRBankCardV1Option(image: self)
        let task = Cardpp.bankCardV1(option: option) { error, resp in
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
    func bankcardBeta(completionHandler: ((Error?, OCRBankCardResponse?) -> Void)?) -> URLSessionTask? {
        let option = OCRBankCardBetaOption(image: self)
        let task = Cardpp.bankCardBeta(option: option) { error, resp in
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
    func template(templateId: String,
                  extraInfo: [String]? = nil,
                  completionHandler: ((Error?, OCRTemplateResponse?) -> Void)? = nil) -> URLSessionTask? {
        let option = OCRTemplateOption(templateId: templateId)
        option.imageBase64 = base64String()
        option.extraInfo = extraInfo
        let task = Cardpp.templateOCR(option: option) { error, resp in
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
