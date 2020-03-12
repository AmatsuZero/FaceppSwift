import UIKit

public extension CGRect {
    func asFaceppRectangle() -> FaceppRectangle {
        return FaceppRectangle(top: Int(minX),
                               left: Int(minY),
                               width: Int(width),
                               height: Int(height))
    }
}

public extension FaceppRectangle {
    func asCGRect() -> CGRect {
        return CGRect(x: CGFloat(left), y: CGFloat(top),
                      width: CGFloat(width), height: CGFloat(height))
    }
}

public extension FaceppPoint {
    func asCGPoint() -> CGPoint {
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}

public typealias ThreeDimensionFaces = (front: UIImage, left: UIImage, right: UIImage)

public extension UIImage {
    @discardableResult
    func detectFace(returnLandmark: FaceDetectOption.ReturnLandmark = .no,
                    returnAttributes: Set<FaceDetectOption.ReturnAttributes> = [.none],
                    beautyScoreMin: Int = 0,
                    beautyScoreMax: Int = 100,
                    calculateAll: Bool? = nil,
                    completioHandler:@escaping (Error?, FaceDetectResponse?) -> Void)
        -> URLSessionTask? {
            let option = FaceDetectOption(image: self)
            option.beautyScoreMin = beautyScoreMin
            option.beautyScoreMax = beautyScoreMax
            option.calculateAll = calculateAll
            option.returnLandmark = returnLandmark
            option.returnAttributes = returnAttributes
            return Facepp.detect(option: option, completionHandler: completioHandler).request()
    }

    @discardableResult
    func beautifyV2(whitening: UInt = 50,
                    smoothing: UInt = 50,
                    thinface: UInt = 50,
                    shrinkFace: UInt = 50,
                    enlargeEye: UInt = 50,
                    removeEyebrow: UInt = 50,
                    filterType: BeautifyV2Option.FilterType? = nil,
                    completionHandler:@escaping (Error?, UIImage?) -> Void)
        -> URLSessionTask? {
            let option = BeautifyV2Option(image: self)
            option.whitening = whitening
            option.smoothing = whitening
            option.thinface = thinface
            option.shrinkFace = shrinkFace
            option.enlargeEye = enlargeEye
            option.removeEyebrow = removeEyebrow
            option.filterType = filterType
            return Facepp.beautifyV2(option: option) { error, resp in
                guard let result = resp?.result else {
                    completionHandler(error, nil)
                    return
                }
                completionHandler(error, UIImage(base64String: result))
            }.request()
    }
    
    @discardableResult
    func beautifyV1(whitening: UInt = 50,
                    smoothing: UInt = 50,
                    completionHandler:@escaping (Error?, UIImage?) -> Void)  -> URLSessionTask? {
        let option = BeautifyV1Option(image: self)
        option.whitening = whitening
        option.smoothing = smoothing
        return Facepp.beautifyV1(option: option) { error, resp in
            guard let result = resp?.result else {
                completionHandler(error, nil)
                return
            }
            completionHandler(error, UIImage(base64String: result))
        }.request()
    }
    
    static func faceModel(faces: ThreeDimensionFaces,
                          needTexture: Bool = false,
                          needMTL: Bool = false,
                          needCheckParams: Bool = true,
                          completionHandler: @escaping (Error?, ThreeDimensionFaceResponse?) -> Void) -> URLSessionTask? {
        var option = ThreeDimensionFaceOption()
        option.imageBase641 = faces.front.base64String()
        option.imageBase642 = faces.left.base64String()
        option.imageBase643 = faces.right.base64String()
        option.needTexture = needTexture
        option.needMtl = needMTL
        option.needCheckParams = needCheckParams
        return Facepp.threeDimensionFace(option: option, completionHandler: completionHandler).request()
    }
}

public extension FaceppBaseRequest {
    convenience init(image: UIImage) {
        self.init()
        imageBase64 = image.base64String()
    }
}

fileprivate extension UInt32 {
    var mask8: UInt32 { return self & 0xFF }
    var R: UInt32 { return mask8 }
    var G: UInt32 { (self >> 8).mask8 }
    var B: UInt32 { (self >> 16).mask8 }
    var A: UInt32 { (self >> 24).mask8 }

    static func rgbAMake(r: UInt32, g: UInt32, b: UInt32, a: UInt32) -> UInt32 {
        return r.mask8 | g.mask8 << 8 | b.mask8 << 16 | a.mask8 << 24
    }
}

extension UIImage {
    func fixImage(maxSize: CGSize, maxBytes: Float = 2 * 1024 * 1024) -> UIImage? {
        //计算尺寸缩放比例
        let sizeScale = max(size.width / maxSize.width,
                            size.height / maxSize.height)
        //计算大小缩放比例
        let imageBytes = Float(size.width * size.height * 4)
        let byteScale = sqrtf(imageBytes / maxBytes)

        //取最大缩放比
        let scale = max(sizeScale, CGFloat(byteScale))
        // 方向尺寸都OK
        guard imageOrientation != .up || scale > 1.0  else {
            return self
        }

        let newSize = CGSize(width: size.width / scale, height: size.height / scale)
        UIGraphicsBeginImageContext(newSize)
        draw(in: .init(origin: .zero, size: newSize))
        let fixImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return fixImage
    }

    func imageData() -> Data? {
        return self.jpegData(compressionQuality: 1.0)
    }

    func base64String() -> String? {
        return imageData()?.base64EncodedString(options: .lineLength64Characters)
    }

    func crop(rect: CGRect) -> UIImage? {
        guard let imageRef = cgImage?.cropping(to: rect)  else {
            return nil
        }
        return UIImage(cgImage: imageRef)
    }

    func blend(with grayImage: UIImage, backgroundColor hexColor: Int) -> UIImage? {
        guard let inputCGImage = cgImage else {
            return nil
        }

        let inputWidth = inputCGImage.width
        let inputHeight = inputCGImage.height

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let bytesPerPixel = 4
        let bitsPerComponent = 8

        let inputBytesPerRow = bytesPerPixel * inputWidth

        let inputPixels = UnsafeMutableRawPointer.allocate(byteCount: inputWidth * inputHeight,
                                                           alignment: MemoryLayout<UInt32>.size)
        defer {
            inputPixels.deallocate()
        }

        let bitmapInfo: CGBitmapInfo = [
            .byteOrder32Big,
            CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        ]
        guard let context = CGContext(data: inputPixels,
                                      width: inputWidth,
                                      height: inputHeight,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: inputBytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else {
                                        return nil
        }

        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: inputWidth, height: inputHeight))

        guard let ghostCGImage = grayImage.cgImage else {
            return nil
        }

        // 2.1 Calculate the size & position of the ghost
        let ghostImageAspectRatio = grayImage.size.height / grayImage.size.height
        let targetSize = CGFloat(inputWidth)
        let ghostSize = CGSize(width: targetSize, height: targetSize / ghostImageAspectRatio)
        let ghostOrigin = CGPoint.zero

        // 2.2 Scale & Get pixels of the ghost
        let ghostBytesPerRow = bytesPerPixel * Int(ghostSize.width)
        let ghostPixels = UnsafeMutableRawPointer.allocate(byteCount: Int(ghostSize.width * ghostSize.height),
                                                           alignment: MemoryLayout<UInt32>.size)
        defer {
            ghostPixels.deallocate()
        }

        guard let ghostContext = CGContext(data: ghostPixels,
                                           width: Int(ghostSize.width),
                                           height: Int(ghostSize.height),
                                           bitsPerComponent: bitsPerComponent,
                                           bytesPerRow: ghostBytesPerRow,
                                           space: colorSpace,
                                           bitmapInfo: bitmapInfo.rawValue) else {
                                            return nil
        }
        ghostContext.draw(ghostCGImage, in: .init(origin: .zero, size: ghostSize))

        // 2.3 Blend each pixel
        //background color
        //0x开头的十六进制转换成的颜色
        let rBack = CGFloat((hexColor & 0xFF0000) >> 16)
        let gBack = CGFloat((hexColor & 0xFF00) >> 8)
        let bBack = CGFloat(hexColor & 0xFF)

        let offsetPixelCountForInput = ghostOrigin.y * CGFloat(inputWidth) + ghostOrigin.x
        for j in 0..<Int(ghostSize.height) {
            for i in 0..<Int(ghostSize.width) {
                var inputPixel = inputPixels + j * inputWidth + i + Int(offsetPixelCountForInput)
                let inputColor = inputPixel.assumingMemoryBound(to: UInt32.self).pointee

                let ghostPixel = ghostPixels + j * Int(ghostSize.width) + i
                let ghostColor = ghostPixel.assumingMemoryBound(to: UInt32.self).pointee

                let confidence = CGFloat(ghostColor.R + ghostColor.G + ghostColor.B) / 3 / 255.0

                //用置信度标识透明度
                let alpha = confidence
                var newR = inputColor.R * UInt32(alpha) + UInt32(rBack * (1 - alpha))
                var newG = inputColor.G * UInt32(alpha) + UInt32(gBack * (1 - alpha))
                var newB = inputColor.B * UInt32(alpha) + UInt32(bBack * (1 - alpha))

                 //Clamp, not really useful here :p
                newR = max(0, min(255, newR))
                newG = max(0, min(255, newG))
                newB = max(0, min(255, newB))

                inputPixel = inputPixel.advanced(by: Int(UInt32.rgbAMake(r: newR, g: newG, b: newB, a: inputColor.A)))
            }
        }

        // 4. Create a new UIImage
        guard let newCGImage = context.makeImage() else {
            return nil
        }
        return  UIImage(cgImage: newCGImage)
    }
}

extension UIImage {
    convenience init?(base64String string: String) {
        guard let data = Data(base64Encoded: string) else {
            return nil
        }
        self.init(data: data)
    }
}
