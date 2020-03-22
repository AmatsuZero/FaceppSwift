//
//  FaceMessageHandlers.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/3/17.
//

import Foundation
import WebKit

public let kFaceppMessageHandlerCallbackKey = "callbackFunc"

public class FaceppMessageHandler<Option: FaceppRequestConfigProtocol>: NSObject, WKScriptMessageHandler {
    /// 回调函数名
    public var callbackFuncName: String

    private var tasks = [Date: URLSessionTask]()

    public init(callBack name: String) {
        callbackFuncName = name
    }

    public func userContentController(_ userContentController: WKUserContentController,
                                      didReceive message: WKScriptMessage) {
        guard let params = message.body as? [String: Any] else {
            return handle(message.webView, error: FppHandlerRuntimeError("无效的传参"), data: nil)
        }
        if let cb = params[kFaceppMessageHandlerCallbackKey] as? String {
            callbackFuncName = cb
        }
        let option = Option(params: params)
        let date = Date()
        do {
            let task = try FaceppClient.shared?.quickRequest(option: option) { [weak self] error, data in
                DispatchQueue.main.async {
                   self?.handle(message.webView, error: error, data: data)
                }
                self?.tasks.removeValue(forKey: date)
            }
            tasks[date] = task
        } catch {
            handle(message.webView, error: error, data: nil)
        }
    }

    func handle(_ webview: WKWebView?, error: Error?, data: Data?) {
        var resp: String?
        if let data = data {
            resp = String(data: data, encoding: .utf8)
        }
        var err: String?
        if let msg = error?.localizedDescription {
            err = "Error('\(msg)')"
        }
        let script = "\(callbackFuncName)(\(err ?? "null"), \(resp ?? "null"))"
        webview?.evaluateJavaScript(script) { _, _ in

        }
    }

    deinit {
        tasks.values.forEach { $0.cancel() }
        tasks.removeAll()
    }
}

extension FaceppClient {
    func quickRequest(option: FaceppRequestConfigProtocol,
                      completionHandler: @escaping (Error?, Data?) -> Void) throws -> URLSessionTask? {
        guard let realReq = option as? RequestProtocol else { // 转换成内部协议
            return nil
        }
        let (request, data) = try realReq.asRequest(apiKey: apiKey, apiSecret: apiSecret)
        guard let req = request else {
            throw FppHandlerRuntimeError("缺少必要参数")
        }
        let task = session.uploadTask(with: req, from: data) { data, _, error in
            completionHandler(error, data)
        }
        task.resume()
        return task
    }
}
