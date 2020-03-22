//
//  FaceppDetectFacesSchemeHandler.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/3/17.
//

import UIKit
import WebKit

@available(iOS 11.0, *)
public protocol FaceppDetectFacesSchemeHandlerDelegate: FaceppSchemeHandlerDelegate {
    func schemeHandler(_ handler: FaceppDetectFacesSchemeHandler,
                       rawImage: UIImage,
                       error: Error?,
                       detect skeletons: [Face]?) -> UIImage?
}

@available(iOS 11.0, *)
public extension FaceppDetectFacesSchemeHandlerDelegate {
    func schemeHandler(_ handler: FaceppDetectFacesSchemeHandler,
                       rawImage: UIImage,
                       error: Error?,
                       detect skeletons: [Face]?) -> UIImage? {
        return rawImage
    }
}

/// 人脸标记拦截器
@available(iOS 11.0, *)
public class FaceppDetectFacesSchemeHandler: FaceppBaseSchemeHandler {

    private weak var _delegate: FaceppDetectFacesSchemeHandlerDelegate?

    override weak public var delegate: FaceppSchemeHandlerDelegate? {
        set {
            if let proxy = newValue as? FaceppDetectFacesSchemeHandlerDelegate {
                _delegate = proxy
            } else {
                _delegate = nil
            }
        }
        get {
            return _delegate
        }
    }

    public override func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let components = urlSchemeTask.request.url?
            .customURL(webviewURL: webView.url, resourceDir: resourceDirURL)  else {
                urlSchemeTask.didFailWithError(FppHandlerRuntimeError("Not Support"))
                return
        }
        guard let picURL = components.picURL else {
            urlSchemeTask.didFailWithError(FppHandlerRuntimeError("Invalid URL"))
            return
        }
        let option = FaceDetectOption(picURL: picURL, params: components.params)
        extraOriginalImage(url: picURL) { [weak self] err, rawImg in
            guard err == nil else {
                urlSchemeTask.didFailWithError(err!)
                return
            }
            option.imageBase64 = rawImg?.base64String()
            self?.handle(urlSchemeTask, rawImage: rawImg!, option: option)
        }
    }

    func handle(_ urlSchemeTask: WKURLSchemeTask, rawImage: UIImage, option: FaceDetectOption) {
        let task = Facepp.detect(option: option) { [weak self] error, resp in
            guard error == nil,
                let self = self else {
                urlSchemeTask.didFailWithError(error!)
                return
            }
            self.draw(task: urlSchemeTask, originalImage: rawImage, error: error, faces: resp?.faces)
        }.request()
        self.tasks[urlSchemeTask.request] = task
    }

    func draw(task: WKURLSchemeTask, originalImage: UIImage, error: Error?, faces: [Face]?) {
        defer {
            tasks.removeValue(forKey: task.request)
        }
        let newImage = _delegate?.schemeHandler(self,
                                                rawImage: originalImage,
                                                error: error,
                                                detect: faces) ?? originalImage
        task.complete(with: newImage)
    }
}

extension FaceDetectOption {
    convenience init(picURL: URL, params: [String: String]) {
        self.init(params: params)
        if picURL.scheme == "file" {
            imageFile = picURL
        } else {
            imageURL = picURL
        }
    }
}
