//
//  FacialFeatures.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/9.
// - Wiki: https://console.faceplusplus.com.cn/documents/118131136
//

import Foundation

public class FacialFeaturesOption: FaceppBaseRequest {
    /// 是否返回人脸矫正后图片。合法值为：
    public var returnImageReset = false
    
    public required init(params: [String : Any]) {
        if let value = params["return_imagereset"] as? Int {
            returnImageReset = value == 1
        } else {
            returnImageReset = false
        }
        super.init(params: params)
    }
    
    public override init() {
        super.init()
    }

    override var requsetURL: URL? {
        return kFaceappV1URL?.appendingPathComponent("facialfeatures")
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, files) = try super.params()
        params["return_imagereset"] = returnImageReset ? 1 : 0
        return (params, files)
    }
}

public struct FacialFeaturesResponse: FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 人脸五官及轮廓的关键点坐标数组。
    public let denselandmark: DenseLandmark?
    /// 人脸矩形框的位置
    public let faceRectangle: FaceppRectangle?
    /// 被检测的图片在系统中的标识。
    public let imageId: String?
    /// 人脸矫正后的图片，jpg格式。base64 编码的二进制图片数据。
    public let imageReset: String?
    /// 人脸姿势分析结果
    public let headpose: FacialHeadPose?
    /// 人脸特征分析的结果
    public let result: FacialFeaturesResults?
}

/// 三庭
public struct Threeparts: Codable, Hashable {
    /// 返回三庭比例，保留至小数点后两位，若为0，则返回null
    public let partsRation: String?

    public enum FaceupResult: String, Codable {
        /// 上庭标准
        case faceupNormal = "faceup_normal"
        /// 上庭偏长
        case faceupLong = "faceup_long"
        /// 上庭偏短
        case faceupShort = "faceup_short"
    }

    public struct OnePart: Codable, Hashable {
        /// 上庭长度（若为0或无法判断，则返回null）
        public let faceupLength: Float?
        /// 上庭占比（若为0或无法判断，则返回null）
        public let faceupRatio: Float?
        /// 上庭判断结果（若为0或无法判断，则返回null）
        public let faceupResult: FaceupResult?
    }
    /// 返回上庭分析结果，距离单位为mm，保留至小数点后两位
    public let onePart: OnePart

    public enum FacemidResult: String, Codable {
        /// 中庭标准
        case facemidNormal = "facemid_normal"
        /// 中庭偏长
        case facemidLong = "facemid_long"
        /// 中庭偏短
        case facemidShort = "facemid_short"
    }

    public struct TwoPart: Codable, Hashable {
        /// 中庭长度（若为0或无法判断，则返回null）
        public let facemidLength: Float?
        /// 中庭占比（若为0或无法判断，则返回null）
        public let facemidRatio: Float?

        /// 中庭判断结果（若为0或无法判断，则返回null）
        public let facemidResult: FacemidResult?
    }
    /// 返回中庭分析结果，包括以下属性，距离单位为mm，保留至小数点后两位
    public let twoPart: TwoPart?

    public enum FacedownResult: String, Codable {
        /// 下庭标准
        case facedownNormal = "facedown_normal"
        /// 下庭偏长
        case facedownLong = "facedown_long"
        /// 下庭偏短
        case facedownShort = "facedown_short"
    }

    public struct ThreePart: Codable, Hashable {
        /// 下庭长度（若为0或无法判断，则返回null）
        public let facedownLength: Float?
        /// 下庭占比（若为0或无法判断，则返回null）
        public let facedownRatio: Float?

        /// 下庭判断结果
        public let facedownResult: FacedownResult?
    }
}

public struct FiveEyes: Codable, Hashable {
    /// 返回五眼比例，保留至小数点后两位，若出现0，则返回null
    public let eyesRatio: String?

    public enum RighteyeEmptyResult: String, Codable {
        /// 右眼外侧适中
        case righteyeEmptyNormal = "righteye_empty_normal"
        /// 右眼外侧偏窄
        case righteyeEmptyShort = "righteye_empty_short"
        /// 右眼外侧偏宽
        case righteyeEmptyLong = "righteye_empty_long"
    }

    public struct OneEye: Codable, Hashable {
        /// 右外眼角颧弓留白距离（若为0或无法判断，则返回null）
        public let righteyeEmptyLength: Float?
        /// 右外眼角颧弓留白占比（若为0或无法判断，则返回null）
        public let righteyeEmptyRatio: Float?
        /// 五眼右侧判断结果
        public let righteyeEmptyResult: RighteyeEmptyResult?
    }
    /// 返回右眼宽度分析结果，距离单位为mm，保留至小数点后两位，若为0，则返回null
    public let righteye: Float?

    public enum EyeinResult: String, Codable {
        /// 内眼角间距适中
        case eyeinNormal = "eyein_normal"
        /// 内眼角间距偏窄
        case eyeinShort = "eyein_short"
        /// 内眼角间距偏宽
        case eyeinLong = "eyein_long"
    }

    public struct ThreeEye: Codable, Hashable {
        /// 内眼角间距（若为0或无法判断，则返回null）
        public let eyeinLength: Float?
        /// 内眼角间距占比（若为0或无法判断，则返回null）
        public let eyeinRatio: Float?
        /// 内眼角间距判断结果（若为0或无法判断，则返回null）
        public let eyeinResult: EyeinResult?
    }
    /// 返回左眼宽度分析结果，距离单位为mm，保留至小数点后两位，若为0，则返回null
    public let lefteye: Float?

    public enum LefteyeEmptyResult: String, Codable {
        /// 左眼外侧适中
        case lefteyeEmptyNormal = "lefteye_empty_normal"
        /// 左外外侧偏窄
        case lefteyeEmptyShort = "lefteye_empty_short"
        /// (左眼外侧偏宽
        case lefteyeEmptyLong = "lefteye_empty_long"
    }

    public struct FiveEye: Codable, Hashable {
        /// 左外眼角颧弓留白 （若为0或无法判断，则返回null）
        public let lefteyeEmptyLength: Float?
        /// 左外眼角颧弓留白占比（若为0或无法判断，则返回null）
        public let lefteyeEmptyRatio: Float?
        /// 五眼左侧距判断结果（若为0或无法判断，则返回null）
        public let lefteyeEmptyResult: LefteyeEmptyResult?
    }
}

public struct FacialFeaturesFace: Codable, Hashable {
    /// 颞部宽度（若为0则返回null）
    public let tempusLength: Float?
    /// 颧骨宽度（若为0则返回null）
    public let zygomaLength: Float?
    /// 脸部长度（若为0则返回null）
    public let faceLength: Float?
    /// 下颌角宽度（若为0则返回null）
    public let mandibleLength: Float?
    /// 下颌角度数（若为0则返回null）
    public let E: Float?
    /// 颞部宽度、颧部宽度（固定颧部为1）、下颌角宽度比（若为0则返回null）
    public let ABDRatio: Float?

    public enum FaceType: String, Codable {
        /// 瓜子脸
        case pointedFace = "pointed_face"
        /// 椭圆脸
        case ovalFace = "oval_face"
        /// 菱形脸
        case diamondFace = "diamond_face"
        /// 圆形脸
        case roundFace = "round_face"
        /// 长形脸
        case longFace = "long_face"
        /// 方形脸
        case squareFace = "square_face"
        /// 标准脸
        case normalFace = "normal_face"
    }
    /// 脸型判断结果（若无法判断则返回null）
    public let faceType: FaceType?
}

public struct FacialFeaturesJaw: Codable, Hashable {
    /// 下巴宽度（若为0或者无法判断，则返回null）
    public let jawWidth: Float?
    /// 下巴长度（若为0或者无法判断，则返回null）
    public let jawLength: Float?
    /// 下巴角度（若为0则返回null）
    public let jawAngle: Float?

    public enum JawType: String, Codable {
        /// 圆下巴
        case flatJaw = "flat_jaw"
        /// 尖下巴
        case sharpJaw = "sharp_jaw"
        /// 方下巴
        case squareJaw = "square_jaw"
    }
    /// 下巴判断结果（若为0或者无法判断，则返回null）
    public let jawType: JawType?
}

public struct FacialFeaturesEyebrow: Codable, Hashable {
    /// 眉毛宽度（若为0则返回null）
    public let browWidth: Float?
    /// 眉毛高度（若为0则返回null）
    public let browHeight: Float?
    /// 眉毛挑度，若通过M2的水平线在M3的下方，则返回null
    public let browUptrendAngle: Float?
    /// 眉毛弯度
    public let browCamberAngle: Float?
    /// 眉毛粗细（若为0则返回null）
    public let browThick: Float?

    public enum EyebrowType: String, Codable {
        /// 粗眉
        case bushyEyebrows = "bushy_eyebrows"
        /// 八字眉
        case eightEyebrows = "eight_eyebrows"
        /// 上挑眉
        case raiseEyebrows = "raise_eyebrows"
        /// 一字眉
        case straightEyebrows = "straight_eyebrows"
        /// 拱形眉
        case roundEyebrows = "round_eyebrows"
        /// 柳叶眉
        case archEyebrows = "arch_eyebrows"
        /// 细眉
        case thinEyebrows = "thin_eyebrows"
    }
    /// 眉型判断结果（若无法判断则返回null）
    public let eyebrowType: EyebrowType?
}

public struct FacialFeaturesEyes: Codable, Hashable {
    /// 眼睛宽度（若为0或无法判断，则返回null）
    public let eyeWidth: Float?
    /// 眼睛高度（若为0或无法判断，则返回null）
    public let eyeHeight: Float?
    /// 内眦角度数（若为0或无法判断，则返回null）
    public let angulusOculiMedialis: Float?

    public enum EyesType: String, Codable {
        /// 圆眼
        case roundEyes = "round_eyes"
        /// 细长眼
        case thinEyes = "thin_eyes"
        /// 大眼
        case bigEyes = "big_eyes"
        /// 小眼
        case smallEyes = "small_eyes"
        /// 标准眼
        case normalEyes = "normal_eyes"
    }
    /// 眼型判断结果（若为0或无法判断，则返回null）
    public let eyesType: EyesType?
}

public struct FacialFeaturesNose: Codable, Hashable {
    /// 鼻翼宽度（若为0或无法判断，则返回null）
    public let noseWidth: Float?

    public enum NoseType: String, Codable {
        /// 标准鼻
        case normalNose = "normal_nose"
        /// 宽鼻
        case thickNose = "thick_nose"
        /// 窄鼻
        case thinNose = "thin_nose"
    }
    /// 鼻翼判断结果（若为0或无法判断，则返回null）
    public let noseType: NoseType?
}

public struct FacialFeaturesMouth: Codable, Hashable {
    /// 嘴巴高度（若为0或无法判断，则返回null）
    public let mouthHeight: Float?
    /// 嘴巴宽度（若为0或无法判断，则返回null）
    public let mouthWidth: Float?
    /// 嘴唇厚度（若为0或无法判断，则返回null）
    public let lipThickness: Float?
    /// 嘴角弯曲度（若为0或无法判断，则返回null）
    public let angulusOris: Float?

    public enum MouthType: String, Codable {
        /// 薄唇
        case thinLip = "thin_lip"
        /// 厚唇
        case thickLip = "thick_lip"
        /// 微笑唇
        case smileLip = "smile_lip"
        /// 态度唇
        case upsetLip = "upset_lip"
        /// 标准唇
        case normalLip = "normal_lip"
    }
    /// 唇型判断结果（若为0或无法判断，则返回null）
    public let mouthType: MouthType?
}

public struct FacialFeaturesResults: Codable, Hashable {
    /// 三庭
    public let threeParts: Threeparts
    /// 五眼
    public let fiveEyes: FiveEyes
    /// 返回黄金三角度数，单位为°，范围[0,180]，保留至小数点后两位（若为0则返回null）
    public let goldenTriangle: Float?
    /// 脸型
    public let face: FacialFeaturesFace
    /// 返回下巴分析结果，包含以下属性，距离单位为mm，保留至小数点后两位
    public let jaw: FacialFeaturesJaw
    /// 返回眉毛分析结果，包含以下属性，距离单位为mm，角度单位为°，保留至小数点后两位
    public let eyebrow: FacialFeaturesEyebrow
    ///返回眼睛分析结果，包含以下属性，距离单位为mm，角度单位为°，保留至小数点后两位
    public let eyes: FacialFeaturesEyes
    /// 返回鼻子分析结果，包含以下属性，距离单位为mm，保留至小数点后两位
    public let nose: FacialFeaturesNose
}
