//
//  FaceMessageHandlers.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/3/17.
//

import Foundation
import WebKit

public class FaceppBaseMsgHandler: NSObject, WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController,
                                      didReceive message: WKScriptMessage) {
        message.webView?.evaluateJavaScript("", completionHandler: { ret, err in
            
        })
    }
}

public class FaceppFaceDetectMsgHandler: FaceppBaseMsgHandler {
    
}
