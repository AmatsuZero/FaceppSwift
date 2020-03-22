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
    let skeletonHandler = FaceppSkeletonSchemeHandler()
    let textHandler = FaceppTextDetectSchemeHandler()
    let templateHandler = FaceppTemplateSchemeHandler()
    let segmendHandler = FaceppSegmentSchemeHandler()
    let gestureHandler = FaceppGestureSchemeHandler()
    let bodyHandler = FaceppHumanBodyDetectSchemeHandler()
    let messageHandler = FaceppMessageHandler<OCRIDCardOption>(callBack: "faceppHandler")

    lazy var webView: WKWebView = {
        let configureation = WKWebViewConfiguration()
        configureation.setURLSchemeHandler(beautyHandler, forURLScheme: "test1")
        configureation.setURLSchemeHandler(markHandler, forURLScheme: "test2")
        configureation.setURLSchemeHandler(skeletonHandler, forURLScheme: "test3")
        configureation.setURLSchemeHandler(textHandler, forURLScheme: "test4")
        configureation.setURLSchemeHandler(templateHandler, forURLScheme: "test5")
        configureation.setURLSchemeHandler(segmendHandler, forURLScheme: "test6")
        configureation.setURLSchemeHandler(gestureHandler, forURLScheme: "test7")
        configureation.setURLSchemeHandler(bodyHandler, forURLScheme: "test8")

        let userController = WKUserContentController()
        userController.add(messageHandler, name: "idcard")
        configureation.userContentController = userController

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
        skeletonHandler.delegate = self
        textHandler.delegate = self
        templateHandler.delegate = self
        gestureHandler.delegate = self
        bodyHandler.delegate = self
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
                       error: Error?,
                       detect faces: [Face]?) -> UIImage? {
        guard error == nil, let faces = faces else {
            return rawImage
        }
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
    func schemeHandler(_ handler: FaceppSkeletonSchemeHandler,
                       rawImage: UIImage,
                       error: Error?,
                       detect skeletons: [SkeletonDetectResponse.Skeleton]?) -> UIImage? {
        guard error == nil else {
            return rawImage
        }
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
                       error: Error?,
                       detect result: [ImagepprecognizeTextResponse.Result]?) -> UIImage? {
        guard error == nil else {
            return rawImage
        }
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
                       error: Error?,
                       detect results: [OCRTemplateResponse.Result]?) -> UIImage? {
        guard error == nil, let results = results else {
            return rawImage
        }
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

extension ViewController: FaceppGestureSchemeHandlerDelegate {
    func schemeHandler(_ handler: FaceppGestureSchemeHandler,
                       rawImage: UIImage,
                       error: Error?,
                       detect hands: [HumanBodyGestureResponse.Hands]?) -> UIImage? {
        guard error == nil else {
            return rawImage
        }
        let imageSize = rawImage.size
        UIGraphicsBeginImageContextWithOptions(imageSize, false, rawImage.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return rawImage
        }
        rawImage.draw(at: .zero)
        context.setLineWidth(3.0)
        hands?.forEach { self.draw(context, hand: $0) }
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func draw(_ ctx: CGContext, hand: HumanBodyGestureResponse.Hands) {
        ctx.setStrokeColor(UIColor.systemBlue.cgColor)
        let rect = hand.handRectangle.asCGRect()
        ctx.addRect(rect)
        ctx.drawPath(using: .stroke)
        ctx.saveGState()
        let scale = UIScreen.main.scale
        let title = NSAttributedString(string: "\(hand.gesture.mostLikelyGesutre)", attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.blue,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12 * scale)
        ])
        var origin = rect.origin
        origin.x += 5 * scale
        origin.y += 5 * scale
        title.draw(at: origin)
        ctx.restoreGState()
    }
}

extension ViewController: FaceppHumanBodyDetectSchemeHandlerDelegate {
    func schemeHandler(_ handler: FaceppHumanBodyDetectSchemeHandler,
                       rawImage: UIImage,
                       error: Error?,
                       detect humanbodies: [HumanBodyDetectResponse.HumanBody]?) -> UIImage? {
        guard error == nil, let bodies = humanbodies else {
            return rawImage
        }
        let imageSize = rawImage.size
        UIGraphicsBeginImageContextWithOptions(imageSize, false, rawImage.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return rawImage
        }
        rawImage.draw(at: .zero)
        context.setLineWidth(3.0)
        bodies.forEach { self.draw(context, body: $0) }
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func draw(_ ctx: CGContext, body: HumanBodyDetectResponse.HumanBody) {
        let rect = body.humanbodyRectangle.asCGRect()
        let upperColor = body.attributes?.upperBodyCloth?.upperBodyClothColorRgb.color ?? .blue
        ctx.beginPath()
        ctx.setStrokeColor(upperColor.cgColor)
        ctx.move(to: .init(x: rect.minX, y: rect.midY))
        ctx.addLine(to: rect.origin)
        ctx.addLine(to: .init(x: rect.maxX, y: rect.minY))
        ctx.addLine(to: .init(x: rect.maxX, y: rect.midY))
        ctx.strokePath()

        let lowerColor = body.attributes?.lowerBodyCloth?.lowerBodyClothColorRgb.color ?? .blue
        ctx.beginPath()
        ctx.setStrokeColor(lowerColor.cgColor)
        ctx.move(to: .init(x: rect.minX, y: rect.midY))
        ctx.addLine(to: .init(x: rect.minX, y: rect.maxY))
        ctx.addLine(to: .init(x: rect.maxX, y: rect.maxY))
        ctx.addLine(to: .init(x: rect.maxX, y: rect.midY))
        ctx.strokePath()

        let gender = body.attributes?.mostLikelySex ?? .unknown
        let scale = UIScreen.main.scale
        let title = NSAttributedString(string: "\(gender)", attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.blue,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10 * scale)
        ])
        var origin = rect.origin
        origin.x += 5 * scale
        origin.y += 5 * scale
        title.draw(at: origin)
    }
}
