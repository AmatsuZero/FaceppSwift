//
//  Cardpp.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/9.
//

import Foundation

public class Cardpp {
    
    public class func idcard(option: OCRIDCardOption, completionHanlder: @escaping (Error?, OCRIDCardResponse?) -> Void) {
        parse(option: option, completionHanlder: completionHanlder)
    }
    
    class func parse<R: ResponseProtocol>(option: RequestProtocol,
                                          completionHanlder: @escaping (Error?, R?) -> Void)  {
        guard let client = Facepp.shared else {
            return completionHanlder(RequestError.NotInit, nil)
        }
        client.parse(option: option, completionHanlder: completionHanlder)
    }
}
