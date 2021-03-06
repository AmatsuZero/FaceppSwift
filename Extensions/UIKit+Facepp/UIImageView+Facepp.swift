//
//  UIImageView+Facepp.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/4/21.
//

import Foundation
import UIKit

private var fppDebugFppAwareKey: Void?
private var fppDidFocusOnFacesKey: Void?
private var fppFoucusTypeKey: Void?

/**
 参考：https://github.com/BeauNouvelle/FaceAware
 */
extension UIImageView {
    /// 聚焦类型
    public enum FocusType {
        /// 脸部（请求失败是否用CIFilter 代替）
        case face(needFallback: Bool)
        /// 手势
        case gesture
        /// 身体
        case body
        /// 不检测
        case none
    }

    public var debugFppAware: Bool {
        set {
            objc_setAssociatedObject(self, &fppDebugFppAwareKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &fppDebugFppAwareKey) as? Bool ?? false
        }
    }

    public var didFocusOn: (() -> Void)? {
        set {
            objc_setAssociatedObject(self, &fppDidFocusOnFacesKey, newValue, .OBJC_ASSOCIATION_COPY)
        }
        get {
            objc_getAssociatedObject(self, &fppDidFocusOnFacesKey) as? (() -> Void)
        }
    }

    public var focusType: FocusType {
        set {
            switch newValue {
            case .face(let needFallback):
                setImageFocusOnFaces(needFallback: needFallback)
            case .body:
                setImageFoucusOnBody()
            case .gesture:
                setImageFoucusOnGesture()
            case .none:
                removeImageLayer(image: image)
            }
            objc_setAssociatedObject(self, &fppFoucusTypeKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &fppFoucusTypeKey) as? FocusType ?? .none
        }
    }

    private func setImageFocusOnFaces(needFallback: Bool) {
        guard let image = image else {
            return
        }
        image.detectFace(returnLandmark: .no, completioHandler: { [weak self] _, resp in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                var isFallback = false
                var faceReactangles = resp?.faces?.map { $0.faceRectangle.asCGRect() } ?? []
                if faceReactangles.isEmpty, needFallback {
                    isFallback = true
                    faceReactangles = self.faceFocusFallback(image: image)
                }
                self.applyDetection(rects: faceReactangles, isFallback: isFallback)
            }
        })
    }

    private func setImageFoucusOnGesture() {
        image?.gesture { [weak self] error, resp in
            guard let self = self, error == nil else {
                return
            }
            let rects = resp?.hands?.map { $0.handRectangle.asCGRect() } ?? []
            DispatchQueue.main.async {
                self.applyDetection(rects: rects)
            }
        }
    }

    private func setImageFoucusOnBody() {
        image?.detectBody { [weak self] error, resp in
            guard let self = self, error == nil else {
                return
            }
            let rects = resp?.humanbodies?.map { $0.humanbodyRectangle.asCGRect() } ?? []
            DispatchQueue.main.async {
                self.applyDetection(rects: rects)
            }
        }
    }

    private func applyDetection(rects: [CGRect], isFallback: Bool = true) {
        guard let cgImage = image?.cgImage, !rects.isEmpty else {
            if debugFppAware {
                print("No face detected")
            }
            removeImageLayer(image: image)
            return
        }
        let size = CGSize(width: cgImage.width, height: cgImage.height)
        var rect = rects[0]
        if isFallback {
            rect.origin.y = size.height - rect.maxY
        }
        var rightBorder = rect.maxX
        var bottomBorder = rect.maxY

        for dectRect in rects[1..<rects.count] {
            var oneRect = dectRect
            if isFallback {
                oneRect.origin.y = size.height - oneRect.maxY
            }
            rect.origin.x = min(oneRect.minX, rect.minX)
            rect.origin.y = min(oneRect.minY, rect.minY)
            rightBorder = max(oneRect.maxX, rightBorder)
            bottomBorder = max(oneRect.maxY, bottomBorder)
        }
        rect.size.width = rightBorder - rect.minX
        rect.size.height = bottomBorder - rect.minY
        var offset = CGPoint.zero
        var finalSize = size
        DispatchQueue.main.async {
            (offset, finalSize) = self.getFinalSize(rect: rect, size: size)
        }
        var newImage: UIImage?
        if self.debugFppAware {
            newImage = drawDebugRectangles(size: size, rects: rects, isFallback: isFallback)
        } else {
            newImage = image
        }
        DispatchQueue.main.async {
            self.image = newImage
            let layer = self.imageLayer()
            layer.contents = newImage?.cgImage
            layer.frame = CGRect(x: offset.x, y: offset.y, width: finalSize.width, height: finalSize.height)
            self.didFocusOn?()
        }
    }

    private func drawDebugRectangles(size: CGSize, rects: [CGRect],
                                     isFallback: Bool) -> UIImage? {
        guard let cgImage = image?.cgImage else {
            return nil
        }
        let rawImage = UIImage(cgImage: cgImage)
        UIGraphicsBeginImageContext(size)
        rawImage.draw(at: CGPoint.zero)

        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.red.cgColor)
        context?.setLineWidth(3)
        rects.forEach { rect in
            var faceViewBounds = rect
            if isFallback {
                faceViewBounds.origin.y = size.height - faceViewBounds.maxY
            }
            context?.addRect(faceViewBounds)
            context?.drawPath(using: .stroke)
        }
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    private func getFinalSize(rect: CGRect, size: CGSize) -> (offset: CGPoint, finalSize: CGSize) {
        var offset = CGPoint.zero
        var finalSize = size
        if size.width / size.height > bounds.width / bounds.height {
            var centerX = rect.minX + rect.width / 2
            finalSize.height = bounds.height
            finalSize.width = size.width / size.height * finalSize.height
            centerX = finalSize.width / size.width * centerX

            offset.x = centerX - bounds.size.width * 0.5
            if offset.x < 0 {
                offset.x = 0
            } else if offset.x + bounds.width > finalSize.width {
                offset.x = finalSize.width - bounds.width
            }
            offset.x = -offset.x
        } else {
            var centerY = rect.minY + rect.height / 2
            finalSize.width = bounds.width
            finalSize.height = size.height / size.width * finalSize.width
            centerY = finalSize.width / size.width * centerY

            offset.y = centerY - bounds.height * (1-0.618)
            if offset.y < 0 {
                offset.y = 0
            } else if offset.y + bounds.height > finalSize.height {
                finalSize.height = bounds.height
                offset.y = finalSize.height
            }
            offset.y = -offset.y
        }
        return (offset, finalSize)
    }

    private func faceFocusFallback(image: UIImage) -> [CGRect] {
        guard let image = CIImage(image: image) else {
            return []
        }
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil,
                                  options: [CIDetectorAccuracy: CIDetectorAccuracyLow])
        return detector?.features(in: image).map { $0.bounds } ?? []
    }

    private func removeImageLayer(image: UIImage?) {
        DispatchQueue.main.async {
            // avoid redundant layer when focus on faces for the image of cell specified in UITableView
            self.imageLayer().removeFromSuperlayer()
            self.image = image
        }
    }

    private func imageLayer() -> CALayer {
        if let layer = sublayer() {
            return layer
        }

        let subLayer = CALayer()
        subLayer.name = "AspectFillFppAware"
        subLayer.actions = [
            "contents": NSNull(),
            "bounds": NSNull(),
            "position": NSNull()
        ]
        layer.addSublayer(subLayer)
        return subLayer
    }

    private func sublayer() -> CALayer? {
        return layer.sublayers?.first(where: { $0.name == "AspectFillFppAware" })
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        // 触发一下刷新
        let type = self.focusType
        self.focusType = type
    }
}
