//
//  ViewController.swift
//  Example
//
//  Created by 姜振华 on 2020/3/12.
//  Copyright © 2020 FaceppSwift. All rights reserved.
//

import UIKit
import WebKit
import SnapKit
import FaceppSwift

class ViewController: UIViewController {
    let beautyHandler = FaceppBeautifySchemeHandler()
    let markHandler = FaceppDetectFacesSchemeHandler()
    let bodyHandler = FaceppSkeletonSchemeHandler()
    let textHandler = FaceppTextDetectSchemeHandler()
    let templateHandler = FaceppTemplateSchemeHandler()

    lazy var webView: WKWebView = {
        let configureation = WKWebViewConfiguration()
        configureation.setURLSchemeHandler(beautyHandler, forURLScheme: "test1")
        configureation.setURLSchemeHandler(markHandler, forURLScheme: "test2")
        configureation.setURLSchemeHandler(bodyHandler, forURLScheme: "test3")
        configureation.setURLSchemeHandler(textHandler, forURLScheme: "test4")
        configureation.setURLSchemeHandler(templateHandler, forURLScheme: "test5")
        return WKWebView(frame: .zero, configuration: configureation)
    }()

    override func loadView() {
        super.loadView()
        view.addSubview(webView)
        webView.snp.makeConstraints { $0.edges.equalTo(0) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        markHandler.delegate = self
        bodyHandler.delegate = self
        textHandler.delegate = self
        templateHandler.delegate = self
        if let url = Bundle.main.url(forResource: "Beautify",
                                     withExtension: "html",
                                     subdirectory: "WebPages") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
}

extension ViewController: FaceppDetectFacesSchemeHandlerDelegate {
    func schemeHandler(_ handler: FaceppDetectFacesSchemeHandler,
                       rawImage: UIImage,
                       detect faces: [Face]) -> UIImage? {
        let imageSize = rawImage.size
        UIGraphicsBeginImageContextWithOptions(imageSize, false, rawImage.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return rawImage
        }
        rawImage.draw(at: .zero)
        context.setFillColor(UIColor.clear.cgColor)
        context.setStrokeColor(UIColor.systemBlue.cgColor)
        context.setLineWidth(3.6)
        faces.map { face -> CGPath in
            let rect = face.faceRectangle.asCGRect()
            let path = UIBezierPath(rect: rect)
            if let angle = face.attributes?.headpose?.rollAngle {
                var transform = CGAffineTransform.identity
                transform = transform.translatedBy(x: rect.midX, y: rect.midY)
                transform = transform.rotated(by: .pi * CGFloat(angle) / 180)
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

extension ViewController: FaceppSkeletonSchemeHandlerDelegate {
    func schemeHandler(_ handler: FaceppSkeletonSchemeHandler, rawImage: UIImage,
                       detect skeletons: [SkeletonDetectResponse.Skeleton]?) -> UIImage? {
        let imageSize = rawImage.size
        UIGraphicsBeginImageContextWithOptions(imageSize, false, rawImage.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return rawImage
        }
        rawImage.draw(at: .zero)
        context.setFillColor(UIColor.clear.cgColor)
        context.setStrokeColor(UIColor.systemBlue.cgColor)
        context.setLineWidth(3.0)
        skeletons?.forEach { skeleton in
            context.saveGState()
            let rect = skeleton.bodyRectangle.asCGRect()
            context.addRect(rect)
            context.translateBy(x: rect.minX, y: rect.minY)
            self.drawBody(context, skeleton: skeleton)
            context.restoreGState()
        }
        context.drawPath(using: .fillStroke)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func drawBody(_ context: CGContext, skeleton: SkeletonDetectResponse.Skeleton) {
        // 头和左手
        context.addLines(between: [
            skeleton.landmark.head.asCGPoint(),
            skeleton.landmark.neck.asCGPoint(),
            skeleton.landmark.leftShoulder.asCGPoint(),
            skeleton.landmark.leftElbow.asCGPoint(),
            skeleton.landmark.leftHand.asCGPoint()
        ])
        // 右手
        context.move(to: skeleton.landmark.neck.asCGPoint())
        context.addLines(between: [
            skeleton.landmark.neck.asCGPoint(),
            skeleton.landmark.rightShoulder.asCGPoint(),
            skeleton.landmark.rightElbow.asCGPoint(),
            skeleton.landmark.rightHand.asCGPoint()
        ])
        // 左腿
        context.move(to: skeleton.landmark.leftButtocks.asCGPoint())
        context.addLines(between: [
            skeleton.landmark.leftButtocks.asCGPoint(),
            skeleton.landmark.leftKnee.asCGPoint(),
            skeleton.landmark.leftFoot.asCGPoint()
        ])
        // 右腿
        context.move(to: skeleton.landmark.rightButtocks.asCGPoint())
        context.addLines(between: [
            skeleton.landmark.rightButtocks.asCGPoint(),
            skeleton.landmark.rightKnee.asCGPoint(),
            skeleton.landmark.rightFoot.asCGPoint()
        ])
        // 躯干
        context.move(to: skeleton.landmark.leftShoulder.asCGPoint())
        context.addLines(between: [
            skeleton.landmark.leftShoulder.asCGPoint(),
            skeleton.landmark.leftButtocks.asCGPoint(),
            skeleton.landmark.rightButtocks.asCGPoint(),
            skeleton.landmark.rightShoulder.asCGPoint()
        ])
    }
}

extension ViewController: FaceppTextDetectSchemeHandlerDelegate {
    func schemeHandler(_ handler: FaceppTextDetectSchemeHandler,
                       rawImage: UIImage,
                       detect result: [ImagepprecognizeTextResponse.Result]) -> UIImage? {
        let imageSize = rawImage.size
        UIGraphicsBeginImageContextWithOptions(imageSize, false, rawImage.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return rawImage
        }
        rawImage.draw(at: .zero)
        context.setFillColor(UIColor.clear.cgColor)
        context.setStrokeColor(UIColor.systemBlue.cgColor)
        context.setLineWidth(3.0)
        return rawImage
    }
}

extension ViewController: FaceppTemplateSchemeHandlerDelegate {
    func schemeHandler(_ handler: FaceppTemplateSchemeHandler,
                       rawImage: UIImage,
                       detect results: [OCRTemplateResponse.Result]) -> UIImage? {
        let imageSize = rawImage.size
        UIGraphicsBeginImageContextWithOptions(imageSize, false, rawImage.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return rawImage
        }
        rawImage.draw(at: .zero)
        context.setFillColor(UIColor.blue.withAlphaComponent(0.3).cgColor)
        context.setStrokeColor(UIColor.systemBlue.cgColor)
        context.setLineWidth(3.0)
        results.forEach { ret in
            guard let pts = ret.value.position?.map({ $0.asCGPoint() }) else {
                return
            }
            // 绘制边框
            context.addLines(between: pts)
            self.drawTile(context, text: ret.key, points: pts)
            self.drawContent(context, texts: ret.value.text, points: pts, padding: 10 * rawImage.scale)
        }
        context.drawPath(using: .fillStroke)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func drawTile(_ ctx: CGContext, text: String, points: [CGPoint]) {
        let scale = UIScreen.main.scale
        guard let leftTop = points.min(by: { $0.x < $1.x && $0.y < $1.y }),
            let rightBottom = points.max(by: {$0.x < $1.x && $0.y < $1.y}) else {
                return
        }
        let title = NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.red,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12 * scale)
        ])
        let textSize = title.boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: rightBottom.y - leftTop.x),
                                          options: .usesFontLeading,
                                          context: nil).size
        ctx.saveGState()
        title.draw(at: .init(x: leftTop.x - textSize.width, y: leftTop.y))
        ctx.restoreGState()
    }

    func drawContent(_ ctx: CGContext, texts: [String], points: [CGPoint], padding: CGFloat) {
        let scale = UIScreen.main.scale
        guard let leftTop = points.min(by: { $0.x < $1.x && $0.y < $1.y }) else {
            return
        }
        let title = NSAttributedString(string: texts.joined(separator: "\t"), attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.blue,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12 * scale)
        ])
        ctx.saveGState()
        title.draw(at: .init(x: leftTop.x + padding, y: leftTop.y))
        ctx.restoreGState()
    }
}
