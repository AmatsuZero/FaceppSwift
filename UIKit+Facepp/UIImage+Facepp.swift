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
    
    @discardableResult
    func facialFeatures(returnImageReset: Bool = false,
                        completionHandler:@escaping (Error?, FacialFeaturesResponse?) -> Void) -> URLSessionTask? {
        let option = FacialFeaturesOption(image: self)
        option.returnImageReset = returnImageReset
        return Facepp.facialFeatures(option: option) { error, resp in
            guard let result = resp else {
                completionHandler(error, nil)
                return
            }
            completionHandler(error, result)
        }.request()
    }
    
    @discardableResult
    func search(returnResultCount count: UInt = 1,
                faceRectangle frame: CGRect? = nil,
                completionHandler:@escaping (Error?, SearchResponse?) -> Void) -> URLSessionTask? {
        let option = SearchOption(image: self)
        option.returnResultCount = count
        option.faceRectangle = frame?.asFaceppRectangle()
        return FaceSet.search(option: option) { error, resp in
            guard let result = resp else {
                completionHandler(error, nil)
                return
            }
            completionHandler(error, result)
        }
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
}

extension UIImage {
    convenience init?(base64String string: String) {
        guard let data = Data(base64Encoded: string) else {
            return nil
        }
        self.init(data: data)
    }
}
