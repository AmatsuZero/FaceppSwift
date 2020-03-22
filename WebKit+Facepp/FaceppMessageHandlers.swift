//
//  FaceMessageHandlers.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/3/17.
//

import Foundation
import WebKit

public class FaceppMessageHandler<Option: FaceppRequestConfigProtocol>: NSObject, WKScriptMessageHandler {
    /// 回调函数名
    public var callbackFuncName: String
    
    private var tasks = [URLSessionTask]()
    
    public init(callBack name: String) {
        callbackFuncName = name
    }
    
    public func userContentController(_ userContentController: WKUserContentController,
                                      didReceive message: WKScriptMessage) {
        guard let params = message.body as? [String: Any] else {
            return handle(message.webView, error: FppHandlerRuntimeError("无效的传参"), data: nil)
        }
        let option = Option(params: params)
        do {
            let task = try FaceppClient.shared?.quickRequest(option: option) { [weak self] error, data in
                self?.handle(message.webView, error: error, data: data)
            }
            if let task = task {
                tasks.append(task)
            }
        } catch {
            handle(message.webView, error: error, data: nil)
        }
    }
    
    func handle(_ webview: WKWebView?, error: Error?, data: Data?) {
        let script = "\(callbackFuncName)"
        webview?.evaluateJavaScript(script) { ret, error in
            
        }
    }
    
    deinit {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
}

extension FaceppClient {
    func quickRequest(option: FaceppRequestConfigProtocol,
                      completionHandler: @escaping (Error?, Data?) -> Void) throws -> URLSessionTask? {
        guard let realReq = option as? RequestProtocol else { // 转换成内部协议
            return nil
        }
        let (request, data) = try realReq.asRequest(apiKey: apiKey, apiSecret: apiKey)
        guard let req = request else {
            return nil
        }
        let task = session.uploadTask(with: req, from: data) { data, _, error in
            completionHandler(error, data)
        }
        task.resume()
        return task
    }
}
