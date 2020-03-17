//
//  FaceppMarkFacesSchemeHandler.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/3/17.
//

import UIKit
import WebKit

public class FaceppMarkFacesSchemeHandler: FaceppBaseSchemeHandler {
    /**
     拦截的scheme，如果需要处理的资源是全路径，host部分以“[本来的scheme]^[host]”标记
     例：
     fppdetect://file^folder/picture.jpg
     fppdetect://http^dummy/pic.jpg
     如果不设置host，则以当前 WebView 的地址作为 baseURL 进行拼接处理
     */
    public static let scheme = "fppdetect"
    
    public var lineWidth: CGFloat = 4
    
    public var lineColor = UIColor.systemBlue
    
    private let queue = DispatchQueue(label: "com.daubert.facepp.markHandler")
    
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
        
        let group = DispatchGroup()
        var originalImage: UIImage!
        var faces: [Face]!
        var shouldCancel = false
        
        group.enter()
        extraOriginalImage(url: picURL) { error, img in
            guard error == nil,
                let image = img else {
                shouldCancel = true
                urlSchemeTask.didFailWithError(error!)
                return
            }
            originalImage = image
            group.leave()
        }
        
        group.enter()
        let task = Facepp.detect(option: option) { error, resp in
            guard error == nil else {
                shouldCancel = true
                urlSchemeTask.didFailWithError(error!)
                return
            }
            faces = resp?.faces
            group.leave()
        }.request()
        tasks[urlSchemeTask.request] = task
        
        group.notify(queue: queue) { [weak self] in
            guard !shouldCancel else {
                return
            }
            self?.draw(task: urlSchemeTask, originalImage: originalImage, faces: faces)
        }
    }
}

extension FaceDetectOption {
    convenience init(picURL: URL, params: [String: String]) {
        self.init(picURL: picURL)
        if let value = params["beauty_score_min"]?.integerValue {
            beautyScoreMin = value
        }
        if let value = params["beauty_score_max"]?.integerValue {
            beautyScoreMin = value
        }
        if let value = params["calculate_all"]?.integerValue {
            calculateAll = value == 1
        }
        if let attribbutes = params["return_attributes"]?.components(separatedBy: ",") {
            returnAttributes = Set(attribbutes.compactMap { ReturnAttributes(rawValue: $0) })
        }
        if let pts = params["face_rectangle"] {
            faceRectangle = FaceppRectangle(string: pts)
        }
        if let landmark = params["return_landmark"]?.integerValue {
            returnLandmark = ReturnLandmark(rawValue: landmark) ?? .no
        }
    }
}

extension FaceppMarkFacesSchemeHandler {
    func extraOriginalImage(url: URL, completionHandler:@escaping (Error?, UIImage?) -> Void) {
        var image: UIImage?
        if url.scheme == "file" {
            image = UIImage(contentsOfFile: url.path)
            completionHandler(nil, image)
        } else {
            let req = URLRequest(url: url)
            // 先尝试从缓存取出图片
            if let data = URLCache.shared.cachedResponse(for: req)?.data {
                image = UIImage(data: data)
                completionHandler(nil, image)
            } else { // 没有，通过请求获取
                let task = URLSession.shared.dataTask(with: req) { [weak self] data, resp, error in
                    guard let data = data else {
                        completionHandler(error, nil)
                        return
                    }
                    self?.tasks.removeValue(forKey: req)
                    completionHandler(nil, UIImage(data: data))
                }
                tasks[req] = task
                task.resume()
            }
        }
    }
    
    func draw(task:WKURLSchemeTask, originalImage: UIImage, faces: [Face]) {
        defer {
            tasks.removeValue(forKey: task.request)
        }
        guard let data = drawFaceRectangle(rawImage: originalImage, faces: faces)?.imageData() else {
            task.didFailWithError(FppHandlerRuntimeError("转换图片失败"))
            return
        }
        let response = URLResponse(url: task.request.url!,
                                   mimeType: "image/jpeg",
                                   expectedContentLength: data.count,
                                   textEncodingName: nil)
        task.didReceive(response)
        task.didReceive(data)
        task.didFinish()
    }
    
    func drawFaceRectangle(rawImage: UIImage,
                           faces: [Face]) -> UIImage? {
        let imageSize = rawImage.size
        let scale = CGFloat.zero
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return rawImage
        }
        rawImage.draw(at: .zero)
        context.setFillColor(UIColor.clear.cgColor)
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(lineWidth)
        faces.map { face -> CGPath in
            let rect = face.faceRectangle.asCGRect()
            let path = UIBezierPath(rect: rect)
            if let angle = face.attributes?.headpose?.rollAngle {
                var transform = CGAffineTransform.identity
                transform = transform.translatedBy(x: rect.midX, y: rect.midY)
                transform = transform.rotated(by: -.pi * CGFloat(angle) / 180)
                transform = transform.translatedBy(x: -rect.midX, y: -rect.midY)
                path.apply(transform)
            }
            return path.cgPath
        }.forEach { context.addPath($0) }
        context.drawPath(using: .fillStroke)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
