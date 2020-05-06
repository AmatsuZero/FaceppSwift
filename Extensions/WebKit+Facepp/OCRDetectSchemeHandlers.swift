//
//  FaceppTextDetectSchemeHandler.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/3/18.
//

import UIKit
import WebKit

@available(iOS 11.0, *)
public protocol FaceppTextDetectSchemeHandlerDelegate: FaceppSchemeHandlerDelegate {
    func schemeHandler(_ handler: FaceppTextDetectSchemeHandler,
                       rawImage: UIImage,
                       error: Error?,
                       detect result: [ImagepprecognizeTextResponse.Result]?) -> UIImage?
}

@available(iOS 11.0, *)
public extension FaceppTextDetectSchemeHandlerDelegate {
    func schemeHandler(_ handler: FaceppTextDetectSchemeHandler,
                       rawImage: UIImage,
                       error: Error?,
                       detect result: [ImagepprecognizeTextResponse.Result]?) -> UIImage? {
        return rawImage
    }
}

/// 文字识别拦截器
@available(iOS 11.0, *)
public class FaceppTextDetectSchemeHandler: FaceppBaseSchemeHandler {

    private weak var _delegate: FaceppTextDetectSchemeHandlerDelegate?

    public override var delegate: FaceppSchemeHandlerDelegate? {
        set {
            if let proxy = newValue as? FaceppTextDetectSchemeHandlerDelegate {
                _delegate = proxy
            }
        }
        get {
            return _delegate
        }
    }

    public override func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let picURL = urlSchemeTask.request.url?
            .customURL(webviewURL: webView.url, resourceDir: resourceDirURL)?.picURL  else {
                urlSchemeTask.didFailWithError(FppHandlerRuntimeError("Not Support"))
                return
        }
        extraOriginalImage(url: picURL) { [weak self] error, img in
            guard let img = img else {
                urlSchemeTask.didFailWithError(error!)
                return
            }
            self?.handle(urlSchemeTask, image: img)
        }
    }

    func handle(_ schemeTask: WKURLSchemeTask, image: UIImage) {
        let task = image.recognizeText { [weak self] error, resp in
            defer {
                self?.tasks.removeValue(forKey: schemeTask.request)
            }
            guard let self = self else {
                return
            }
            let newImage = self._delegate?.schemeHandler(self, rawImage: image,
                                                         error: error,
                                                         detect: resp?.result) ?? image
            schemeTask.complete(with: newImage)
        }
        tasks[schemeTask.request] = task
    }
}

@available(iOS 11.0, *)
public protocol FaceppTemplateSchemeHandlerDelegate: FaceppSchemeHandlerDelegate {
    func schemeHandler(_ handler: FaceppTemplateSchemeHandler,
                       rawImage: UIImage,
                       error: Error?,
                       detect results: [OCRTemplateResponse.Result]?) -> UIImage?
}

@available(iOS 11.0, *)
public extension FaceppTemplateSchemeHandlerDelegate {
    func schemeHandler(_ handler: FaceppTemplateSchemeHandler,
                       rawImage: UIImage,
                       error: Error?,
                       detect results: [OCRTemplateResponse.Result]?) -> UIImage? {
        return rawImage
    }
}

/// 模板识别拦截器
@available(iOS 11.0, *)
public class FaceppTemplateSchemeHandler: FaceppBaseSchemeHandler {
    private weak var _delegate: FaceppTemplateSchemeHandlerDelegate?

    public override var delegate: FaceppSchemeHandlerDelegate? {
        set {
            if let proxy = newValue as? FaceppTemplateSchemeHandlerDelegate {
                _delegate = proxy
            }
        }
        get {
            return _delegate
        }
    }

    public override func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let components = urlSchemeTask.request.url?
            .customURL(webviewURL: webView.url, resourceDir: resourceDirURL) else {
                urlSchemeTask.didFailWithError(FppHandlerRuntimeError("Not Support"))
                return
        }
        guard let picURL = components.picURL else {
            urlSchemeTask.didFailWithError(FppHandlerRuntimeError(""))
            return
        }
        guard let id = components.params["template_id"] else {
            urlSchemeTask.didFailWithError(FppHandlerRuntimeError("缺少Template ID"))
            return
        }
        let extraInfo = components.params["extra_info"]?.components(separatedBy: ",")
        extraOriginalImage(url: picURL) { [weak self] error, img in
            guard let img = img else {
                urlSchemeTask.didFailWithError(error!)
                return
            }
            self?.handle(urlSchemeTask, templateId: id, extraInfo: extraInfo, image: img)
        }
    }

    func handle(_ schemeTask: WKURLSchemeTask,
                templateId: String,
                extraInfo: [String]?,
                image: UIImage) {
        let task = image.template(templateId: templateId, extraInfo: extraInfo) { [weak self] error, resp in
            defer {
                self?.tasks.removeValue(forKey: schemeTask.request)
            }
            guard let self = self else {
                return
            }
            let newImage = self._delegate?.schemeHandler(self, rawImage: image,
                                                         error: error,
                                                         detect: resp?.result) ?? image
            schemeTask.complete(with: newImage)
        }
        tasks[schemeTask.request] = task
    }
}
