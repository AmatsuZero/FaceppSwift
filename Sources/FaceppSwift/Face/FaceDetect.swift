//
//  Detect.swift
//  facepp
//
//  Created by 姜振华 on 2020/2/3.
// - Wiki: https://console.faceplusplus.com.cn/documents/4888373
//

import Foundation

@objc(FppFaceDetectOption)
@objcMembers public class FaceDetectOption: FaceppBaseRequest {
    
    /// 是否检测并返回人脸关键点。合法值为：
    @objc(FppFaceDetectReturnLandmark)
    public enum ReturnLandmark: Int {
        /// 无特征点
        case no = 0
        /// 83个特征点
        case baisc
        /// 106特征点
        case all
    }
    
    /// 是否检测并返回根据人脸特征判断出的年龄、性别、情绪等属性。合法值为：
    public enum ReturnAttributes: String, Option {
        case gender, age, smiling, headpose, facequality, blur, eyestatus,
        emotion, ethnicity, beauty, mouthstatus, eyegaze, skinstatus
        case none
    }
    
    /// 是否检测并返回人脸关键点
    public var returnLandmark = ReturnLandmark.no
    /// 是否检测并返回根据人脸特征判断出的年龄、性别、情绪等属性
    @nonobjc public var returnAttributes: Set<ReturnAttributes> = [.none]
    ///是否检测并返回所有人脸的人脸关键点和人脸属性。如果不使用此功能，则本 API 只会对人脸面积最大的五个人脸分析人脸关键点和人脸属性
    @nonobjc public var calculateAll: Bool?
    /// 是否检测并返回所有人脸的人脸关键点和人脸属性。如果不使用此功能，则本 API 只会对人脸面积最大的五个人脸分析人脸关键点和人脸属性 (布尔值)
    @objc public var calculateAllObjc: NSNumber? {
        set {
            calculateAll = newValue?.boolValue
        }
        get {
            calculateAll != nil ? NSNumber(booleanLiteral: calculateAll!) : nil
        }
    }
    /// 是否检测并返回根据人脸特征判断出的年龄、性别、情绪等属性
    @objc public var returnAttributesString: Set<String> {
        set {
            returnAttributes = Set(newValue.compactMap { FaceDetectOption.ReturnAttributes(rawValue: $0) })
        }
        get {
            Set(returnAttributes.map { $0.rawValue })
        }
    }
    
    /// 是否指定人脸框位置进行人脸检测。
    public var faceRectangle: FaceppRectangle?
    /// 颜值评分分数区间的最小值。默认为0
    public var beautyScoreMin = 0
    /// 颜值评分分数区间的最大值。默认为100
    public var beautyScoreMax = 100
    
    override var requsetURL: URL? {
        return kFaceppV3URL?.appendingPathComponent("detect")
    }
    
    public override init() {
        super.init()
    }
    
    public required init(params: [String: Any]) {
        if let value = params["beauty_score_min"] as? Int {
            beautyScoreMin = value
        } else {
            beautyScoreMin = 0
        }
        if let value = params["beauty_score_max"] as? Int {
            beautyScoreMax = value
        } else {
            beautyScoreMax = 100
        }
        if let value = params["return_landmark"] as? Int {
            returnLandmark = FaceDetectOption.ReturnLandmark(rawValue: value) ?? .no
        } else {
            returnLandmark = .no
        }
        if let value = params["return_attributes"] as? String {
            returnAttributes = Set(value
                .components(separatedBy: ",")
                .compactMap {FaceDetectOption.ReturnAttributes(rawValue: $0) })
        } else {
            returnAttributes = [.none]
        }
        if let value = params["face_rectangle"] as? String {
            faceRectangle = FaceppRectangle(string: value)
        }
        if let value = params["calculate_all"] as? Int {
            calculateAll = value == 1
        }
        super.init(params: params)
    }
    
    override func params() throws -> (Params, [Params]?) {
        var (params, files) = try super.params()
        params["return_landmark"] = returnLandmark.rawValue
        params["return_attributes"] = returnAttributes.map { $0.rawValue }.joined(separator: ",")
        if let ret = calculateAll {
            params["calculate_all"] = ret ? 1 : 0
        }
        if let rectangle = faceRectangle {
            params["face_rectangle"] = "\(String(describing: rectangle))"
        }
        params["beauty_score_min"] = beautyScoreMin
        params["beauty_score_max"] = beautyScoreMax
        return (params, files)
    }
}

public struct Attributes: Codable, Hashable {
    
    public struct Threshold: Codable, Hashable {
        public let threshold: Float
        public let value: Float
    }
    
    public struct EyeStatusInfo: Codable, Hashable {
        /// 眼睛被遮挡的置信度
        public let occlusion: Float
        /// 佩戴普通眼镜且睁眼的置信度
        public let normalGlassEyeOpen: Float
        /// 佩戴普通眼镜且闭眼的置信度
        public let normalGlassEyeClose: Float
        /// 不戴眼镜且睁眼的置信度
        public let noGlassEyeOpen: Float
        /// 不戴眼镜且闭眼的置信度
        public let noGlassEyeClose: Float
        /// 佩戴墨镜的置信度
        public let darkGlasses: Float
    }
    
    public struct Age: Codable, Hashable {
        public let value: Int
    }
    /// 年龄分析结果。返回值为一个非负整数。
    public let age: Age?
    
    public struct Beauty: Codable, Hashable {
        public let femaleScore: Float
        public let maleScore: Float
    }
    /// 颜值识别结果。返回值包含以下两个字段。每个字段的值是一个浮点数，范围 [0,100]，小数点后 3 位有效数字。
    public let beauty: Beauty?
    
    public struct Blur: Codable, Hashable {
        public let blurness: Threshold
        public let gaussianblur: Threshold
        public let motionblur: Threshold
    }
    /// 人脸模糊分析结果
    public let blur: Blur?
    
    public struct Emotion: Codable, Hashable {
        public let anger: Float
        public let disgust: Float
        public let fear: Float
        public let happiness: Float
        public let neutral: Float
        public let sadness: Float
        public let surprise: Float
    }
    /// 情绪识别结果。返回值包含以下字段。每个字段的值都是一个浮点数，范围 [0,100]，小数点后 3 位有效数字
    public let emotion: Emotion?
    
    public struct EyeStatus: Codable, Hashable {
        public let leftEyeStatus: EyeStatusInfo
        public let rightEyeStatus: EyeStatusInfo
    }
    
    /// 眼睛状态信息
    public let eyestatus: EyeStatus?
    /// 人脸质量判断结果
    public let facequality: Threshold?
    /// 人脸姿势分析结果
    public let headpose: FacialHeadPose?
    
    public struct SkinStatus: Codable, Hashable {
        /// 健康
        public let health: Float
        /// 色斑
        public let stain: Float
        /// 青春痘
        public let acne: Float
        /// 黑眼圈
        public let darkCircle: Float
    }
    
    /// 面部特征识别结果，包括以下字段。每个字段的值都是一个浮点数，范围 [0,100]，小数点后 3 位有效数字
    public let skinstatus: SkinStatus?
    
    public struct EyeGazeInfo: Codable, Hashable {
        /// 眼球中心位置的 X 轴坐标
        public let positionXCoordinate: Float
        /// 眼球中心位置的 Y 轴坐标
        public let positionYCoordinate: Float
        /// 眼球视线方向向量的 X 轴分量
        public let vectorXComponent: Float
        /// 眼球视线方向向量的 Y 轴分量
        public let vectorYComponent: Float
        /// 眼球视线方向向量的 Z 轴分量
        public let vectorZComponent: Float
    }
    
    public struct EyeGaze: Codable, Hashable {
        /// 左眼的位置与视线状态
        public let leftEyeGaze: EyeGazeInfo
        /// 右眼的位置与视线状态
        public let rightEyeGaze: EyeGazeInfo
    }
    
    /// 眼球位置与视线方向信息
    public let eyegaze: EyeGaze?
    
    public struct MouthStatus: Codable, Hashable {
        /// 嘴部被医用口罩或呼吸面罩遮挡的置信度
        public let surgicalMaskOrRespirator: Float
        /// 嘴部被其他物体遮挡的置信度
        public let otherOcclusion: Float
        /// 嘴部没有遮挡且闭上的置信度
        public let close: Float
        /// 嘴部没有遮挡且张开的置信度
        public let open: Float
    }
    /// 嘴部状态信息
    public let mouthstatus: MouthStatus?
    /// 笑容分析结果
    public let smile: Threshold?
}

@objc(FppRectangle)
@objcMembers public final class FaceppRectangle: NSObject, Codable {
    public var top = 0
    public var left = 0
    public var width = 0
    public var height = 0
    
    @objc public init(top: Int, left: Int, width: Int, height: Int) {
        self.top = top
        self.left = left
        self.width = width
        self.height = height
    }
    
    @objc public init?(string: String) {
        let pts = string
            .components(separatedBy: ",")
            .compactMap { Int($0) }
        guard pts.count == 4 else {
            return nil
        }
        top = pts[0]
        left = pts[1]
        width = pts[2]
        height = pts[3]
    }
    
    public override var description: String {
        return "\(top),\(left),\(width),\(height)"
    }
}

public struct FaceppPoint: Codable, Hashable {
    public let x: Float
    public let y: Float
    
    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
}

public struct LandMark: Codable, Hashable {
    // MARK: - 83个特征点：https://console.faceplusplus.com.cn/documents/5671270
    public let contourChin: FaceppPoint
    public let contourLeft1: FaceppPoint
    public let contourLeft2: FaceppPoint
    public let contourLeft3: FaceppPoint
    public let contourLeft4: FaceppPoint
    public let contourLeft5: FaceppPoint
    public let contourLeft6: FaceppPoint
    public let contourLeft7: FaceppPoint
    public let contourLeft8: FaceppPoint
    public let contourLeft9: FaceppPoint
    public let contourRight1: FaceppPoint
    public let contourRight2: FaceppPoint
    public let contourRight3: FaceppPoint
    public let contourRight4: FaceppPoint
    public let contourRight5: FaceppPoint
    public let contourRight6: FaceppPoint
    public let contourRight7: FaceppPoint
    public let contourRight8: FaceppPoint
    public let contourRight9: FaceppPoint
    public let leftEyeBottom: FaceppPoint
    public let leftEyeCenter: FaceppPoint
    public let leftEyeLeftCorner: FaceppPoint
    public let leftEyeLowerLeftQuarter: FaceppPoint
    public let leftEyeLowerRightQuarter: FaceppPoint
    public let leftEyePupil: FaceppPoint
    public let leftEyeRightCorner: FaceppPoint
    public let leftEyeTop: FaceppPoint
    public let leftEyeUpperLeftQuarter: FaceppPoint
    public let leftEyeUpperRightQuarter: FaceppPoint
    public let leftEyebrowLeftCorner: FaceppPoint
    public let leftEyebrowLowerLeftQuarter: FaceppPoint
    public let leftEyebrowLowerMiddle: FaceppPoint
    public let leftEyebrowLowerRightQuarter: FaceppPoint
    public let leftEyebrowRightCorner: FaceppPoint?
    public let leftEyebrowUpperLeftQuarter: FaceppPoint
    public let leftEyebrowUpperMiddle: FaceppPoint
    public let leftEyebrowUpperRightQuarter: FaceppPoint
    public let mouthLeftCorner: FaceppPoint
    public let mouthLowerLipBottom: FaceppPoint
    public let mouthLowerLipLeftContour1: FaceppPoint
    public let mouthLowerLipLeftContour2: FaceppPoint
    public let mouthLowerLipLeftContour3: FaceppPoint
    public let mouthLowerLipRightContour1: FaceppPoint
    public let mouthLowerLipRightContour2: FaceppPoint
    public let mouthLowerLipRightContour3: FaceppPoint
    public let mouthLowerLipTop: FaceppPoint
    public let mouthRightCorner: FaceppPoint
    public let mouthUpperLipBottom: FaceppPoint
    public let mouthUpperLipLeftContour1: FaceppPoint
    public let mouthUpperLipLeftContour2: FaceppPoint
    public let mouthUpperLipLeftContour3: FaceppPoint
    public let mouthUpperLipRightContour1: FaceppPoint
    public let mouthUpperLipRightContour2: FaceppPoint
    public let mouthUpperLipRightContour3: FaceppPoint
    public let mouthUpperLipTop: FaceppPoint
    public let noseContourLeft1: FaceppPoint?
    public let noseContourLeft2: FaceppPoint?
    public let noseContourLeft3: FaceppPoint?
    public let noseContourLowerMiddle: FaceppPoint?
    public let noseContourRight1: FaceppPoint?
    public let noseContourRight2: FaceppPoint?
    public let noseContourRight3: FaceppPoint?
    public let noseLeft: FaceppPoint?
    public let noseRight: FaceppPoint?
    public let noseTip: FaceppPoint
    public let rightEyeBottom: FaceppPoint
    public let rightEyeCenter: FaceppPoint
    public let rightEyeLeftCorner: FaceppPoint
    public let rightEyeLowerLeftQuarter: FaceppPoint
    public let rightEyeLowerRightQuarter: FaceppPoint
    public let rightEyePupil: FaceppPoint
    public let rightEyeRightCorner: FaceppPoint
    public let rightEyeTop: FaceppPoint
    public let rightEyeUpperLeftQuarter: FaceppPoint
    public let rightEyeUpperRightQuarter: FaceppPoint
    public let rightEyebrowLeftCorner: FaceppPoint?
    public let rightEyebrowLowerLeftQuarter: FaceppPoint
    public let rightEyebrowLowerMiddle: FaceppPoint
    public let rightEyebrowLowerRightQuarter: FaceppPoint
    public let rightEyebrowRightCorner: FaceppPoint
    public let rightEyebrowUpperLeftQuarter: FaceppPoint
    public let rightEyebrowUpperMiddle: FaceppPoint
    public let rightEyebrowUpperRightQuarter: FaceppPoint
    
    // MARK: - 106个特征点：https://console.faceplusplus.com.cn/documents/13207408
    public let contourLeft10: FaceppPoint?
    public let contourLeft11: FaceppPoint?
    public let contourLeft12: FaceppPoint?
    public let contourLeft13: FaceppPoint?
    public let contourLeft14: FaceppPoint?
    public let contourLeft15: FaceppPoint?
    public let contourLeft16: FaceppPoint?
    public let contourRight10: FaceppPoint?
    public let contourRight11: FaceppPoint?
    public let contourRight12: FaceppPoint?
    public let contourRight13: FaceppPoint?
    public let contourRight14: FaceppPoint?
    public let contourRight15: FaceppPoint?
    public let contourRight16: FaceppPoint?
    public let leftEyebrowUpperRightCorner: FaceppPoint?
    public let leftEyebrowLowerRightCorner: FaceppPoint?
    public let rightEyebrowUpperLeftCorner: FaceppPoint?
    public let rightEyebrowLowerLeftCorner: FaceppPoint?
    public let noseBridge1: FaceppPoint?
    public let noseBridge2: FaceppPoint?
    public let noseBridge3: FaceppPoint?
    public let noseLeftContour1: FaceppPoint?
    public let noseLeftContour2: FaceppPoint?
    public let noseLeftContour3: FaceppPoint?
    public let noseLeftContour4: FaceppPoint?
    public let noseLeftContour5: FaceppPoint?
    public let noseMiddleContour: FaceppPoint?
    public let noseRightContour1: FaceppPoint?
    public let noseRightContour2: FaceppPoint?
    public let noseRightContour3: FaceppPoint?
    public let noseRightContour4: FaceppPoint?
    public let noseRightContour5: FaceppPoint?
    public let mouthUpperLipLeftContour4: FaceppPoint?
    public let mouthUupperLipRightContour4: FaceppPoint?
}

public struct Face: Codable, Hashable {
    public let faceToken: String
    public let faceRectangle: FaceppRectangle
    public let attributes: Attributes?
    public let landmark: LandMark?
}

public struct FaceDetectResponse: FaceppResponseProtocol, Hashable {
    public let requestId: String?
    public let imageId: String?
    public let timeUsed: Int?
    public let errorMessage: String?
    public let faces: [Face]?
}

extension Set where Element == FaceDetectOption.ReturnAttributes {
    public static var all: Set<FaceDetectOption.ReturnAttributes> {
        return Set(Element.allCases.filter { $0 != .none })
    }
}

public extension LandMark {
    func basicPoints() -> [FaceppPoint] {
        return [
            contourChin,
            contourLeft1, contourLeft2, contourLeft3, contourLeft4,
            contourLeft5, contourLeft6, contourLeft7, contourLeft8, contourLeft9,
            contourRight1, contourRight2, contourRight3, contourRight4,
            contourRight5, contourRight6, contourRight7, contourRight8, contourRight9,
            leftEyeBottom, leftEyeCenter, leftEyeLeftCorner, leftEyeLowerLeftQuarter,
            leftEyeLowerRightQuarter, leftEyePupil, leftEyeRightCorner, leftEyeTop,
            leftEyeUpperLeftQuarter, leftEyeUpperRightQuarter, leftEyebrowUpperLeftQuarter, leftEyebrowUpperRightQuarter,
            mouthLeftCorner, mouthLowerLipBottom, mouthLowerLipLeftContour1, mouthLowerLipLeftContour2, mouthLowerLipLeftContour3,
            mouthLowerLipRightContour1, mouthLowerLipRightContour2, mouthLowerLipRightContour3, mouthLowerLipTop,
            noseContourLeft1, noseContourLeft2, noseContourLeft3, noseLeft, noseRight, noseTip,
            rightEyeBottom, rightEyeCenter, rightEyeLowerLeftQuarter, rightEyeLowerRightQuarter, rightEyePupil,
            rightEyeRightCorner, rightEyeTop, rightEyeUpperLeftQuarter, rightEyeUpperRightQuarter, rightEyebrowLeftCorner,
            rightEyebrowLowerLeftQuarter, rightEyebrowLowerMiddle, rightEyeLowerRightQuarter, rightEyebrowRightCorner,
            rightEyebrowUpperLeftQuarter, rightEyebrowUpperMiddle, rightEyebrowUpperMiddle, rightEyebrowUpperRightQuarter
            ].compactMap { $0 }
    }
}
