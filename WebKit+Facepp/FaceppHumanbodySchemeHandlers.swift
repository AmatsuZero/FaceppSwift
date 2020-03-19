//
//  FaceppObjectDetectSchemeHandler.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/3/17.
//

import UIKit
import WebKit

@available(iOS 11.0, *)
public protocol FaceppSkeletonSchemeHandlerDelegate: FaceppSchemeHandlerDelegate {
    func schemeHandler(_ handler:FaceppSkeletonSchemeHandler,
                       rawImage: UIImage,
                       detect skeletons: [SkeletonDetectResponse.Skeleton]?) -> UIImage?
}

@available(iOS 11.0, *)
public extension FaceppSkeletonSchemeHandlerDelegate {
    func schemeHandler(_ handler:FaceppSkeletonSchemeHandler,
                       rawImage: UIImage,
                       detect skeletons: [SkeletonDetectResponse.Skeleton]?) -> UIImage? {
        return rawImage
    }
}

/// 人体检测和骨骼关键点检测拦截器
@available(iOS 11.0, *)
public class FaceppSkeletonSchemeHandler: FaceppBaseSchemeHandler {
    
    private weak var _delegate: FaceppSkeletonSchemeHandlerDelegate?
    
    public override var delegate: FaceppSchemeHandlerDelegate? {
        set {
            if let proxy = newValue as? FaceppSkeletonSchemeHandlerDelegate {
                _delegate = proxy
            }
        }
        get {
            return _delegate
        }
    }
    
    public override func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url?
            .customURL(webviewURL: webView.url, resourceDir: resourceDirURL)?.picURL  else {
                urlSchemeTask.didFailWithError(FppHandlerRuntimeError("Not Support"))
                return
        }
        extraOriginalImage(url: url) { [weak self] err, image in
            guard err == nil else {
                urlSchemeTask.didFailWithError(err!)
                return
            }
            self?.fetchData(urlSchemeTask, rawImage: image!)
        }
    }
}

@available(iOS 11.0, *)
extension FaceppSkeletonSchemeHandler {
    func fetchData(_ schemeTask: WKURLSchemeTask, rawImage image: UIImage) {
        let task = image.skeleton { [weak self] error, resp in
            self?.handle(task: schemeTask, error: error, rawImage: image, response: resp)
        }
        self.tasks[schemeTask.request] = task
    }
    
    func handle(task: WKURLSchemeTask, error: Error?,
                rawImage:UIImage, response: SkeletonDetectResponse?) {
        defer {
            tasks.removeValue(forKey: task.request)
        }
        guard error == nil else {
            task.didFailWithError(error!)
            return
        }
        let newImage = _delegate?.schemeHandler(self, rawImage: rawImage,
                                                detect: response?.skeletons) ?? rawImage
        task.complete(with: newImage)
    }
}
