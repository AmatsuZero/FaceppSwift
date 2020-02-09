//
//  Detect.swift
//  facepp
//
//  Created by 姜振华 on 2020/2/3.
// - Wiki: https://console.faceplusplus.com.cn/documents/4888373
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
    /// 图片的 URL
    public var imageURL: URL?
    /// 图片的二进制文件，需要用 post multipart/form-data 的方式上传。
    public var imageFile: URL?
    /**
     base64 编码的二进制图片数据
     
     如果同时传入了 image_url、image_file 和 image_base64参数，本 API 使用顺序为image_file 优先，image_url最低。
     */
    public var imageBase64: String?
    
    /// 是否指定人脸框位置进行人脸检测。
    public var faceRectangle: FaceRectangle?
    /// 颜值评分分数区间的最小值。默认为0
    public var beautyScoreMin = 0
    /// beauty_score_max
    public var beautyScoreNax = 100
    
    var requsetURL: URL? {
        return kFaceppV3BaseURL?.appendingPathComponent("detect")
    }
    
    func paramsCheck() -> Bool {
        return imageFile != nil || imageURL != nil || imageBase64 != nil
    }
    
    func params(apiKey: String, apiSecret: String) -> (Params, [Params]?) {
        var params: Params = [
            "api_key": apiKey,
            "api_secret": apiSecret
        ]
        params["return_landmark"] = returnLandmark.rawValue
        params["return_attributes"] = returnAttributes.map { $0.rawValue }.joined(separator: ",")
        if let ret = calculateAll {
            params["calculate_all"] = ret ? 1 : 0
        }
        if let rectangle = faceRectangle {
            params["face_rectangle"] = "\(String(describing: rectangle))"
        }
        params["beauty_score_min"] = beautyScoreMin
        params["beauty_score_max"] = beautyScoreNax
        var files = [Params]()
        params["image_base64"] = imageBase64
        params["image_url"] = imageURL
        if let url = imageFile, let data = try? Data(contentsOf: url) {
            files.append([
                "fieldName": "image_file",
                "fileType": url.pathExtension,
                "data": data
            ])
        }
        return (params, files)
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
    /// 人脸姿势分析结果
    public let headpose: FacialHeadPose?
    
    public struct SkinStatus: Codable {
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

public struct FaceRectangle: Codable {
    public var top: Int = 0
    public var left: Int = 0
    public var width: Int = 0
    public var height: Int = 0
}

public struct LandMarkInfo: Codable {
    public let x: Float
    public let y: Float
}

public struct LandMark: Codable {
    // MARK: - 83个特征点：https://console.faceplusplus.com.cn/documents/5671270
    public let contourChin: LandMarkInfo
    public let contourLeft1: LandMarkInfo
    public let contourLeft2: LandMarkInfo
    public let contourLeft3: LandMarkInfo
    public let contourLeft4: LandMarkInfo
    public let contourLeft5: LandMarkInfo
    public let contourLeft6: LandMarkInfo
    public let contourLeft7: LandMarkInfo
    public let contourLeft8: LandMarkInfo
    public let contourLeft9: LandMarkInfo
    public let contourRight1: LandMarkInfo
    public let contourRight2: LandMarkInfo
    public let contourRight3: LandMarkInfo
    public let contourRight4: LandMarkInfo
    public let contourRight5: LandMarkInfo
    public let contourRight6: LandMarkInfo
    public let contourRight7: LandMarkInfo
    public let contourRight8: LandMarkInfo
    public let contourRight9: LandMarkInfo
    public let leftEyeBottom: LandMarkInfo
    public let leftEyeCenter: LandMarkInfo
    public let leftEyeLeftCorner: LandMarkInfo
    public let leftEyeLowerLeftQuarter: LandMarkInfo
    public let leftEyeLowerRightQuarter: LandMarkInfo
    public let leftEyePupil: LandMarkInfo
    public let leftEyeRightCorner: LandMarkInfo
    public let leftEyeTop: LandMarkInfo
    public let leftEyeUpperLeftQuarter: LandMarkInfo
    public let leftEyeUpperRightQuarter: LandMarkInfo
    public let leftEyebrowLeftCorner: LandMarkInfo
    public let leftEyebrowLowerLeftQuarter: LandMarkInfo
    public let leftEyebrowLowerMiddle: LandMarkInfo
    public let leftEyebrowLowerRightQuarter: LandMarkInfo
    public let leftEyebrowRightCorner: LandMarkInfo?
    public let leftEyebrowUpperLeftQuarter: LandMarkInfo
    public let leftEyebrowUpperMiddle: LandMarkInfo
    public let leftEyebrowUpperRightQuarter: LandMarkInfo
    public let mouthLeftCorner: LandMarkInfo
    public let mouthLowerLipBottom: LandMarkInfo
    public let mouthLowerLipLeftContour1: LandMarkInfo
    public let mouthLowerLipLeftContour2: LandMarkInfo
    public let mouthLowerLipLeftContour3: LandMarkInfo
    public let mouthLowerLipRightContour1: LandMarkInfo
    public let mouthLowerLipRightContour2: LandMarkInfo
    public let mouthLowerLipRightContour3: LandMarkInfo
    public let mouthLowerLipTop: LandMarkInfo
    public let mouthRightCorner: LandMarkInfo
    public let mouthUpperLipBottom: LandMarkInfo
    public let mouthUpperLipLeftContour1: LandMarkInfo
    public let mouthUpperLipLeftContour2: LandMarkInfo
    public let mouthUpperLipLeftContour3: LandMarkInfo
    public let mouthUpperLipRightContour1: LandMarkInfo
    public let mouthUpperLipRightContour2: LandMarkInfo
    public let mouthUpperLipRightContour3: LandMarkInfo
    public let mouthUpperLipTop: LandMarkInfo
    public let noseContourLeft1: LandMarkInfo?
    public let noseContourLeft2: LandMarkInfo?
    public let noseContourLeft3: LandMarkInfo?
    public let noseContourLowerMiddle: LandMarkInfo?
    public let noseContourRight1: LandMarkInfo?
    public let noseContourRight2: LandMarkInfo?
    public let noseContourRight3: LandMarkInfo?
    public let noseLeft: LandMarkInfo?
    public let noseRight: LandMarkInfo?
    public let noseTip: LandMarkInfo
    public let rightEyeBottom: LandMarkInfo
    public let rightEyeCenter: LandMarkInfo
    public let rightEyeLeftCorner: LandMarkInfo
    public let rightEyeLowerLeftQuarter: LandMarkInfo
    public let rightEyeLowerRightQuarter: LandMarkInfo
    public let rightEyePupil: LandMarkInfo
    public let rightEyeRightCorner: LandMarkInfo
    public let rightEyeTop: LandMarkInfo
    public let rightEyeUpperLeftQuarter: LandMarkInfo
    public let rightEyeUpperRightQuarter: LandMarkInfo
    public let rightEyebrowLeftCorner: LandMarkInfo?
    public let rightEyebrowLowerLeftQuarter: LandMarkInfo
    public let rightEyebrowLowerMiddle: LandMarkInfo
    public let rightEyebrowLowerRightQuarter: LandMarkInfo
    public let rightEyebrowRightCorner: LandMarkInfo
    public let rightEyebrowUpperLeftQuarter: LandMarkInfo
    public let rightEyebrowUpperMiddle: LandMarkInfo
    public let rightEyebrowUpperRightQuarter: LandMarkInfo
    
    // MARK: - 106个特征点：https://console.faceplusplus.com.cn/documents/13207408
    public let contourLeft10: LandMarkInfo?
    public let contourLeft11: LandMarkInfo?
    public let contourLeft12: LandMarkInfo?
    public let contourLeft13: LandMarkInfo?
    public let contourLeft14: LandMarkInfo?
    public let contourLeft15: LandMarkInfo?
    public let contourLeft16: LandMarkInfo?
    public let contourRight10: LandMarkInfo?
    public let contourRight11: LandMarkInfo?
    public let contourRight12: LandMarkInfo?
    public let contourRight13: LandMarkInfo?
    public let contourRight14: LandMarkInfo?
    public let contourRight15: LandMarkInfo?
    public let contourRight16: LandMarkInfo?
    public let leftEyebrowUpperRightCorner: LandMarkInfo?
    public let leftEyebrowLowerRightCorner: LandMarkInfo?
    public let rightEyebrowUpperLeftCorner: LandMarkInfo?
    public let rightEyebrowLowerLeftCorner: LandMarkInfo?
    public let noseBridge1: LandMarkInfo?
    public let noseBridge2: LandMarkInfo?
    public let noseBridge3: LandMarkInfo?
    public let noseLeftContour1: LandMarkInfo?
    public let noseLeftContour2: LandMarkInfo?
    public let noseLeftContour3: LandMarkInfo?
    public let noseLeftContour4: LandMarkInfo?
    public let noseLeftContour5: LandMarkInfo?
    public let noseMiddleContour: LandMarkInfo?
    public let noseRightContour1: LandMarkInfo?
    public let noseRightContour2: LandMarkInfo?
    public let noseRightContour3: LandMarkInfo?
    public let noseRightContour4: LandMarkInfo?
    public let noseRightContour5: LandMarkInfo?
    public let mouthUpperLipLeftContour4: LandMarkInfo?
    public let mouthUupperLipRightContour4: LandMarkInfo?
}

public struct Face: Codable {
    public let faceToken: String
    public let faceRectangle: FaceRectangle
    public let attributes: Attributes?
    public let landmark: LandMark?
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
