//
//  Cardpp.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/9.
//

import Foundation

public class Cardpp {
    
    public class func idcard(option: OCRIDCardOption, completionHandler: @escaping (Error?, OCRIDCardResponse?) -> Void) {
        parse(option: option, completionHandler: completionHandler)
    }
    
    public class func driverLicenseV2(option: OCRDriverLicenseV2Option, completionHandler: @escaping (Error?, OCRDriverLicenseV2Response?) -> Void) {
        parse(option: option, completionHandler: completionHandler)
    }
    
    public class func driverLicenseV1(option: OCRDriverLicenseV1Option, completionHandler: @escaping (Error?, OCRDriverLicenseV1Response?) -> Void) {
        parse(option: option, completionHandler: completionHandler)
    }
    
    public class func vehicleLicense(option: OCRVehicleLicenseOption, completionHandler: @escaping (Error?, OCRVehicleLicenseResponse?) -> Void) {
        parse(option: option, completionHandler: completionHandler)
    }
    
    class func parse<R: ResponseProtocol>(option: RequestProtocol,
                                          completionHandler: @escaping (Error?, R?) -> Void)  {
        guard let client = Facepp.shared else {
            return completionHandler(RequestError.NotInit, nil)
        }
        client.parse(option: option, completionHanlder: completionHandler)
    }
}
