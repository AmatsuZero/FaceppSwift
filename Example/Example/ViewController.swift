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
    let handler = FaceppBeautifySchemeHandler()
    let markHandler = FaceppDetectFacesSchemeHandler()
    let bodyHandler = FaceppSkeletonSchemeHandler()
    lazy var webView: WKWebView = {
        let configureation = WKWebViewConfiguration()
        configureation.setURLSchemeHandler(handler, forURLScheme: "test1")
        configureation.setURLSchemeHandler(markHandler, forURLScheme: "test2")
        configureation.setURLSchemeHandler(bodyHandler, forURLScheme: "test3")
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
        let scale = CGFloat.zero
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
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
        let scale = CGFloat.zero
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
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
