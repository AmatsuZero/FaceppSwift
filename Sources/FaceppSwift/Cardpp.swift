//
//  Cardpp.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/9.
//

import Foundation

public enum Cardpp: UseFaceppClientProtocol {
    case idCard(option: OCRIDCardOption, handler: (Error?, OCRIDCardResponse?) -> Void)
    case driverLicenseV2(option: OCRDriverLicenseV2Option, handler: (Error?, OCRDriverLicenseV2Response?) -> Void)
    case driverLicenseV1(option: OCRDriverLicenseV1Option, handler: (Error?, OCRDriverLicenseV1Response?) -> Void)
    case vehicleLicense(option: OCRVehicleLicenseOption, handler: (Error?, OCRVehicleLicenseResponse?) -> Void)
    case bankCardV1(option: OCRBankCardV1Option, handler: (Error?, OCRBankCardResponse?) -> Void)
    case bankCardBeta(option: OCRBankCardBetaOption, handler: (Error?, OCRBankCardResponse?) -> Void)
    case templateOCR(option: OCRTemplateOption, handler: (Error?, OCRTemplateResponse?) -> Void)
    
    @discardableResult
    public func request() -> URLSessionTask? {
        switch self {
        case .driverLicenseV2(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .idCard(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .driverLicenseV1(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .vehicleLicense(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .bankCardV1(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .bankCardBeta(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .templateOCR(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        }
    }
}
