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
                    completioHandler: ((Error?, FaceDetectResponse?) -> Void)? = nil)
        -> URLSessionTask? {
            let option = FaceDetectOption(image: self)
            option.beautyScoreMin = beautyScoreMin
            option.beautyScoreMax = beautyScoreMax
            option.calculateAll = calculateAll
            option.returnLandmark = returnLandmark
            option.returnAttributes = returnAttributes
            let task = Facepp.detect(option: option) { error, resp in
                guard let block = completioHandler else {
                    self.fppDelegate?.image(self, taskDidEndWithEror: error, response: resp)
                    return
                }
                block(error, resp)
            }.request()
            fppDelegate?.image(self, option: option, taskDidBeigin: task)
            return task
    }

    @discardableResult
    func beautifyV2(whitening: UInt = 50,
                    smoothing: UInt = 50,
                    thinface: UInt = 50,
                    shrinkFace: UInt = 50,
                    enlargeEye: UInt = 50,
                    removeEyebrow: UInt = 50,
                    filterType: BeautifyV2Option.FilterType? = nil,
                    completionHandler: ( (Error?, BeautifyResponse?) -> Void)? = nil)
        -> URLSessionTask? {
            let option = BeautifyV2Option(image: self)
            option.whitening = whitening
            option.smoothing = whitening
            option.thinface = thinface
            option.shrinkFace = shrinkFace
            option.enlargeEye = enlargeEye
            option.removeEyebrow = removeEyebrow
            option.filterType = filterType
            let task = Facepp.beautifyV2(option: option) { error, resp in
                guard let block = completionHandler else {
                    self.fppDelegate?.image(self, taskDidEndWithEror: error, response: resp)
                    return
                }
                block(error, resp)
            }.request()
            fppDelegate?.image(self, option: option, taskDidBeigin: task)
            return task
    }

    @discardableResult
    func beautifyV1(whitening: UInt = 50,
                    smoothing: UInt = 50,
                    completionHandler: ((Error?, BeautifyResponse?) -> Void)? = nil) -> URLSessionTask? {
        let option = BeautifyV1Option(image: self)
        option.whitening = whitening
        option.smoothing = smoothing
        let task = Facepp.beautifyV1(option: option) { error, resp in
            guard let block = completionHandler else {
                self.fppDelegate?.image(self, taskDidEndWithEror: error, response: resp)
                return
            }
            block(error, resp)
        }.request()
        fppDelegate?.image(self, option: option, taskDidBeigin: task)
        return task
    }

    @discardableResult
    func facialFeatures(returnImageReset: Bool = false,
                        completionHandler: ((Error?, FacialFeaturesResponse?) -> Void)? = nil) -> URLSessionTask? {
        let option = FacialFeaturesOption(image: self)
        option.returnImageReset = returnImageReset
        let task = Facepp.facialFeatures(option: option) { error, resp in
            guard let block = completionHandler else {
                self.fppDelegate?.image(self, taskDidEndWithEror: error, response: resp)
                return
            }
            block(error, resp)
        }.request()
        fppDelegate?.image(self, option: option, taskDidBeigin: task)
        return task
    }

    @discardableResult
    func search(returnResultCount count: UInt = 1,
                faceRectangle frame: CGRect? = nil,
                completionHandler: ((Error?, SearchResponse?) -> Void)? = nil) -> URLSessionTask? {
        let option = SearchOption(image: self)
        option.returnResultCount = count
        option.faceRectangle = frame?.asFaceppRectangle()
        let task = FaceSet.search(option: option) { error, resp in
            guard let block = completionHandler else {
                self.fppDelegate?.image(self, taskDidEndWithEror: error, response: resp)
                return
            }
            block(error, resp)
        }
        fppDelegate?.image(self, option: option, taskDidBeigin: task)
        return task
    }

    @discardableResult
    func skinAnalyze(completionHandler: ((Error?, SkinAnalyzeResponse?) -> Void)? = nil) -> URLSessionTask? {
        let option = SkinAnalyzeOption(image: self)
        let task = Facepp.skinAnalyze(option: option) { error, resp in
            guard let block = completionHandler else {
                self.fppDelegate?.image(self, taskDidEndWithEror: error, response: resp)
                return
            }
            block(error, resp)
        }.request()
        fppDelegate?.image(self, option: option, taskDidBeigin: task)
        return task
    }

    @discardableResult
    func skinAnalyzeAdvanced(completionHandler: ((Error?, SkinAnalyzeAdvancedResponse?) -> Void)? = nil) -> URLSessionTask? {
        let option = SkinAnalyzeAdvancedOption(image: self)
        let task = Facepp.skinAnalyzeAdvanced(option: option) { error, resp in
            guard let block = completionHandler else {
                self.fppDelegate?.image(self, taskDidEndWithEror: error, response: resp)
                return
            }
            block(error, resp)
        }.request()
        return task
    }

    @discardableResult
    func denseLandmark(returnLandMark: Set<ThousandLandMarkOption.ReturnLandMark> = .all,
                       completionHandler: ((Error?, ThousandLandmarkResponse?) -> Void)? = nil) -> URLSessionTask? {
        let option = ThousandLandMarkOption(returnLandMark: returnLandMark)
        option.imageBase64 = base64String()
        option.metricsReporter = fppMetricsReport
        let task = Facepp.thousandLandmark(option: option) { error, resp in
            guard let block = completionHandler else {
                self.fppDelegate?.image(self, taskDidEndWithEror: error, response: resp)
                return
            }
            block(error, resp)
        }.request()
        fppDelegate?.image(self, option: option, taskDidBeigin: task)
        return task
    }

    @discardableResult
    func compare(faceRect rect1: CGRect? = nil,
                 with image2: UIImage,
                 faceRect2 rect2: CGRect? = nil,
                 completionHandler: ((Error?, CompareResponse?) -> Void)? = nil) -> URLSessionTask? {
        var option = CompareOption()
        option.metricsReporter = fppMetricsReport
        option.imageBase641 = base64String()
        option.faceRectangle1 = rect1?.asFaceppRectangle()
        option.imageBase642 = image2.base64String()
        option.faceRectangle2 = rect2?.asFaceppRectangle()
        let task = Facepp.compare(option: option) { error, resp in
            guard let block = completionHandler else {
                self.fppDelegate?.image(self, taskDidEndWithEror: error, response: resp)
                return
            }
            block(error, resp)
        }.request()
        fppDelegate?.image(self, option: option, taskDidBeigin: task)
        return task
    }

    @discardableResult
    static func compare(image1: UIImage,
                        faceRect1: CGRect? = nil,
                        image2: UIImage,
                        faceRect2: CGRect? = nil,
                        completionHandler: @escaping (Error?, CompareResponse?) -> Void) -> URLSessionTask? {
        return image1.compare(faceRect: faceRect1, with: image2,
                              faceRect2: faceRect2, completionHandler: completionHandler)
    }

    @discardableResult
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
        metricsReporter = metricsReporter
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

public extension BeautifyResponse {
    var resultImg: UIImage? {
        guard let str = result else {
            return nil
        }
        return UIImage(base64String: str)
    }
}

extension FacialFeaturesResponse {
    var resetImage: UIImage? {
        guard let str = imageReset else {
            return nil
        }
        return UIImage(base64String: str)
    }
}
