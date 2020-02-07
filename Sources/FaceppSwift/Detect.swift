//
//  Detect.swift
//  facepp
//
//  Created by 姜振华 on 2020/2/3.
//

import Foundation

public struct DetectOption: RequestProtocol {
    
    /// 是否检测并返回人脸关键点。合法值为：
    public enum ReturnLandmark: Int {
        /// 无特征点
        case no = 0
        /// 83个特征点
        case baisc
        /// 106特征点
        case all
    }
    
    /// 是否检测并返回根据人脸特征判断出的年龄、性别、情绪等属性。合法值为：
    public enum ReturnbAttributes: String, Option {
        case gender, age, smiling, headpose, facequality, blur, eyestatus,
        emotion, ethnicity, beauty, mouthstatus, eyegaze, skinstatus
        case none
    }
    
    /// 是否检测并返回人脸关键点
    public var returnLandmark = ReturnLandmark.no
    /// 是否检测并返回根据人脸特征判断出的年龄、性别、情绪等属性
    public var returnAttributes = Set(arrayLiteral: ReturnbAttributes.none)
    ///是否检测并返回所有人脸的人脸关键点和人脸属性。如果不使用此功能，则本 API 只会对人脸面积最大的五个人脸分析人脸关键点和人脸属性
    public var calculateAll: Bool?
    
    public var imageURL: URL?
    public var imageFile: URL?
    public var imageBase64: String?
    
    /// 是否指定人脸框位置进行人脸检测。
    public var faceRectangele: FaceRectangle?
    /// 颜值评分分数区间的最小值。默认为0
    public var beautyScoreMin = 0
    /// beauty_score_max
    public var beautyScoreNax = 100
    
    var requsetURL: URL? {
        return kFaceppBaseURL?.appendingPathComponent("detect")
    }
    
    func paramsCheck() -> Bool {
        return imageFile != nil || imageURL != nil || imageBase64 != nil
    }
    
    func params(apiKey: String, apiSecret: String) -> Params {
        var params: Params = [
            "api_key": apiKey,
            "api_secret": apiSecret
        ]
        params["return_landmark"] = returnLandmark.rawValue
        params["return_attributes"] = Array(returnAttributes)
            .map { $0.rawValue }
            .joined(separator: ",")
        if let ret = calculateAll {
            params["calculate_all"] = ret ? 1 : 0
        }
        if let rectangle = faceRectangele {
            params["face_rectangle"] = "\(String(describing: rectangle))"
        }
        params["beauty_score_min"] = beautyScoreMin
        params["beauty_score_max"] = beautyScoreNax
        var files = [Params]()
        if let url = imageFile, let data = try? Data(contentsOf: url) {
            files.append([
                "fieldName": "image_file",
                "fileType": url.pathExtension,
                "data": data
            ])
        } else if let data = imageBase64 {
            params["image_base64"] = data
        } else if let url = imageURL {
            params["image_url"] = url
        }
        return params
    }
}

public struct Attributes: Codable {
    
    public struct Threshold: Codable {
        public let threshold: Float
        public let value: Float
    }
    
    public struct EyeStatusInfo: Codable {
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
    
    public struct Age: Codable {
        let value: Int
    }
    /// 年龄分析结果。返回值为一个非负整数。
    public let age: Age?
    
    public struct Beauty: Codable {
        public let femaleScore: Float
        public let maleScore: Float
    }
    /// 颜值识别结果。返回值包含以下两个字段。每个字段的值是一个浮点数，范围 [0,100]，小数点后 3 位有效数字。
    public let beauty: Beauty?
    
    public struct Blur: Codable {
        public let blurness: Threshold
        public let gaussianblur: Threshold
        public let motionblur: Threshold
    }
    /// 人脸模糊分析结果
    public let blur: Blur?
    
    public struct Emotion: Codable {
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
    
    public struct EyeStatus: Codable {
        public let leftEyeStatus: EyeStatusInfo
        public let rightEyeStatus: EyeStatusInfo
    }
    
    /// 眼睛状态信息
    public let eyestatus: EyeStatus?
    /// 人脸质量判断结果
    public let facequality: Threshold?
    
    public struct HeadPose: Codable {
        /// 抬头
        public let pitchAngle: Double
        /// 旋转（平面旋转）
        public let rollAngle: Double
        /// 摇头
        public let yawAngle: Double
    }
    /// 人脸姿势分析结果
    public let headpose: HeadPose?
    
    public struct SkinStatus: Codable {
        /// 健康
        let health: Float
        /// 色斑
        let stain: Float
        /// 青春痘
        let acne: Float
        /// 黑眼圈
        let darkCircle: Float
    }
    
    /// 面部特征识别结果，包括以下字段。每个字段的值都是一个浮点数，范围 [0,100]，小数点后 3 位有效数字
    public let skinstatus: SkinStatus?
    
    public struct EyeGazeInfo: Codable {
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
    
    public struct EyeGaze: Codable {
        /// 左眼的位置与视线状态
        public let leftEyeGaze: EyeGazeInfo
        /// 右眼的位置与视线状态
        public let rightEyeGaze: EyeGazeInfo
    }
    
    /// 眼球位置与视线方向信息
    public let eyegaze: EyeGaze?
    
    public struct MouthStatus: Codable {
        /// 嘴部被医用口罩或呼吸面罩遮挡的置信度
        let surgicalMaskOrRespirator: Float
        /// 嘴部被其他物体遮挡的置信度
        let otherOcclusion: Float
        /// 嘴部没有遮挡且闭上的置信度
        let close: Float
        /// 嘴部没有遮挡且张开的置信度
        let open: Float
    }
    /// 嘴部状态信息
    public let mouthstatus: MouthStatus?
    /// 笑容分析结果
    public let smile: Threshold?
}

public struct FaceRectangle: Codable {
    var top: UInt = 0
    var left: UInt = 0
    var width: UInt = 0
    var height: UInt = 0
}

public struct LandMark: Codable {
    public struct LandMarkInfo: Codable {
        let x: Float
        let y: Float
    }
    // MARK: - 83个特征点：https://console.faceplusplus.com.cn/documents/5671270
    let contourChin: LandMarkInfo
    let contourLeft1: LandMarkInfo
    let contourLeft2: LandMarkInfo
    let contourLeft3: LandMarkInfo
    let contourLeft4: LandMarkInfo
    let contourLeft5: LandMarkInfo
    let contourLeft6: LandMarkInfo
    let contourLeft7: LandMarkInfo
    let contourLeft8: LandMarkInfo
    let contourLeft9: LandMarkInfo
    let contourRight1: LandMarkInfo
    let contourRight2: LandMarkInfo
    let contourRight3: LandMarkInfo
    let contourRight4: LandMarkInfo
    let contourRight5: LandMarkInfo
    let contourRight6: LandMarkInfo
    let contourRight7: LandMarkInfo
    let contourRight8: LandMarkInfo
    let contourRight9: LandMarkInfo
    let leftEyeBottom: LandMarkInfo
    let leftEyeCenter: LandMarkInfo
    let leftEyeLeftCorner: LandMarkInfo
    let leftEyeLowerLeftQuarter: LandMarkInfo
    let leftEyeLowerRightQuarter: LandMarkInfo
    let leftEyePupil: LandMarkInfo
    let leftEyeRightCorner: LandMarkInfo
    let leftEyeTop: LandMarkInfo
    let leftEyeUpperLeftQuarter: LandMarkInfo
    let leftEyeUpperRightQuarter: LandMarkInfo
    let leftEyebrowLeftCorner: LandMarkInfo
    let leftEyebrowLowerLeftQuarter: LandMarkInfo
    let leftEyebrowLowerMiddle: LandMarkInfo
    let leftEyebrowLowerRightQuarter: LandMarkInfo
    let leftEyebrowRightCorner: LandMarkInfo?
    let leftEyebrowUpperLeftQuarter: LandMarkInfo
    let leftEyebrowUpperMiddle: LandMarkInfo
    let leftEyebrowUpperRightQuarter: LandMarkInfo
    let mouthLeftCorner: LandMarkInfo
    let mouthLowerLipBottom: LandMarkInfo
    let mouthLowerLipLeftContour1: LandMarkInfo
    let mouthLowerLipLeftContour2: LandMarkInfo
    let mouthLowerLipLeftContour3: LandMarkInfo
    let mouthLowerLipRightContour1: LandMarkInfo
    let mouthLowerLipRightContour2: LandMarkInfo
    let mouthLowerLipRightContour3: LandMarkInfo
    let mouthLowerLipTop: LandMarkInfo
    let mouthRightCorner: LandMarkInfo
    let mouthUpperLipBottom: LandMarkInfo
    let mouthUpperLipLeftContour1: LandMarkInfo
    let mouthUpperLipLeftContour2: LandMarkInfo
    let mouthUpperLipLeftContour3: LandMarkInfo
    let mouthUpperLipRightContour1: LandMarkInfo
    let mouthUpperLipRightContour2: LandMarkInfo
    let mouthUpperLipRightContour3: LandMarkInfo
    let mouthUpperLipTop: LandMarkInfo
    let noseContourLeft1: LandMarkInfo?
    let noseContourLeft2: LandMarkInfo?
    let noseContourLeft3: LandMarkInfo?
    let noseContourLowerMiddle: LandMarkInfo?
    let noseContourRight1: LandMarkInfo?
    let noseContourRight2: LandMarkInfo?
    let noseContourRight3: LandMarkInfo?
    let noseLeft: LandMarkInfo?
    let noseRight: LandMarkInfo?
    let noseTip: LandMarkInfo
    let rightEyeBottom: LandMarkInfo
    let rightEyeCenter: LandMarkInfo
    let rightEyeLeftCorner: LandMarkInfo
    let rightEyeLowerLeftQuarter: LandMarkInfo
    let rightEyeLowerRightQuarter: LandMarkInfo
    let rightEyePupil: LandMarkInfo
    let rightEyeRightCorner: LandMarkInfo
    let rightEyeTop: LandMarkInfo
    let rightEyeUpperLeftQuarter: LandMarkInfo
    let rightEyeUpperRightQuarter: LandMarkInfo
    let rightEyebrowLeftCorner: LandMarkInfo?
    let rightEyebrowLowerLeftQuarter: LandMarkInfo
    let rightEyebrowLowerMiddle: LandMarkInfo
    let rightEyebrowLowerRightQuarter: LandMarkInfo
    let rightEyebrowRightCorner: LandMarkInfo
    let rightEyebrowUpperLeftQuarter: LandMarkInfo
    let rightEyebrowUpperMiddle: LandMarkInfo
    let rightEyebrowUpperRightQuarter: LandMarkInfo
    
    // MARK: - 106个特征点：https://console.faceplusplus.com.cn/documents/13207408
    let contourLeft10: LandMarkInfo?
    let contourLeft11: LandMarkInfo?
    let contourLeft12: LandMarkInfo?
    let contourLeft13: LandMarkInfo?
    let contourLeft14: LandMarkInfo?
    let contourLeft15: LandMarkInfo?
    let contourLeft16: LandMarkInfo?
    let contourRight10: LandMarkInfo?
    let contourRight11: LandMarkInfo?
    let contourRight12: LandMarkInfo?
    let contourRight13: LandMarkInfo?
    let contourRight14: LandMarkInfo?
    let contourRight15: LandMarkInfo?
    let contourRight16: LandMarkInfo?
    let leftEyebrowUpperRightCorner: LandMarkInfo?
    let leftEyebrowLowerRightCorner: LandMarkInfo?
    let rightEyebrowUpperLeftCorner: LandMarkInfo?
    let rightEyebrowLowerLeftCorner: LandMarkInfo?
    let noseBridge1: LandMarkInfo?
    let noseBridge2: LandMarkInfo?
    let noseBridge3: LandMarkInfo?
    let noseLeftContour1: LandMarkInfo?
    let noseLeftContour2: LandMarkInfo?
    let noseLeftContour3: LandMarkInfo?
    let noseLeftContour4: LandMarkInfo?
    let noseLeftContour5: LandMarkInfo?
    let noseMiddleContour: LandMarkInfo?
    let noseRightContour1: LandMarkInfo?
    let noseRightContour2: LandMarkInfo?
    let noseRightContour3: LandMarkInfo?
    let noseRightContour4: LandMarkInfo?
    let noseRightContour5: LandMarkInfo?
    let mouthUpperLipLeftContour4: LandMarkInfo?
    let mouthUupperLipRightContour4: LandMarkInfo?
}

public struct Face: Codable {
    let faceToken: String
    let faceRectangle: FaceRectangle
    let attributes: Attributes?
    let landmark: LandMark?
}

public struct DetectResponse: ResponseProtocol {
    
    public let requestId: String?
    public let imageId: String?
    public let timeUsed: Int?
    public let errorMessage: String?
    public let faces: [Face]?
}

extension Set where Element == DetectOption.ReturnbAttributes {
    static var all: Set<DetectOption.ReturnbAttributes> {
        return Set(Element.allCases.filter { $0 != .none })
    }
}
