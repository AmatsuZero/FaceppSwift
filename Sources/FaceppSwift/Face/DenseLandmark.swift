//
//  DenseLandmark.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/7.
// - Wiki: https://console.faceplusplus.com.cn/documents/55107022
//

import Foundation

let kFaceBaseURL = kFaceappV1URL?.appendingPathComponent("face")

@objc(FppThousandLandMarkOption)
@objcMembers public class ThousandLandMarkOption: FaceppBaseRequest {
    /// 人脸标识 face_token，优先使用该参数
    public var faceToken: String?
    @nonobjc public var returnLandMark: Set<ReturnLandMark>

    public var returnLandMarkString: Set<String> {
        set {
            returnLandMark = Set(newValue.compactMap { ReturnLandMark(rawValue: $0) })
        }
        get {
            Set(returnLandMark.map { $0.rawValue })
        }
    }

    @nonobjc public init(returnLandMark: Set<ReturnLandMark>) {
        self.returnLandMark = returnLandMark
        super.init()
    }

    public init(returnLandMarkString: Set<String>) {
        returnLandMark = Set(returnLandMarkString.compactMap {
            ReturnLandMark(rawValue: $0)
        })
        super.init()
    }

    required public init(params: [String: Any]) {
        if let value = params["face_token"] as? String {
            faceToken = value
        }
        if let attributs = params["return_landmark"] as? String {
            returnLandMark = Set(attributs
                .components(separatedBy: ",")
                .compactMap { ReturnLandMark(rawValue: $0) })
        } else {
            returnLandMark = .all
        }
        super.init(params: params)
    }

    public enum ReturnLandMark: String, Option {
        case leftEyeBrow = "left_eyebrow"
        case rightEyeBrow = "right_eyebrow"
        case lefteye = "left_eye"
        case leftEyeEyelid = "left_eye_eyelid"
        case rightEye = "right_eye"
        case rightEyeEyelid = "right_eye_eyelid"
        case nose, mouse, face
    }

    override var requsetURL: URL? {
        return kFaceBaseURL?.appendingPathComponent("thousandlandmark")
    }

    override func paramsCheck() throws -> Bool {
        guard needCheckParams else {
            return true
        }
        let result = try super.paramsCheck()
        return faceToken != nil || result
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, files) = try super.params()
        params["return_landmark"] = returnLandMark == .all
            ? "all"
            : returnLandMark.map { $0.rawValue }.joined(separator: ",")
        return (params, files)
    }
}

public extension Set where Element == ThousandLandMarkOption.ReturnLandMark {
    static var all: Set {
        return Set(ThousandLandMarkOption.ReturnLandMark.allCases)
    }
}

@objc(FppThousandLandmarkResponse)
@objcMembers public final class ThousandLandmarkResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?

    @objc(FppThousandLandmarkFace)
    @objcMembers public final class Face: NSObject, Codable {
        /// 人脸矩形框的位置
        public let faceRectangle: FaceppRectangle
        /// 人脸五官及轮廓的关键点坐标数组。
        public let landmark: DenseLandmark
    }
    /// 经过分析的人脸
    public let face: Face?
}

@objc(FppDenseLandmark)
public final class DenseLandmark: NSObject, Codable {
    // MARK: - 面部轮廓关键点集合。返回值为：
    @objc(FppDenseLandmarkFace)
    @objcMembers public final class Face: NSObject, Codable {
        // MARK: - 面部上半部分轮廓关键点，从右耳附近起始到左耳附近终，按逆时针顺序检测到的位置序列。
        public let faceHairline0: FaceppPoint
        public let faceHairline1: FaceppPoint
        public let faceHairline2: FaceppPoint
        public let faceHairline3: FaceppPoint
        public let faceHairline4: FaceppPoint
        public let faceHairline5: FaceppPoint
        public let faceHairline6: FaceppPoint
        public let faceHairline7: FaceppPoint
        public let faceHairline8: FaceppPoint
        public let faceHairline9: FaceppPoint
        public let faceHairline10: FaceppPoint
        public let faceHairline11: FaceppPoint
        public let faceHairline12: FaceppPoint
        public let faceHairline13: FaceppPoint
        public let faceHairline14: FaceppPoint
        public let faceHairline15: FaceppPoint
        public let faceHairline16: FaceppPoint
        public let faceHairline17: FaceppPoint
        public let faceHairline18: FaceppPoint
        public let faceHairline19: FaceppPoint
        public let faceHairline20: FaceppPoint
        public let faceHairline21: FaceppPoint
        public let faceHairline22: FaceppPoint
        public let faceHairline23: FaceppPoint
        public let faceHairline24: FaceppPoint
        public let faceHairline25: FaceppPoint
        public let faceHairline26: FaceppPoint
        public let faceHairline27: FaceppPoint
        public let faceHairline28: FaceppPoint
        public let faceHairline29: FaceppPoint
        public let faceHairline30: FaceppPoint
        public let faceHairline31: FaceppPoint
        public let faceHairline32: FaceppPoint
        public let faceHairline33: FaceppPoint
        public let faceHairline34: FaceppPoint
        public let faceHairline35: FaceppPoint
        public let faceHairline36: FaceppPoint
        public let faceHairline37: FaceppPoint
        public let faceHairline38: FaceppPoint
        public let faceHairline39: FaceppPoint
        public let faceHairline40: FaceppPoint
        public let faceHairline41: FaceppPoint
        public let faceHairline42: FaceppPoint
        public let faceHairline43: FaceppPoint
        public let faceHairline44: FaceppPoint
        public let faceHairline45: FaceppPoint
        public let faceHairline46: FaceppPoint
        public let faceHairline47: FaceppPoint
        public let faceHairline48: FaceppPoint
        public let faceHairline49: FaceppPoint
        public let faceHairline50: FaceppPoint
        public let faceHairline51: FaceppPoint
        public let faceHairline52: FaceppPoint
        public let faceHairline53: FaceppPoint
        public let faceHairline54: FaceppPoint
        public let faceHairline55: FaceppPoint
        public let faceHairline56: FaceppPoint
        public let faceHairline57: FaceppPoint
        public let faceHairline58: FaceppPoint
        public let faceHairline59: FaceppPoint
        public let faceHairline60: FaceppPoint
        public let faceHairline61: FaceppPoint
        public let faceHairline62: FaceppPoint
        public let faceHairline63: FaceppPoint
        public let faceHairline64: FaceppPoint
        public let faceHairline65: FaceppPoint
        public let faceHairline66: FaceppPoint
        public let faceHairline67: FaceppPoint
        public let faceHairline68: FaceppPoint
        public let faceHairline69: FaceppPoint
        public let faceHairline70: FaceppPoint
        public let faceHairline71: FaceppPoint
        public let faceHairline72: FaceppPoint
        public let faceHairline73: FaceppPoint
        public let faceHairline74: FaceppPoint
        public let faceHairline75: FaceppPoint
        public let faceHairline76: FaceppPoint
        public let faceHairline77: FaceppPoint
        public let faceHairline78: FaceppPoint
        public let faceHairline79: FaceppPoint
        public let faceHairline80: FaceppPoint
        public let faceHairline81: FaceppPoint
        public let faceHairline82: FaceppPoint
        public let faceHairline83: FaceppPoint
        public let faceHairline84: FaceppPoint
        public let faceHairline85: FaceppPoint
        public let faceHairline86: FaceppPoint
        public let faceHairline87: FaceppPoint
        public let faceHairline88: FaceppPoint
        public let faceHairline89: FaceppPoint
        public let faceHairline90: FaceppPoint
        public let faceHairline91: FaceppPoint
        public let faceHairline92: FaceppPoint
        public let faceHairline93: FaceppPoint
        public let faceHairline94: FaceppPoint
        public let faceHairline95: FaceppPoint
        public let faceHairline96: FaceppPoint
        public let faceHairline97: FaceppPoint
        public let faceHairline98: FaceppPoint
        public let faceHairline99: FaceppPoint
        public let faceHairline100: FaceppPoint
        public let faceHairline101: FaceppPoint
        public let faceHairline102: FaceppPoint
        public let faceHairline103: FaceppPoint
        public let faceHairline104: FaceppPoint
        public let faceHairline105: FaceppPoint
        public let faceHairline106: FaceppPoint
        public let faceHairline107: FaceppPoint
        public let faceHairline108: FaceppPoint
        public let faceHairline109: FaceppPoint
        public let faceHairline110: FaceppPoint
        public let faceHairline111: FaceppPoint
        public let faceHairline112: FaceppPoint
        public let faceHairline113: FaceppPoint
        public let faceHairline114: FaceppPoint
        public let faceHairline115: FaceppPoint
        public let faceHairline116: FaceppPoint
        public let faceHairline117: FaceppPoint
        public let faceHairline118: FaceppPoint
        public let faceHairline119: FaceppPoint
        public let faceHairline120: FaceppPoint
        public let faceHairline121: FaceppPoint
        public let faceHairline122: FaceppPoint
        public let faceHairline123: FaceppPoint
        public let faceHairline124: FaceppPoint
        public let faceHairline125: FaceppPoint
        public let faceHairline126: FaceppPoint
        public let faceHairline127: FaceppPoint
        public let faceHairline128: FaceppPoint
        public let faceHairline129: FaceppPoint
        public let faceHairline130: FaceppPoint
        public let faceHairline131: FaceppPoint
        public let faceHairline132: FaceppPoint
        public let faceHairline133: FaceppPoint
        public let faceHairline134: FaceppPoint
        public let faceHairline135: FaceppPoint
        public let faceHairline136: FaceppPoint
        public let faceHairline137: FaceppPoint
        public let faceHairline138: FaceppPoint
        public let faceHairline139: FaceppPoint
        public let faceHairline140: FaceppPoint
        public let faceHairline141: FaceppPoint
        public let faceHairline142: FaceppPoint
        public let faceHairline143: FaceppPoint
        public let faceHairline144: FaceppPoint
        // MARK: - 面部下半部分右边轮廓关键点。从下巴起始到右耳附近，按逆时针顺序检测到的位置序列。face_contour_right_0为下巴中心位置。
        public let faceContourRight0: FaceppPoint
        public let faceContourRight1: FaceppPoint
        public let faceContourRight2: FaceppPoint
        public let faceContourRight3: FaceppPoint
        public let faceContourRight4: FaceppPoint
        public let faceContourRight5: FaceppPoint
        public let faceContourRight6: FaceppPoint
        public let faceContourRight7: FaceppPoint
        public let faceContourRight8: FaceppPoint
        public let faceContourRight9: FaceppPoint
        public let faceContourRight10: FaceppPoint
        public let faceContourRight11: FaceppPoint
        public let faceContourRight12: FaceppPoint
        public let faceContourRight13: FaceppPoint
        public let faceContourRight14: FaceppPoint
        public let faceContourRight15: FaceppPoint
        public let faceContourRight16: FaceppPoint
        public let faceContourRight17: FaceppPoint
        public let faceContourRight18: FaceppPoint
        public let faceContourRight19: FaceppPoint
        public let faceContourRight20: FaceppPoint
        public let faceContourRight21: FaceppPoint
        public let faceContourRight22: FaceppPoint
        public let faceContourRight23: FaceppPoint
        public let faceContourRight24: FaceppPoint
        public let faceContourRight25: FaceppPoint
        public let faceContourRight26: FaceppPoint
        public let faceContourRight27: FaceppPoint
        public let faceContourRight28: FaceppPoint
        public let faceContourRight29: FaceppPoint
        public let faceContourRight30: FaceppPoint
        public let faceContourRight31: FaceppPoint
        public let faceContourRight32: FaceppPoint
        public let faceContourRight33: FaceppPoint
        public let faceContourRight34: FaceppPoint
        public let faceContourRight35: FaceppPoint
        public let faceContourRight36: FaceppPoint
        public let faceContourRight37: FaceppPoint
        public let faceContourRight38: FaceppPoint
        public let faceContourRight39: FaceppPoint
        public let faceContourRight40: FaceppPoint
        public let faceContourRight41: FaceppPoint
        public let faceContourRight42: FaceppPoint
        public let faceContourRight43: FaceppPoint
        public let faceContourRight44: FaceppPoint
        public let faceContourRight45: FaceppPoint
        public let faceContourRight46: FaceppPoint
        public let faceContourRight47: FaceppPoint
        public let faceContourRight48: FaceppPoint
        public let faceContourRight49: FaceppPoint
        public let faceContourRight50: FaceppPoint
        public let faceContourRight51: FaceppPoint
        public let faceContourRight52: FaceppPoint
        public let faceContourRight53: FaceppPoint
        public let faceContourRight54: FaceppPoint
        public let faceContourRight55: FaceppPoint
        public let faceContourRight56: FaceppPoint
        public let faceContourRight57: FaceppPoint
        public let faceContourRight58: FaceppPoint
        public let faceContourRight59: FaceppPoint
        public let faceContourRight60: FaceppPoint
        public let faceContourRight61: FaceppPoint
        public let faceContourRight62: FaceppPoint
        public let faceContourRight63: FaceppPoint
        // MARK: - 面部下半部分左边轮廓关键点。从下巴起始到左耳附近，按顺时针顺序检测到的位置序列。
        public let faceContourLeft0: FaceppPoint
        public let faceContourLeft1: FaceppPoint
        public let faceContourLeft2: FaceppPoint
        public let faceContourLeft3: FaceppPoint
        public let faceContourLeft4: FaceppPoint
        public let faceContourLeft5: FaceppPoint
        public let faceContourLeft6: FaceppPoint
        public let faceContourLeft7: FaceppPoint
        public let faceContourLeft8: FaceppPoint
        public let faceContourLeft9: FaceppPoint
        public let faceContourLeft10: FaceppPoint
        public let faceContourLeft11: FaceppPoint
        public let faceContourLeft12: FaceppPoint
        public let faceContourLeft13: FaceppPoint
        public let faceContourLeft14: FaceppPoint
        public let faceContourLeft15: FaceppPoint
        public let faceContourLeft16: FaceppPoint
        public let faceContourLeft17: FaceppPoint
        public let faceContourLeft18: FaceppPoint
        public let faceContourLeft19: FaceppPoint
        public let faceContourLeft20: FaceppPoint
        public let faceContourLeft21: FaceppPoint
        public let faceContourLeft22: FaceppPoint
        public let faceContourLeft23: FaceppPoint
        public let faceContourLeft24: FaceppPoint
        public let faceContourLeft25: FaceppPoint
        public let faceContourLeft26: FaceppPoint
        public let faceContourLeft27: FaceppPoint
        public let faceContourLeft28: FaceppPoint
        public let faceContourLeft29: FaceppPoint
        public let faceContourLeft30: FaceppPoint
        public let faceContourLeft31: FaceppPoint
        public let faceContourLeft32: FaceppPoint
        public let faceContourLeft33: FaceppPoint
        public let faceContourLeft34: FaceppPoint
        public let faceContourLeft35: FaceppPoint
        public let faceContourLeft36: FaceppPoint
        public let faceContourLeft37: FaceppPoint
        public let faceContourLeft38: FaceppPoint
        public let faceContourLeft39: FaceppPoint
        public let faceContourLeft40: FaceppPoint
        public let faceContourLeft41: FaceppPoint
        public let faceContourLeft42: FaceppPoint
        public let faceContourLeft43: FaceppPoint
        public let faceContourLeft44: FaceppPoint
        public let faceContourLeft45: FaceppPoint
        public let faceContourLeft46: FaceppPoint
        public let faceContourLeft47: FaceppPoint
        public let faceContourLeft48: FaceppPoint
        public let faceContourLeft49: FaceppPoint
        public let faceContourLeft50: FaceppPoint
        public let faceContourLeft51: FaceppPoint
        public let faceContourLeft52: FaceppPoint
        public let faceContourLeft53: FaceppPoint
        public let faceContourLeft54: FaceppPoint
        public let faceContourLeft55: FaceppPoint
        public let faceContourLeft56: FaceppPoint
        public let faceContourLeft57: FaceppPoint
        public let faceContourLeft58: FaceppPoint
        public let faceContourLeft59: FaceppPoint
        public let faceContourLeft60: FaceppPoint
        public let faceContourLeft61: FaceppPoint
        public let faceContourLeft62: FaceppPoint
        public let faceContourLeft63: FaceppPoint
    }
    /// 面部轮廓关键点集合
    public let face: Face?
    // MARK: - 从左眉左端中心位置起始，按顺时针顺序检测到的左眉关键点位置序列。
    @objc(FppLeftEyebrow)
    @objcMembers public final class LeftEyebrow: NSObject, Codable {
        public let leftEyebrow0: FaceppPoint
        public let leftEyebrow1: FaceppPoint
        public let leftEyebrow2: FaceppPoint
        public let leftEyebrow3: FaceppPoint
        public let leftEyebrow4: FaceppPoint
        public let leftEyebrow5: FaceppPoint
        public let leftEyebrow6: FaceppPoint
        public let leftEyebrow7: FaceppPoint
        public let leftEyebrow8: FaceppPoint
        public let leftEyebrow9: FaceppPoint
        public let leftEyebrow10: FaceppPoint
        public let leftEyebrow11: FaceppPoint
        public let leftEyebrow12: FaceppPoint
        public let leftEyebrow13: FaceppPoint
        public let leftEyebrow14: FaceppPoint
        public let leftEyebrow15: FaceppPoint
        public let leftEyebrow16: FaceppPoint
        public let leftEyebrow17: FaceppPoint
        public let leftEyebrow18: FaceppPoint
        public let leftEyebrow19: FaceppPoint
        public let leftEyebrow20: FaceppPoint
        public let leftEyebrow21: FaceppPoint
        public let leftEyebrow22: FaceppPoint
        public let leftEyebrow23: FaceppPoint
        public let leftEyebrow24: FaceppPoint
        public let leftEyebrow25: FaceppPoint
        public let leftEyebrow26: FaceppPoint
        public let leftEyebrow27: FaceppPoint
        public let leftEyebrow28: FaceppPoint
        public let leftEyebrow29: FaceppPoint
        public let leftEyebrow30: FaceppPoint
        public let leftEyebrow31: FaceppPoint
        public let leftEyebrow32: FaceppPoint
        public let leftEyebrow33: FaceppPoint
        public let leftEyebrow34: FaceppPoint
        public let leftEyebrow35: FaceppPoint
        public let leftEyebrow36: FaceppPoint
        public let leftEyebrow37: FaceppPoint
        public let leftEyebrow38: FaceppPoint
        public let leftEyebrow39: FaceppPoint
        public let leftEyebrow40: FaceppPoint
        public let leftEyebrow41: FaceppPoint
        public let leftEyebrow42: FaceppPoint
        public let leftEyebrow43: FaceppPoint
        public let leftEyebrow44: FaceppPoint
        public let leftEyebrow45: FaceppPoint
        public let leftEyebrow46: FaceppPoint
        public let leftEyebrow47: FaceppPoint
        public let leftEyebrow48: FaceppPoint
        public let leftEyebrow49: FaceppPoint
        public let leftEyebrow50: FaceppPoint
        public let leftEyebrow51: FaceppPoint
        public let leftEyebrow52: FaceppPoint
        public let leftEyebrow53: FaceppPoint
        public let leftEyebrow54: FaceppPoint
        public let leftEyebrow55: FaceppPoint
        public let leftEyebrow56: FaceppPoint
        public let leftEyebrow57: FaceppPoint
        public let leftEyebrow58: FaceppPoint
        public let leftEyebrow59: FaceppPoint
        public let leftEyebrow60: FaceppPoint
        public let leftEyebrow61: FaceppPoint
        public let leftEyebrow62: FaceppPoint
        public let leftEyebrow63: FaceppPoint
    }
    /// 左眉毛关键点集合
    public let leftEyebrow: LeftEyebrow?
    // MAKR: - 从右眉右端中心位置起始，按逆时针顺序检测到的右眉关键点位置序列。
    @objc(FppRightEyebrow)
    @objcMembers public final class RightEyebrow: NSObject, Codable {
        public let rightEyebrow0: FaceppPoint
        public let rightEyebrow1: FaceppPoint
        public let rightEyebrow2: FaceppPoint
        public let rightEyebrow3: FaceppPoint
        public let rightEyebrow4: FaceppPoint
        public let rightEyebrow5: FaceppPoint
        public let rightEyebrow6: FaceppPoint
        public let rightEyebrow7: FaceppPoint
        public let rightEyebrow8: FaceppPoint
        public let rightEyebrow9: FaceppPoint
        public let rightEyebrow10: FaceppPoint
        public let rightEyebrow11: FaceppPoint
        public let rightEyebrow12: FaceppPoint
        public let rightEyebrow13: FaceppPoint
        public let rightEyebrow14: FaceppPoint
        public let rightEyebrow15: FaceppPoint
        public let rightEyebrow16: FaceppPoint
        public let rightEyebrow17: FaceppPoint
        public let rightEyebrow18: FaceppPoint
        public let rightEyebrow19: FaceppPoint
        public let rightEyebrow20: FaceppPoint
        public let rightEyebrow21: FaceppPoint
        public let rightEyebrow22: FaceppPoint
        public let rightEyebrow23: FaceppPoint
        public let rightEyebrow24: FaceppPoint
        public let rightEyebrow25: FaceppPoint
        public let rightEyebrow26: FaceppPoint
        public let rightEyebrow27: FaceppPoint
        public let rightEyebrow28: FaceppPoint
        public let rightEyebrow29: FaceppPoint
        public let rightEyebrow30: FaceppPoint
        public let rightEyebrow31: FaceppPoint
        public let rightEyebrow32: FaceppPoint
        public let rightEyebrow33: FaceppPoint
        public let rightEyebrow34: FaceppPoint
        public let rightEyebrow35: FaceppPoint
        public let rightEyebrow36: FaceppPoint
        public let rightEyebrow37: FaceppPoint
        public let rightEyebrow38: FaceppPoint
        public let rightEyebrow39: FaceppPoint
        public let rightEyebrow40: FaceppPoint
        public let rightEyebrow41: FaceppPoint
        public let rightEyebrow42: FaceppPoint
        public let rightEyebrow43: FaceppPoint
        public let rightEyebrow44: FaceppPoint
        public let rightEyebrow45: FaceppPoint
        public let rightEyebrow46: FaceppPoint
        public let rightEyebrow47: FaceppPoint
        public let rightEyebrow48: FaceppPoint
        public let rightEyebrow49: FaceppPoint
        public let rightEyebrow50: FaceppPoint
        public let rightEyebrow51: FaceppPoint
        public let rightEyebrow52: FaceppPoint
        public let rightEyebrow53: FaceppPoint
        public let rightEyebrow54: FaceppPoint
        public let rightEyebrow55: FaceppPoint
        public let rightEyebrow56: FaceppPoint
        public let rightEyebrow57: FaceppPoint
        public let rightEyebrow58: FaceppPoint
        public let rightEyebrow59: FaceppPoint
        public let rightEyebrow60: FaceppPoint
        public let rightEyebrow61: FaceppPoint
        public let rightEyebrow62: FaceppPoint
        public let rightEyebrow63: FaceppPoint
    }
    /// 右眉毛关键点集合
    public let rightEyebrow: RightEyebrow?

    @objc(FppLeftEye)
    @objcMembers public final class LeftEye: NSObject, Codable {
        // MARK: - 从左眼左端中心位置起始，按顺时针顺序检测到的左眼关键点位置序列。
        public let leftEye0: FaceppPoint
        public let leftEye1: FaceppPoint
        public let leftEye2: FaceppPoint
        public let leftEye3: FaceppPoint
        public let leftEye4: FaceppPoint
        public let leftEye5: FaceppPoint
        public let leftEye6: FaceppPoint
        public let leftEye7: FaceppPoint
        public let leftEye8: FaceppPoint
        public let leftEye9: FaceppPoint
        public let leftEye10: FaceppPoint
        public let leftEye11: FaceppPoint
        public let leftEye12: FaceppPoint
        public let leftEye13: FaceppPoint
        public let leftEye14: FaceppPoint
        public let leftEye15: FaceppPoint
        public let leftEye16: FaceppPoint
        public let leftEye17: FaceppPoint
        public let leftEye18: FaceppPoint
        public let leftEye19: FaceppPoint
        public let leftEye20: FaceppPoint
        public let leftEye21: FaceppPoint
        public let leftEye22: FaceppPoint
        public let leftEye23: FaceppPoint
        public let leftEye24: FaceppPoint
        public let leftEye25: FaceppPoint
        public let leftEye26: FaceppPoint
        public let leftEye27: FaceppPoint
        public let leftEye28: FaceppPoint
        public let leftEye29: FaceppPoint
        public let leftEye30: FaceppPoint
        public let leftEye31: FaceppPoint
        public let leftEye32: FaceppPoint
        public let leftEye33: FaceppPoint
        public let leftEye34: FaceppPoint
        public let leftEye35: FaceppPoint
        public let leftEye36: FaceppPoint
        public let leftEye37: FaceppPoint
        public let leftEye38: FaceppPoint
        public let leftEye39: FaceppPoint
        public let leftEye40: FaceppPoint
        public let leftEye41: FaceppPoint
        public let leftEye42: FaceppPoint
        public let leftEye43: FaceppPoint
        public let leftEye44: FaceppPoint
        public let leftEye45: FaceppPoint
        public let leftEye46: FaceppPoint
        public let leftEye47: FaceppPoint
        public let leftEye48: FaceppPoint
        public let leftEye49: FaceppPoint
        public let leftEye50: FaceppPoint
        public let leftEye51: FaceppPoint
        public let leftEye52: FaceppPoint
        public let leftEye53: FaceppPoint
        public let leftEye54: FaceppPoint
        public let leftEye55: FaceppPoint
        public let leftEye56: FaceppPoint
        public let leftEye57: FaceppPoint
        public let leftEye58: FaceppPoint
        public let leftEye59: FaceppPoint
        public let leftEye60: FaceppPoint
        public let leftEye61: FaceppPoint
        public let leftEye62: FaceppPoint
        /// 左眼瞳孔中心位置
        public let leftEyePupilCenter: FaceppPoint
        /// 左眼瞳孔半径
        public let leftEyePupilRadius: Float
    }
    /// 左眼内圈关键点集合
    public let leftEye: LeftEye?

    @objc(FppLeftEyeEyelid)
    @objcMembers public final class LeftEyeEyelid: NSObject, Codable {
        // MARK: - 从左眼外眼角位置起始，按顺时针顺序检测到的左眼外圈关键点位置序列。
        public let leftEyeEyelid0: FaceppPoint
        public let leftEyeEyelid1: FaceppPoint
        public let leftEyeEyelid2: FaceppPoint
        public let leftEyeEyelid3: FaceppPoint
        public let leftEyeEyelid4: FaceppPoint
        public let leftEyeEyelid5: FaceppPoint
        public let leftEyeEyelid6: FaceppPoint
        public let leftEyeEyelid7: FaceppPoint
        public let leftEyeEyelid8: FaceppPoint
        public let leftEyeEyelid9: FaceppPoint
        public let leftEyeEyelid10: FaceppPoint
        public let leftEyeEyelid11: FaceppPoint
        public let leftEyeEyelid12: FaceppPoint
        public let leftEyeEyelid13: FaceppPoint
        public let leftEyeEyelid14: FaceppPoint
        public let leftEyeEyelid15: FaceppPoint
        public let leftEyeEyelid16: FaceppPoint
        public let leftEyeEyelid17: FaceppPoint
        public let leftEyeEyelid18: FaceppPoint
        public let leftEyeEyelid19: FaceppPoint
        public let leftEyeEyelid20: FaceppPoint
        public let leftEyeEyelid21: FaceppPoint
        public let leftEyeEyelid22: FaceppPoint
        public let leftEyeEyelid23: FaceppPoint
        public let leftEyeEyelid24: FaceppPoint
        public let leftEyeEyelid25: FaceppPoint
        public let leftEyeEyelid26: FaceppPoint
        public let leftEyeEyelid27: FaceppPoint
        public let leftEyeEyelid28: FaceppPoint
        public let leftEyeEyelid29: FaceppPoint
        public let leftEyeEyelid30: FaceppPoint
        public let leftEyeEyelid31: FaceppPoint
        public let leftEyeEyelid32: FaceppPoint
        public let leftEyeEyelid33: FaceppPoint
        public let leftEyeEyelid34: FaceppPoint
        public let leftEyeEyelid35: FaceppPoint
        public let leftEyeEyelid36: FaceppPoint
        public let leftEyeEyelid37: FaceppPoint
        public let leftEyeEyelid38: FaceppPoint
        public let leftEyeEyelid39: FaceppPoint
        public let leftEyeEyelid40: FaceppPoint
        public let leftEyeEyelid41: FaceppPoint
        public let leftEyeEyelid42: FaceppPoint
        public let leftEyeEyelid43: FaceppPoint
        public let leftEyeEyelid44: FaceppPoint
        public let leftEyeEyelid45: FaceppPoint
        public let leftEyeEyelid46: FaceppPoint
        public let leftEyeEyelid47: FaceppPoint
        public let leftEyeEyelid48: FaceppPoint
        public let leftEyeEyelid49: FaceppPoint
        public let leftEyeEyelid50: FaceppPoint
        public let leftEyeEyelid51: FaceppPoint
        public let leftEyeEyelid52: FaceppPoint
        public let leftEyeEyelid53: FaceppPoint
        public let leftEyeEyelid54: FaceppPoint
        public let leftEyeEyelid55: FaceppPoint
        public let leftEyeEyelid56: FaceppPoint
        public let leftEyeEyelid57: FaceppPoint
        public let leftEyeEyelid58: FaceppPoint
        public let leftEyeEyelid59: FaceppPoint
        public let leftEyeEyelid60: FaceppPoint
        public let leftEyeEyelid61: FaceppPoint
        public let leftEyeEyelid62: FaceppPoint
        public let leftEyeEyelid63: FaceppPoint
    }
    /// 左眼外圈关键点集合
    public let leftEyeEyelid: LeftEyeEyelid?

    @objc(FppRightEye)
    @objcMembers public final class RightEye: NSObject, Codable {
        // MARK: - 从右眼右端中心位置起始，按逆时针顺序检测到的右眼关键点位置序列
        public let rightEye0: FaceppPoint
        public let rightEye1: FaceppPoint
        public let rightEye2: FaceppPoint
        public let rightEye3: FaceppPoint
        public let rightEye4: FaceppPoint
        public let rightEye5: FaceppPoint
        public let rightEye6: FaceppPoint
        public let rightEye7: FaceppPoint
        public let rightEye8: FaceppPoint
        public let rightEye9: FaceppPoint
        public let rightEye10: FaceppPoint
        public let rightEye11: FaceppPoint
        public let rightEye12: FaceppPoint
        public let rightEye13: FaceppPoint
        public let rightEye14: FaceppPoint
        public let rightEye15: FaceppPoint
        public let rightEye16: FaceppPoint
        public let rightEye17: FaceppPoint
        public let rightEye18: FaceppPoint
        public let rightEye19: FaceppPoint
        public let rightEye20: FaceppPoint
        public let rightEye21: FaceppPoint
        public let rightEye22: FaceppPoint
        public let rightEye23: FaceppPoint
        public let rightEye24: FaceppPoint
        public let rightEye25: FaceppPoint
        public let rightEye26: FaceppPoint
        public let rightEye27: FaceppPoint
        public let rightEye28: FaceppPoint
        public let rightEye29: FaceppPoint
        public let rightEye30: FaceppPoint
        public let rightEye31: FaceppPoint
        public let rightEye32: FaceppPoint
        public let rightEye33: FaceppPoint
        public let rightEye34: FaceppPoint
        public let rightEye35: FaceppPoint
        public let rightEye36: FaceppPoint
        public let rightEye37: FaceppPoint
        public let rightEye38: FaceppPoint
        public let rightEye39: FaceppPoint
        public let rightEye40: FaceppPoint
        public let rightEye41: FaceppPoint
        public let rightEye42: FaceppPoint
        public let rightEye43: FaceppPoint
        public let rightEye44: FaceppPoint
        public let rightEye45: FaceppPoint
        public let rightEye46: FaceppPoint
        public let rightEye47: FaceppPoint
        public let rightEye48: FaceppPoint
        public let rightEye49: FaceppPoint
        public let rightEye50: FaceppPoint
        public let rightEye51: FaceppPoint
        public let rightEye52: FaceppPoint
        public let rightEye53: FaceppPoint
        public let rightEye54: FaceppPoint
        public let rightEye55: FaceppPoint
        public let rightEye56: FaceppPoint
        public let rightEye57: FaceppPoint
        public let rightEye58: FaceppPoint
        public let rightEye59: FaceppPoint
        public let rightEye60: FaceppPoint
        public let rightEye61: FaceppPoint
        public let rightEye62: FaceppPoint
        /// 右眼瞳孔中心位置
        public let rightEyePupilCenter: FaceppPoint
        /// 右眼瞳孔半径
        public let rightEyePupilRadius: Float
    }
    /// 右眼内圈关键点集合
    public let rightEye: RightEye?

    @objc(FppRightEyeEyelid)
    @objcMembers public final class RightEyeEyelid: NSObject, Codable {
        // MARK: - 从右眼外眼角位置起始，按逆时针顺序检测到的左眼外圈关键点位置序列。
        public let rightEyeEyelid0: FaceppPoint
        public let rightEyeEyelid1: FaceppPoint
        public let rightEyeEyelid2: FaceppPoint
        public let rightEyeEyelid3: FaceppPoint
        public let rightEyeEyelid4: FaceppPoint
        public let rightEyeEyelid5: FaceppPoint
        public let rightEyeEyelid6: FaceppPoint
        public let rightEyeEyelid7: FaceppPoint
        public let rightEyeEyelid8: FaceppPoint
        public let rightEyeEyelid9: FaceppPoint
        public let rightEyeEyelid10: FaceppPoint
        public let rightEyeEyelid11: FaceppPoint
        public let rightEyeEyelid12: FaceppPoint
        public let rightEyeEyelid13: FaceppPoint
        public let rightEyeEyelid14: FaceppPoint
        public let rightEyeEyelid15: FaceppPoint
        public let rightEyeEyelid16: FaceppPoint
        public let rightEyeEyelid17: FaceppPoint
        public let rightEyeEyelid18: FaceppPoint
        public let rightEyeEyelid19: FaceppPoint
        public let rightEyeEyelid20: FaceppPoint
        public let rightEyeEyelid21: FaceppPoint
        public let rightEyeEyelid22: FaceppPoint
        public let rightEyeEyelid23: FaceppPoint
        public let rightEyeEyelid24: FaceppPoint
        public let rightEyeEyelid25: FaceppPoint
        public let rightEyeEyelid26: FaceppPoint
        public let rightEyeEyelid27: FaceppPoint
        public let rightEyeEyelid28: FaceppPoint
        public let rightEyeEyelid29: FaceppPoint
        public let rightEyeEyelid30: FaceppPoint
        public let rightEyeEyelid31: FaceppPoint
        public let rightEyeEyelid32: FaceppPoint
        public let rightEyeEyelid33: FaceppPoint
        public let rightEyeEyelid34: FaceppPoint
        public let rightEyeEyelid35: FaceppPoint
        public let rightEyeEyelid36: FaceppPoint
        public let rightEyeEyelid37: FaceppPoint
        public let rightEyeEyelid38: FaceppPoint
        public let rightEyeEyelid39: FaceppPoint
        public let rightEyeEyelid40: FaceppPoint
        public let rightEyeEyelid41: FaceppPoint
        public let rightEyeEyelid42: FaceppPoint
        public let rightEyeEyelid43: FaceppPoint
        public let rightEyeEyelid44: FaceppPoint
        public let rightEyeEyelid45: FaceppPoint
        public let rightEyeEyelid46: FaceppPoint
        public let rightEyeEyelid47: FaceppPoint
        public let rightEyeEyelid48: FaceppPoint
        public let rightEyeEyelid49: FaceppPoint
        public let rightEyeEyelid50: FaceppPoint
        public let rightEyeEyelid51: FaceppPoint
        public let rightEyeEyelid52: FaceppPoint
        public let rightEyeEyelid53: FaceppPoint
        public let rightEyeEyelid54: FaceppPoint
        public let rightEyeEyelid55: FaceppPoint
        public let rightEyeEyelid56: FaceppPoint
        public let rightEyeEyelid57: FaceppPoint
        public let rightEyeEyelid58: FaceppPoint
        public let rightEyeEyelid59: FaceppPoint
        public let rightEyeEyelid60: FaceppPoint
        public let rightEyeEyelid61: FaceppPoint
        public let rightEyeEyelid62: FaceppPoint
        public let rightEyeEyelid63: FaceppPoint
    }
    /// 右眼外圈关键点集合
    public let rightEyeEyelid: RightEyeEyelid?

    @objc(FppNose)
    @objcMembers public final class Nose: NSObject, Codable {
        // MARK: - 从鼻子上部左端位置起始到鼻尖，顺序检测到的鼻子关键点位置序列。
        public let noseLeft0: FaceppPoint
        public let noseLeft1: FaceppPoint
        public let noseLeft2: FaceppPoint
        public let noseLeft3: FaceppPoint
        public let noseLeft4: FaceppPoint
        public let noseLeft5: FaceppPoint
        public let noseLeft6: FaceppPoint
        public let noseLeft7: FaceppPoint
        public let noseLeft8: FaceppPoint
        public let noseLeft9: FaceppPoint
        public let noseLeft10: FaceppPoint
        public let noseLeft11: FaceppPoint
        public let noseLeft12: FaceppPoint
        public let noseLeft13: FaceppPoint
        public let noseLeft14: FaceppPoint
        public let noseLeft15: FaceppPoint
        public let noseLeft16: FaceppPoint
        public let noseLeft17: FaceppPoint
        public let noseLeft18: FaceppPoint
        public let noseLeft19: FaceppPoint
        public let noseLeft20: FaceppPoint
        public let noseLeft21: FaceppPoint
        public let noseLeft22: FaceppPoint
        public let noseLeft23: FaceppPoint
        public let noseLeft24: FaceppPoint
        public let noseLeft25: FaceppPoint
        public let noseLeft26: FaceppPoint
        public let noseLeft27: FaceppPoint
        public let noseLeft28: FaceppPoint
        public let noseLeft29: FaceppPoint
        public let noseLeft30: FaceppPoint
        public let noseLeft31: FaceppPoint
        public let noseLeft32: FaceppPoint
        public let noseLeft33: FaceppPoint
        public let noseLeft34: FaceppPoint
        public let noseLeft35: FaceppPoint
        public let noseLeft36: FaceppPoint
        public let noseLeft37: FaceppPoint
        public let noseLeft38: FaceppPoint
        public let noseLeft39: FaceppPoint
        public let noseLeft40: FaceppPoint
        public let noseLeft41: FaceppPoint
        public let noseLeft42: FaceppPoint
        public let noseLeft43: FaceppPoint
        public let noseLeft44: FaceppPoint
        public let noseLeft45: FaceppPoint
        public let noseLeft46: FaceppPoint
        public let noseLeft47: FaceppPoint
        public let noseLeft48: FaceppPoint
        public let noseLeft49: FaceppPoint
        public let noseLeft50: FaceppPoint
        public let noseLeft51: FaceppPoint
        public let noseLeft52: FaceppPoint
        public let noseLeft53: FaceppPoint
        public let noseLeft54: FaceppPoint
        public let noseLeft55: FaceppPoint
        public let noseLeft56: FaceppPoint
        public let noseLeft57: FaceppPoint
        public let noseLeft58: FaceppPoint
        public let noseLeft59: FaceppPoint
        public let noseLeft60: FaceppPoint
        public let noseLeft61: FaceppPoint
        public let noseLeft62: FaceppPoint
        // MARK: - 从鼻子上部右端端位置起始到鼻尖，顺序检测到的鼻子关键点位置序列
        public let noseRight0: FaceppPoint
        public let noseRight1: FaceppPoint
        public let noseRight2: FaceppPoint
        public let noseRight3: FaceppPoint
        public let noseRight4: FaceppPoint
        public let noseRight5: FaceppPoint
        public let noseRight6: FaceppPoint
        public let noseRight7: FaceppPoint
        public let noseRight8: FaceppPoint
        public let noseRight9: FaceppPoint
        public let noseRight10: FaceppPoint
        public let noseRight11: FaceppPoint
        public let noseRight12: FaceppPoint
        public let noseRight13: FaceppPoint
        public let noseRight14: FaceppPoint
        public let noseRight15: FaceppPoint
        public let noseRight16: FaceppPoint
        public let noseRight17: FaceppPoint
        public let noseRight18: FaceppPoint
        public let noseRight19: FaceppPoint
        public let noseRight20: FaceppPoint
        public let noseRight21: FaceppPoint
        public let noseRight22: FaceppPoint
        public let noseRight23: FaceppPoint
        public let noseRight24: FaceppPoint
        public let noseRight25: FaceppPoint
        public let noseRight26: FaceppPoint
        public let noseRight27: FaceppPoint
        public let noseRight28: FaceppPoint
        public let noseRight29: FaceppPoint
        public let noseRight30: FaceppPoint
        public let noseRight31: FaceppPoint
        public let noseRight32: FaceppPoint
        public let noseRight33: FaceppPoint
        public let noseRight34: FaceppPoint
        public let noseRight35: FaceppPoint
        public let noseRight36: FaceppPoint
        public let noseRight37: FaceppPoint
        public let noseRight38: FaceppPoint
        public let noseRight39: FaceppPoint
        public let noseRight40: FaceppPoint
        public let noseRight41: FaceppPoint
        public let noseRight42: FaceppPoint
        public let noseRight43: FaceppPoint
        public let noseRight44: FaceppPoint
        public let noseRight45: FaceppPoint
        public let noseRight46: FaceppPoint
        public let noseRight47: FaceppPoint
        public let noseRight48: FaceppPoint
        public let noseRight49: FaceppPoint
        public let noseRight50: FaceppPoint
        public let noseRight51: FaceppPoint
        public let noseRight52: FaceppPoint
        public let noseRight53: FaceppPoint
        public let noseRight54: FaceppPoint
        public let noseRight55: FaceppPoint
        public let noseRight56: FaceppPoint
        public let noseRight57: FaceppPoint
        public let noseRight58: FaceppPoint
        public let noseRight59: FaceppPoint
        public let noseRight60: FaceppPoint
        public let noseRight61: FaceppPoint
        public let noseRight62: FaceppPoint
        /// 左鼻孔位置（鼻孔上边缘中心）
        public let leftNostril: FaceppPoint
        /// 右鼻孔位置（鼻孔上边缘中心）
        public let rightNostril: FaceppPoint
        // MAKR: - 从眉心中间到人中，从上到下顺序检测到的鼻子中线关键点位置序列
        public let noseMidline0: FaceppPoint
        public let noseMidline1: FaceppPoint
        public let noseMidline2: FaceppPoint
        public let noseMidline3: FaceppPoint
        public let noseMidline4: FaceppPoint
        public let noseMidline5: FaceppPoint
        public let noseMidline6: FaceppPoint
        public let noseMidline7: FaceppPoint
        public let noseMidline8: FaceppPoint
        public let noseMidline9: FaceppPoint
        public let noseMidline10: FaceppPoint
        public let noseMidline11: FaceppPoint
        public let noseMidline12: FaceppPoint
        public let noseMidline13: FaceppPoint
        public let noseMidline14: FaceppPoint
        public let noseMidline15: FaceppPoint
        public let noseMidline16: FaceppPoint
        public let noseMidline17: FaceppPoint
        public let noseMidline18: FaceppPoint
        public let noseMidline19: FaceppPoint
        public let noseMidline20: FaceppPoint
        public let noseMidline21: FaceppPoint
        public let noseMidline22: FaceppPoint
        public let noseMidline23: FaceppPoint
        public let noseMidline24: FaceppPoint
        public let noseMidline25: FaceppPoint
        public let noseMidline26: FaceppPoint
        public let noseMidline27: FaceppPoint
        public let noseMidline28: FaceppPoint
        public let noseMidline29: FaceppPoint
        public let noseMidline30: FaceppPoint
        public let noseMidline31: FaceppPoint
        public let noseMidline32: FaceppPoint
        public let noseMidline33: FaceppPoint
        public let noseMidline34: FaceppPoint
        public let noseMidline35: FaceppPoint
        public let noseMidline36: FaceppPoint
        public let noseMidline37: FaceppPoint
        public let noseMidline38: FaceppPoint
        public let noseMidline39: FaceppPoint
        public let noseMidline40: FaceppPoint
        public let noseMidline41: FaceppPoint
        public let noseMidline42: FaceppPoint
        public let noseMidline43: FaceppPoint
        public let noseMidline44: FaceppPoint
        public let noseMidline45: FaceppPoint
        public let noseMidline46: FaceppPoint
        public let noseMidline47: FaceppPoint
        public let noseMidline48: FaceppPoint
        public let noseMidline49: FaceppPoint
        public let noseMidline50: FaceppPoint
        public let noseMidline51: FaceppPoint
        public let noseMidline52: FaceppPoint
        public let noseMidline53: FaceppPoint
        public let noseMidline54: FaceppPoint
        public let noseMidline55: FaceppPoint
        public let noseMidline56: FaceppPoint
        public let noseMidline57: FaceppPoint
        public let noseMidline58: FaceppPoint
        public let noseMidline59: FaceppPoint
    }
    /// 鼻子关键点集合
    public let nose: Nose?

    @objc(FppMouth)
    @objcMembers public final class Mouth: NSObject, Codable {
        // MARK: - 上嘴唇的上边缘。从左边嘴角开始，从左到右检测到的上嘴唇上边缘关键点位置序列。
        public let upperLip0: FaceppPoint
        public let upperLip1: FaceppPoint
        public let upperLip2: FaceppPoint
        public let upperLip3: FaceppPoint
        public let upperLip4: FaceppPoint
        public let upperLip5: FaceppPoint
        public let upperLip6: FaceppPoint
        public let upperLip7: FaceppPoint
        public let upperLip8: FaceppPoint
        public let upperLip9: FaceppPoint
        public let upperLip10: FaceppPoint
        public let upperLip11: FaceppPoint
        public let upperLip12: FaceppPoint
        public let upperLip13: FaceppPoint
        public let upperLip14: FaceppPoint
        public let upperLip15: FaceppPoint
        public let upperLip16: FaceppPoint
        public let upperLip17: FaceppPoint
        public let upperLip18: FaceppPoint
        public let upperLip19: FaceppPoint
        public let upperLip20: FaceppPoint
        public let upperLip21: FaceppPoint
        public let upperLip22: FaceppPoint
        public let upperLip23: FaceppPoint
        public let upperLip24: FaceppPoint
        public let upperLip25: FaceppPoint
        public let upperLip26: FaceppPoint
        public let upperLip27: FaceppPoint
        public let upperLip28: FaceppPoint
        public let upperLip29: FaceppPoint
        public let upperLip30: FaceppPoint
        public let upperLip31: FaceppPoint
        // MARK: - 上嘴唇的下边缘。从右到左检测到的上嘴唇下边缘关键点位置序列。
        public let upperLip32: FaceppPoint
        public let upperLip33: FaceppPoint
        public let upperLip34: FaceppPoint
        public let upperLip35: FaceppPoint
        public let upperLip36: FaceppPoint
        public let upperLip37: FaceppPoint
        public let upperLip38: FaceppPoint
        public let upperLip39: FaceppPoint
        public let upperLip40: FaceppPoint
        public let upperLip41: FaceppPoint
        public let upperLip42: FaceppPoint
        public let upperLip43: FaceppPoint
        public let upperLip44: FaceppPoint
        public let upperLip45: FaceppPoint
        public let upperLip46: FaceppPoint
        public let upperLip47: FaceppPoint
        public let upperLip48: FaceppPoint
        public let upperLip49: FaceppPoint
        public let upperLip50: FaceppPoint
        public let upperLip51: FaceppPoint
        public let upperLip52: FaceppPoint
        public let upperLip53: FaceppPoint
        public let upperLip54: FaceppPoint
        public let upperLip55: FaceppPoint
        public let upperLip56: FaceppPoint
        public let upperLip57: FaceppPoint
        public let upperLip58: FaceppPoint
        public let upperLip59: FaceppPoint
        public let upperLip60: FaceppPoint
        public let upperLip61: FaceppPoint
        public let upperLip62: FaceppPoint
        public let upperLip63: FaceppPoint
        // MARK: - 下嘴唇的下边缘。从左边嘴角开始，从左到右检测到的下嘴唇下边缘关键点位置序列。
        public let lowerLip0: FaceppPoint
        public let lowerLip1: FaceppPoint
        public let lowerLip2: FaceppPoint
        public let lowerLip3: FaceppPoint
        public let lowerLip4: FaceppPoint
        public let lowerLip5: FaceppPoint
        public let lowerLip6: FaceppPoint
        public let lowerLip7: FaceppPoint
        public let lowerLip8: FaceppPoint
        public let lowerLip9: FaceppPoint
        public let lowerLip10: FaceppPoint
        public let lowerLip11: FaceppPoint
        public let lowerLip12: FaceppPoint
        public let lowerLip13: FaceppPoint
        public let lowerLip14: FaceppPoint
        public let lowerLip15: FaceppPoint
        public let lowerLip16: FaceppPoint
        public let lowerLip17: FaceppPoint
        public let lowerLip18: FaceppPoint
        public let lowerLip19: FaceppPoint
        public let lowerLip20: FaceppPoint
        public let lowerLip21: FaceppPoint
        public let lowerLip22: FaceppPoint
        public let lowerLip23: FaceppPoint
        public let lowerLip24: FaceppPoint
        public let lowerLip25: FaceppPoint
        public let lowerLip26: FaceppPoint
        public let lowerLip27: FaceppPoint
        public let lowerLip28: FaceppPoint
        public let lowerLip29: FaceppPoint
        public let lowerLip30: FaceppPoint
        public let lowerLip31: FaceppPoint
        // MARK: - 下嘴唇的上边缘。从右到左检测到的下嘴唇上边缘关键点位置序列。
        public let lowerLip32: FaceppPoint
        public let lowerLip33: FaceppPoint
        public let lowerLip34: FaceppPoint
        public let lowerLip35: FaceppPoint
        public let lowerLip36: FaceppPoint
        public let lowerLip37: FaceppPoint
        public let lowerLip38: FaceppPoint
        public let lowerLip39: FaceppPoint
        public let lowerLip40: FaceppPoint
        public let lowerLip41: FaceppPoint
        public let lowerLip42: FaceppPoint
        public let lowerLip43: FaceppPoint
        public let lowerLip44: FaceppPoint
        public let lowerLip45: FaceppPoint
        public let lowerLip46: FaceppPoint
        public let lowerLip47: FaceppPoint
        public let lowerLip48: FaceppPoint
        public let lowerLip49: FaceppPoint
        public let lowerLip50: FaceppPoint
        public let lowerLip51: FaceppPoint
        public let lowerLip52: FaceppPoint
        public let lowerLip53: FaceppPoint
        public let lowerLip54: FaceppPoint
        public let lowerLip55: FaceppPoint
        public let lowerLip56: FaceppPoint
        public let lowerLip57: FaceppPoint
        public let lowerLip58: FaceppPoint
        public let lowerLip59: FaceppPoint
        public let lowerLip60: FaceppPoint
        public let lowerLip61: FaceppPoint
        public let lowerLip62: FaceppPoint
        public let lowerLip63: FaceppPoint
    }
}

extension ThousandLandMarkOption: FppDataRequestProtocol {
    @objc public func request(completionHandler: @escaping (Error?, ThousandLandmarkResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}
