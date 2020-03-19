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
    func schemeHandler(_ handler: FaceppSkeletonSchemeHandler,
                       rawImage: UIImage,
                       detect skeletons: [SkeletonDetectResponse.Skeleton]?) -> UIImage?
}

@available(iOS 11.0, *)
public extension FaceppSkeletonSchemeHandlerDelegate {
    func schemeHandler(_ handler: FaceppSkeletonSchemeHandler,
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

    func fetchData(_ schemeTask: WKURLSchemeTask, rawImage image: UIImage) {
        let task = image.skeleton { [weak self] error, resp in
            self?.handle(task: schemeTask, error: error, rawImage: image, response: resp)
        }
        self.tasks[schemeTask.request] = task
    }

    func handle(task: WKURLSchemeTask, error: Error?,
                rawImage: UIImage, response: SkeletonDetectResponse?) {
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

/// 人体抠图是schemeHandler
@available(iOS 11.0, *)
public class FaceppSegmentSchemeHandler: FaceppBaseSchemeHandler {

    public override func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let (url, params) = urlSchemeTask.request.url?
            .customURL(webviewURL: webView.url, resourceDir: resourceDirURL),
            let picURL = url  else {
                urlSchemeTask.didFailWithError(FppHandlerRuntimeError("Not Support"))
                return
        }
        var returnGrayScale = HumanBodySegmentV2Option.ReturnGrayScale.grayScaleAndFigure
        if let value = params["return_gray_scale"]?.integerValue,
            let type = HumanBodySegmentV2Option.ReturnGrayScale(rawValue: value) {
            returnGrayScale = type
        }
        extraOriginalImage(url: picURL) { [weak self] error, rawImage in
            guard let img = rawImage else {
                urlSchemeTask.didFailWithError(error!)
                return
            }
            let task = img.segmentV2(returnGrayScale: returnGrayScale) { error, resp in
                self?.drawSegment(urlSchemeTask, rawImage: img, error: error, response: resp)
            }
            self?.tasks[urlSchemeTask.request] = task
        }
    }

    func drawSegment(_ task: WKURLSchemeTask, rawImage: UIImage, error: Error?, response: HumanBodySegmentResponse?) {
        defer {
            tasks.removeValue(forKey: task.request)
        }
        guard error == nil else {
            task.didFailWithError(error!)
            return
        }
        if let gray = response?.result,
            let grayImage = UIImage(base64String: gray),
            let body = response?.bodyImage,
            let bodyImage = UIImage(base64String: body) {
            let imageSize = rawImage.size
            UIGraphicsBeginImageContextWithOptions(imageSize, false, rawImage.scale)
            grayImage.draw(at: .zero)
            bodyImage.draw(at: .zero)
            let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? rawImage
            UIGraphicsEndImageContext()
            task.complete(with: newImage)
        } else if let gray = response?.result,
            let grayImage = UIImage(base64String: gray) {
            task.complete(with: grayImage)
        } else if let body = response?.bodyImage,
            let bodyImage = UIImage(base64String: body) {
            task.complete(with: bodyImage)
        } else {
            task.complete(with: rawImage)
        }
    }
}
