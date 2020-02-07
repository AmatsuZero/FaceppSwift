//
//  DenseLandmark.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/7.
//

import Foundation

let kFaceBaseURL = kFaceappV1BaseURL?.appendingPathComponent("face")

public struct ThousandLandMarkOption: RequestProtocol {
    /// 人脸标识 face_token，优先使用该参数
    public var faceToken: String?
    /// 图片的 URL
    public var imageURL: URL?
    /// 图片的二进制文件，需要用 post multipart/form-data 的方式上传。
    public var imageFile: URL?
    /**
     base64 编码的二进制图片数据
     
     如果同时传入了 image_url、image_file 和 image_base64参数，本 API 使用顺序为image_file 优先，image_url最低。
     */
    public var imageBase64: String?
    
    public var returnLandMark: Set<ReturnLandMark>
    
    public enum ReturnLandMark: String, Option {
        case leftEyeBrow = "left_eyebrow"
        case rightEyeBrow = "right_eyebrow"
        case lefteye = "left_eye"
        case leftEyeEyelid = "left_eye_eyelid"
        case rightEye = "right_eye"
        case rightEyeEyelid = "right_eye_eyelid"
        case nose, mouse, face
    }
    
    var requsetURL: URL? {
        return kFaceBaseURL?.appendingPathComponent("thousandlandmark")
    }
    
    func paramsCheck() -> Bool {
        return faceToken != nil || imageURL != nil || imageFile != nil || imageBase64 != nil
    }
    
    func params(apiKey: String, apiSecret: String) -> Params {
        var params: Params = [
            "api_key": apiKey,
            "api_secret": apiSecret
        ]
        params["return_landmark"] = returnLandMark == .all
            ? "all"
            : returnLandMark.map { $0.rawValue }.joined(separator: ",")
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

public extension Set where Element == ThousandLandMarkOption.ReturnLandMark {
    static var all: Set {
        return Set(ThousandLandMarkOption.ReturnLandMark.allCases)
    }
}

public struct ThousandLandmarkResponse: ResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    
    public struct Face: Codable {
        /// 人脸矩形框的位置
        public let faceRectangle: FaceRectangle
        /// 人脸五官及轮廓的关键点坐标数组。
        public let landmark: DenseLandmark
    }
    /// 经过分析的人脸
    public let face: Face?
}

public struct DenseLandmark: Codable {
    // MARK: - 面部轮廓关键点集合。返回值为：
    public struct Face: Codable {
        //MARK: - 面部上半部分轮廓关键点，从右耳附近起始到左耳附近终，按逆时针顺序检测到的位置序列。
        public let faceHairline0: LandMarkInfo
        public let faceHairline1: LandMarkInfo
        public let faceHairline2: LandMarkInfo
        public let faceHairline3: LandMarkInfo
        public let faceHairline4: LandMarkInfo
        public let faceHairline5: LandMarkInfo
        public let faceHairline6: LandMarkInfo
        public let faceHairline7: LandMarkInfo
        public let faceHairline8: LandMarkInfo
        public let faceHairline9: LandMarkInfo
        public let faceHairline10: LandMarkInfo
        public let faceHairline11: LandMarkInfo
        public let faceHairline12: LandMarkInfo
        public let faceHairline13: LandMarkInfo
        public let faceHairline14: LandMarkInfo
        public let faceHairline15: LandMarkInfo
        public let faceHairline16: LandMarkInfo
        public let faceHairline17: LandMarkInfo
        public let faceHairline18: LandMarkInfo
        public let faceHairline19: LandMarkInfo
        public let faceHairline20: LandMarkInfo
        public let faceHairline21: LandMarkInfo
        public let faceHairline22: LandMarkInfo
        public let faceHairline23: LandMarkInfo
        public let faceHairline24: LandMarkInfo
        public let faceHairline25: LandMarkInfo
        public let faceHairline26: LandMarkInfo
        public let faceHairline27: LandMarkInfo
        public let faceHairline28: LandMarkInfo
        public let faceHairline29: LandMarkInfo
        public let faceHairline30: LandMarkInfo
        public let faceHairline31: LandMarkInfo
        public let faceHairline32: LandMarkInfo
        public let faceHairline33: LandMarkInfo
        public let faceHairline34: LandMarkInfo
        public let faceHairline35: LandMarkInfo
        public let faceHairline36: LandMarkInfo
        public let faceHairline37: LandMarkInfo
        public let faceHairline38: LandMarkInfo
        public let faceHairline39: LandMarkInfo
        public let faceHairline40: LandMarkInfo
        public let faceHairline41: LandMarkInfo
        public let faceHairline42: LandMarkInfo
        public let faceHairline43: LandMarkInfo
        public let faceHairline44: LandMarkInfo
        public let faceHairline45: LandMarkInfo
        public let faceHairline46: LandMarkInfo
        public let faceHairline47: LandMarkInfo
        public let faceHairline48: LandMarkInfo
        public let faceHairline49: LandMarkInfo
        public let faceHairline50: LandMarkInfo
        public let faceHairline51: LandMarkInfo
        public let faceHairline52: LandMarkInfo
        public let faceHairline53: LandMarkInfo
        public let faceHairline54: LandMarkInfo
        public let faceHairline55: LandMarkInfo
        public let faceHairline56: LandMarkInfo
        public let faceHairline57: LandMarkInfo
        public let faceHairline58: LandMarkInfo
        public let faceHairline59: LandMarkInfo
        public let faceHairline60: LandMarkInfo
        public let faceHairline61: LandMarkInfo
        public let faceHairline62: LandMarkInfo
        public let faceHairline63: LandMarkInfo
        public let faceHairline64: LandMarkInfo
        public let faceHairline65: LandMarkInfo
        public let faceHairline66: LandMarkInfo
        public let faceHairline67: LandMarkInfo
        public let faceHairline68: LandMarkInfo
        public let faceHairline69: LandMarkInfo
        public let faceHairline70: LandMarkInfo
        public let faceHairline71: LandMarkInfo
        public let faceHairline72: LandMarkInfo
        public let faceHairline73: LandMarkInfo
        public let faceHairline74: LandMarkInfo
        public let faceHairline75: LandMarkInfo
        public let faceHairline76: LandMarkInfo
        public let faceHairline77: LandMarkInfo
        public let faceHairline78: LandMarkInfo
        public let faceHairline79: LandMarkInfo
        public let faceHairline80: LandMarkInfo
        public let faceHairline81: LandMarkInfo
        public let faceHairline82: LandMarkInfo
        public let faceHairline83: LandMarkInfo
        public let faceHairline84: LandMarkInfo
        public let faceHairline85: LandMarkInfo
        public let faceHairline86: LandMarkInfo
        public let faceHairline87: LandMarkInfo
        public let faceHairline88: LandMarkInfo
        public let faceHairline89: LandMarkInfo
        public let faceHairline90: LandMarkInfo
        public let faceHairline91: LandMarkInfo
        public let faceHairline92: LandMarkInfo
        public let faceHairline93: LandMarkInfo
        public let faceHairline94: LandMarkInfo
        public let faceHairline95: LandMarkInfo
        public let faceHairline96: LandMarkInfo
        public let faceHairline97: LandMarkInfo
        public let faceHairline98: LandMarkInfo
        public let faceHairline99: LandMarkInfo
        public let faceHairline100: LandMarkInfo
        public let faceHairline101: LandMarkInfo
        public let faceHairline102: LandMarkInfo
        public let faceHairline103: LandMarkInfo
        public let faceHairline104: LandMarkInfo
        public let faceHairline105: LandMarkInfo
        public let faceHairline106: LandMarkInfo
        public let faceHairline107: LandMarkInfo
        public let faceHairline108: LandMarkInfo
        public let faceHairline109: LandMarkInfo
        public let faceHairline110: LandMarkInfo
        public let faceHairline111: LandMarkInfo
        public let faceHairline112: LandMarkInfo
        public let faceHairline113: LandMarkInfo
        public let faceHairline114: LandMarkInfo
        public let faceHairline115: LandMarkInfo
        public let faceHairline116: LandMarkInfo
        public let faceHairline117: LandMarkInfo
        public let faceHairline118: LandMarkInfo
        public let faceHairline119: LandMarkInfo
        public let faceHairline120: LandMarkInfo
        public let faceHairline121: LandMarkInfo
        public let faceHairline122: LandMarkInfo
        public let faceHairline123: LandMarkInfo
        public let faceHairline124: LandMarkInfo
        public let faceHairline125: LandMarkInfo
        public let faceHairline126: LandMarkInfo
        public let faceHairline127: LandMarkInfo
        public let faceHairline128: LandMarkInfo
        public let faceHairline129: LandMarkInfo
        public let faceHairline130: LandMarkInfo
        public let faceHairline131: LandMarkInfo
        public let faceHairline132: LandMarkInfo
        public let faceHairline133: LandMarkInfo
        public let faceHairline134: LandMarkInfo
        public let faceHairline135: LandMarkInfo
        public let faceHairline136: LandMarkInfo
        public let faceHairline137: LandMarkInfo
        public let faceHairline138: LandMarkInfo
        public let faceHairline139: LandMarkInfo
        public let faceHairline140: LandMarkInfo
        public let faceHairline141: LandMarkInfo
        public let faceHairline142: LandMarkInfo
        public let faceHairline143: LandMarkInfo
        public let faceHairline144: LandMarkInfo
        // MARK: - 面部下半部分右边轮廓关键点。从下巴起始到右耳附近，按逆时针顺序检测到的位置序列。face_contour_right_0为下巴中心位置。
        public let faceContourRight0: LandMarkInfo
        public let faceContourRight1: LandMarkInfo
        public let faceContourRight2: LandMarkInfo
        public let faceContourRight3: LandMarkInfo
        public let faceContourRight4: LandMarkInfo
        public let faceContourRight5: LandMarkInfo
        public let faceContourRight6: LandMarkInfo
        public let faceContourRight7: LandMarkInfo
        public let faceContourRight8: LandMarkInfo
        public let faceContourRight9: LandMarkInfo
        public let faceContourRight10: LandMarkInfo
        public let faceContourRight11: LandMarkInfo
        public let faceContourRight12: LandMarkInfo
        public let faceContourRight13: LandMarkInfo
        public let faceContourRight14: LandMarkInfo
        public let faceContourRight15: LandMarkInfo
        public let faceContourRight16: LandMarkInfo
        public let faceContourRight17: LandMarkInfo
        public let faceContourRight18: LandMarkInfo
        public let faceContourRight19: LandMarkInfo
        public let faceContourRight20: LandMarkInfo
        public let faceContourRight21: LandMarkInfo
        public let faceContourRight22: LandMarkInfo
        public let faceContourRight23: LandMarkInfo
        public let faceContourRight24: LandMarkInfo
        public let faceContourRight25: LandMarkInfo
        public let faceContourRight26: LandMarkInfo
        public let faceContourRight27: LandMarkInfo
        public let faceContourRight28: LandMarkInfo
        public let faceContourRight29: LandMarkInfo
        public let faceContourRight30: LandMarkInfo
        public let faceContourRight31: LandMarkInfo
        public let faceContourRight32: LandMarkInfo
        public let faceContourRight33: LandMarkInfo
        public let faceContourRight34: LandMarkInfo
        public let faceContourRight35: LandMarkInfo
        public let faceContourRight36: LandMarkInfo
        public let faceContourRight37: LandMarkInfo
        public let faceContourRight38: LandMarkInfo
        public let faceContourRight39: LandMarkInfo
        public let faceContourRight40: LandMarkInfo
        public let faceContourRight41: LandMarkInfo
        public let faceContourRight42: LandMarkInfo
        public let faceContourRight43: LandMarkInfo
        public let faceContourRight44: LandMarkInfo
        public let faceContourRight45: LandMarkInfo
        public let faceContourRight46: LandMarkInfo
        public let faceContourRight47: LandMarkInfo
        public let faceContourRight48: LandMarkInfo
        public let faceContourRight49: LandMarkInfo
        public let faceContourRight50: LandMarkInfo
        public let faceContourRight51: LandMarkInfo
        public let faceContourRight52: LandMarkInfo
        public let faceContourRight53: LandMarkInfo
        public let faceContourRight54: LandMarkInfo
        public let faceContourRight55: LandMarkInfo
        public let faceContourRight56: LandMarkInfo
        public let faceContourRight57: LandMarkInfo
        public let faceContourRight58: LandMarkInfo
        public let faceContourRight59: LandMarkInfo
        public let faceContourRight60: LandMarkInfo
        public let faceContourRight61: LandMarkInfo
        public let faceContourRight62: LandMarkInfo
        public let faceContourRight63: LandMarkInfo
        // MARK: - 面部下半部分左边轮廓关键点。从下巴起始到左耳附近，按顺时针顺序检测到的位置序列。
        public let faceContourLeft0: LandMarkInfo
        public let faceContourLeft1: LandMarkInfo
        public let faceContourLeft2: LandMarkInfo
        public let faceContourLeft3: LandMarkInfo
        public let faceContourLeft4: LandMarkInfo
        public let faceContourLeft5: LandMarkInfo
        public let faceContourLeft6: LandMarkInfo
        public let faceContourLeft7: LandMarkInfo
        public let faceContourLeft8: LandMarkInfo
        public let faceContourLeft9: LandMarkInfo
        public let faceContourLeft10: LandMarkInfo
        public let faceContourLeft11: LandMarkInfo
        public let faceContourLeft12: LandMarkInfo
        public let faceContourLeft13: LandMarkInfo
        public let faceContourLeft14: LandMarkInfo
        public let faceContourLeft15: LandMarkInfo
        public let faceContourLeft16: LandMarkInfo
        public let faceContourLeft17: LandMarkInfo
        public let faceContourLeft18: LandMarkInfo
        public let faceContourLeft19: LandMarkInfo
        public let faceContourLeft20: LandMarkInfo
        public let faceContourLeft21: LandMarkInfo
        public let faceContourLeft22: LandMarkInfo
        public let faceContourLeft23: LandMarkInfo
        public let faceContourLeft24: LandMarkInfo
        public let faceContourLeft25: LandMarkInfo
        public let faceContourLeft26: LandMarkInfo
        public let faceContourLeft27: LandMarkInfo
        public let faceContourLeft28: LandMarkInfo
        public let faceContourLeft29: LandMarkInfo
        public let faceContourLeft30: LandMarkInfo
        public let faceContourLeft31: LandMarkInfo
        public let faceContourLeft32: LandMarkInfo
        public let faceContourLeft33: LandMarkInfo
        public let faceContourLeft34: LandMarkInfo
        public let faceContourLeft35: LandMarkInfo
        public let faceContourLeft36: LandMarkInfo
        public let faceContourLeft37: LandMarkInfo
        public let faceContourLeft38: LandMarkInfo
        public let faceContourLeft39: LandMarkInfo
        public let faceContourLeft40: LandMarkInfo
        public let faceContourLeft41: LandMarkInfo
        public let faceContourLeft42: LandMarkInfo
        public let faceContourLeft43: LandMarkInfo
        public let faceContourLeft44: LandMarkInfo
        public let faceContourLeft45: LandMarkInfo
        public let faceContourLeft46: LandMarkInfo
        public let faceContourLeft47: LandMarkInfo
        public let faceContourLeft48: LandMarkInfo
        public let faceContourLeft49: LandMarkInfo
        public let faceContourLeft50: LandMarkInfo
        public let faceContourLeft51: LandMarkInfo
        public let faceContourLeft52: LandMarkInfo
        public let faceContourLeft53: LandMarkInfo
        public let faceContourLeft54: LandMarkInfo
        public let faceContourLeft55: LandMarkInfo
        public let faceContourLeft56: LandMarkInfo
        public let faceContourLeft57: LandMarkInfo
        public let faceContourLeft58: LandMarkInfo
        public let faceContourLeft59: LandMarkInfo
        public let faceContourLeft60: LandMarkInfo
        public let faceContourLeft61: LandMarkInfo
        public let faceContourLeft62: LandMarkInfo
        public let faceContourLeft63: LandMarkInfo
    }
    /// 面部轮廓关键点集合
    public let face: Face?
    // MARK: - 从左眉左端中心位置起始，按顺时针顺序检测到的左眉关键点位置序列。
    public struct LeftEyebrow: Codable {
        public let leftEyebrow0: LandMarkInfo
        public let leftEyebrow1: LandMarkInfo
        public let leftEyebrow2: LandMarkInfo
        public let leftEyebrow3: LandMarkInfo
        public let leftEyebrow4: LandMarkInfo
        public let leftEyebrow5: LandMarkInfo
        public let leftEyebrow6: LandMarkInfo
        public let leftEyebrow7: LandMarkInfo
        public let leftEyebrow8: LandMarkInfo
        public let leftEyebrow9: LandMarkInfo
        public let leftEyebrow10: LandMarkInfo
        public let leftEyebrow11: LandMarkInfo
        public let leftEyebrow12: LandMarkInfo
        public let leftEyebrow13: LandMarkInfo
        public let leftEyebrow14: LandMarkInfo
        public let leftEyebrow15: LandMarkInfo
        public let leftEyebrow16: LandMarkInfo
        public let leftEyebrow17: LandMarkInfo
        public let leftEyebrow18: LandMarkInfo
        public let leftEyebrow19: LandMarkInfo
        public let leftEyebrow20: LandMarkInfo
        public let leftEyebrow21: LandMarkInfo
        public let leftEyebrow22: LandMarkInfo
        public let leftEyebrow23: LandMarkInfo
        public let leftEyebrow24: LandMarkInfo
        public let leftEyebrow25: LandMarkInfo
        public let leftEyebrow26: LandMarkInfo
        public let leftEyebrow27: LandMarkInfo
        public let leftEyebrow28: LandMarkInfo
        public let leftEyebrow29: LandMarkInfo
        public let leftEyebrow30: LandMarkInfo
        public let leftEyebrow31: LandMarkInfo
        public let leftEyebrow32: LandMarkInfo
        public let leftEyebrow33: LandMarkInfo
        public let leftEyebrow34: LandMarkInfo
        public let leftEyebrow35: LandMarkInfo
        public let leftEyebrow36: LandMarkInfo
        public let leftEyebrow37: LandMarkInfo
        public let leftEyebrow38: LandMarkInfo
        public let leftEyebrow39: LandMarkInfo
        public let leftEyebrow40: LandMarkInfo
        public let leftEyebrow41: LandMarkInfo
        public let leftEyebrow42: LandMarkInfo
        public let leftEyebrow43: LandMarkInfo
        public let leftEyebrow44: LandMarkInfo
        public let leftEyebrow45: LandMarkInfo
        public let leftEyebrow46: LandMarkInfo
        public let leftEyebrow47: LandMarkInfo
        public let leftEyebrow48: LandMarkInfo
        public let leftEyebrow49: LandMarkInfo
        public let leftEyebrow50: LandMarkInfo
        public let leftEyebrow51: LandMarkInfo
        public let leftEyebrow52: LandMarkInfo
        public let leftEyebrow53: LandMarkInfo
        public let leftEyebrow54: LandMarkInfo
        public let leftEyebrow55: LandMarkInfo
        public let leftEyebrow56: LandMarkInfo
        public let leftEyebrow57: LandMarkInfo
        public let leftEyebrow58: LandMarkInfo
        public let leftEyebrow59: LandMarkInfo
        public let leftEyebrow60: LandMarkInfo
        public let leftEyebrow61: LandMarkInfo
        public let leftEyebrow62: LandMarkInfo
        public let leftEyebrow63: LandMarkInfo
    }
    /// 左眉毛关键点集合
    public let leftEyebrow: LeftEyebrow?
    // MAKR: - 从右眉右端中心位置起始，按逆时针顺序检测到的右眉关键点位置序列。
    public struct RightEyebrow: Codable {
        public let rightEyebrow0: LandMarkInfo
        public let rightEyebrow1: LandMarkInfo
        public let rightEyebrow2: LandMarkInfo
        public let rightEyebrow3: LandMarkInfo
        public let rightEyebrow4: LandMarkInfo
        public let rightEyebrow5: LandMarkInfo
        public let rightEyebrow6: LandMarkInfo
        public let rightEyebrow7: LandMarkInfo
        public let rightEyebrow8: LandMarkInfo
        public let rightEyebrow9: LandMarkInfo
        public let rightEyebrow10: LandMarkInfo
        public let rightEyebrow11: LandMarkInfo
        public let rightEyebrow12: LandMarkInfo
        public let rightEyebrow13: LandMarkInfo
        public let rightEyebrow14: LandMarkInfo
        public let rightEyebrow15: LandMarkInfo
        public let rightEyebrow16: LandMarkInfo
        public let rightEyebrow17: LandMarkInfo
        public let rightEyebrow18: LandMarkInfo
        public let rightEyebrow19: LandMarkInfo
        public let rightEyebrow20: LandMarkInfo
        public let rightEyebrow21: LandMarkInfo
        public let rightEyebrow22: LandMarkInfo
        public let rightEyebrow23: LandMarkInfo
        public let rightEyebrow24: LandMarkInfo
        public let rightEyebrow25: LandMarkInfo
        public let rightEyebrow26: LandMarkInfo
        public let rightEyebrow27: LandMarkInfo
        public let rightEyebrow28: LandMarkInfo
        public let rightEyebrow29: LandMarkInfo
        public let rightEyebrow30: LandMarkInfo
        public let rightEyebrow31: LandMarkInfo
        public let rightEyebrow32: LandMarkInfo
        public let rightEyebrow33: LandMarkInfo
        public let rightEyebrow34: LandMarkInfo
        public let rightEyebrow35: LandMarkInfo
        public let rightEyebrow36: LandMarkInfo
        public let rightEyebrow37: LandMarkInfo
        public let rightEyebrow38: LandMarkInfo
        public let rightEyebrow39: LandMarkInfo
        public let rightEyebrow40: LandMarkInfo
        public let rightEyebrow41: LandMarkInfo
        public let rightEyebrow42: LandMarkInfo
        public let rightEyebrow43: LandMarkInfo
        public let rightEyebrow44: LandMarkInfo
        public let rightEyebrow45: LandMarkInfo
        public let rightEyebrow46: LandMarkInfo
        public let rightEyebrow47: LandMarkInfo
        public let rightEyebrow48: LandMarkInfo
        public let rightEyebrow49: LandMarkInfo
        public let rightEyebrow50: LandMarkInfo
        public let rightEyebrow51: LandMarkInfo
        public let rightEyebrow52: LandMarkInfo
        public let rightEyebrow53: LandMarkInfo
        public let rightEyebrow54: LandMarkInfo
        public let rightEyebrow55: LandMarkInfo
        public let rightEyebrow56: LandMarkInfo
        public let rightEyebrow57: LandMarkInfo
        public let rightEyebrow58: LandMarkInfo
        public let rightEyebrow59: LandMarkInfo
        public let rightEyebrow60: LandMarkInfo
        public let rightEyebrow61: LandMarkInfo
        public let rightEyebrow62: LandMarkInfo
        public let rightEyebrow63: LandMarkInfo
    }
    /// 右眉毛关键点集合
    public let rightEyebrow: RightEyebrow?
    
    public struct LeftEye: Codable {
        //MARK: - 从左眼左端中心位置起始，按顺时针顺序检测到的左眼关键点位置序列。
        public let leftEye0: LandMarkInfo
        public let leftEye1: LandMarkInfo
        public let leftEye2: LandMarkInfo
        public let leftEye3: LandMarkInfo
        public let leftEye4: LandMarkInfo
        public let leftEye5: LandMarkInfo
        public let leftEye6: LandMarkInfo
        public let leftEye7: LandMarkInfo
        public let leftEye8: LandMarkInfo
        public let leftEye9: LandMarkInfo
        public let leftEye10: LandMarkInfo
        public let leftEye11: LandMarkInfo
        public let leftEye12: LandMarkInfo
        public let leftEye13: LandMarkInfo
        public let leftEye14: LandMarkInfo
        public let leftEye15: LandMarkInfo
        public let leftEye16: LandMarkInfo
        public let leftEye17: LandMarkInfo
        public let leftEye18: LandMarkInfo
        public let leftEye19: LandMarkInfo
        public let leftEye20: LandMarkInfo
        public let leftEye21: LandMarkInfo
        public let leftEye22: LandMarkInfo
        public let leftEye23: LandMarkInfo
        public let leftEye24: LandMarkInfo
        public let leftEye25: LandMarkInfo
        public let leftEye26: LandMarkInfo
        public let leftEye27: LandMarkInfo
        public let leftEye28: LandMarkInfo
        public let leftEye29: LandMarkInfo
        public let leftEye30: LandMarkInfo
        public let leftEye31: LandMarkInfo
        public let leftEye32: LandMarkInfo
        public let leftEye33: LandMarkInfo
        public let leftEye34: LandMarkInfo
        public let leftEye35: LandMarkInfo
        public let leftEye36: LandMarkInfo
        public let leftEye37: LandMarkInfo
        public let leftEye38: LandMarkInfo
        public let leftEye39: LandMarkInfo
        public let leftEye40: LandMarkInfo
        public let leftEye41: LandMarkInfo
        public let leftEye42: LandMarkInfo
        public let leftEye43: LandMarkInfo
        public let leftEye44: LandMarkInfo
        public let leftEye45: LandMarkInfo
        public let leftEye46: LandMarkInfo
        public let leftEye47: LandMarkInfo
        public let leftEye48: LandMarkInfo
        public let leftEye49: LandMarkInfo
        public let leftEye50: LandMarkInfo
        public let leftEye51: LandMarkInfo
        public let leftEye52: LandMarkInfo
        public let leftEye53: LandMarkInfo
        public let leftEye54: LandMarkInfo
        public let leftEye55: LandMarkInfo
        public let leftEye56: LandMarkInfo
        public let leftEye57: LandMarkInfo
        public let leftEye58: LandMarkInfo
        public let leftEye59: LandMarkInfo
        public let leftEye60: LandMarkInfo
        public let leftEye61: LandMarkInfo
        public let leftEye62: LandMarkInfo
        /// 左眼瞳孔中心位置
        public let leftEyePupilCenter: LandMarkInfo
        /// 左眼瞳孔半径
        public let leftEyePupilRadius: Float
    }
    /// 左眼内圈关键点集合
    public let leftEye: LeftEye?
    
    public struct LeftEyeEyelid: Codable {
        // MARK: - 从左眼外眼角位置起始，按顺时针顺序检测到的左眼外圈关键点位置序列。
        public let leftEyeEyelid0: LandMarkInfo
        public let leftEyeEyelid1: LandMarkInfo
        public let leftEyeEyelid2: LandMarkInfo
        public let leftEyeEyelid3: LandMarkInfo
        public let leftEyeEyelid4: LandMarkInfo
        public let leftEyeEyelid5: LandMarkInfo
        public let leftEyeEyelid6: LandMarkInfo
        public let leftEyeEyelid7: LandMarkInfo
        public let leftEyeEyelid8: LandMarkInfo
        public let leftEyeEyelid9: LandMarkInfo
        public let leftEyeEyelid10: LandMarkInfo
        public let leftEyeEyelid11: LandMarkInfo
        public let leftEyeEyelid12: LandMarkInfo
        public let leftEyeEyelid13: LandMarkInfo
        public let leftEyeEyelid14: LandMarkInfo
        public let leftEyeEyelid15: LandMarkInfo
        public let leftEyeEyelid16: LandMarkInfo
        public let leftEyeEyelid17: LandMarkInfo
        public let leftEyeEyelid18: LandMarkInfo
        public let leftEyeEyelid19: LandMarkInfo
        public let leftEyeEyelid20: LandMarkInfo
        public let leftEyeEyelid21: LandMarkInfo
        public let leftEyeEyelid22: LandMarkInfo
        public let leftEyeEyelid23: LandMarkInfo
        public let leftEyeEyelid24: LandMarkInfo
        public let leftEyeEyelid25: LandMarkInfo
        public let leftEyeEyelid26: LandMarkInfo
        public let leftEyeEyelid27: LandMarkInfo
        public let leftEyeEyelid28: LandMarkInfo
        public let leftEyeEyelid29: LandMarkInfo
        public let leftEyeEyelid30: LandMarkInfo
        public let leftEyeEyelid31: LandMarkInfo
        public let leftEyeEyelid32: LandMarkInfo
        public let leftEyeEyelid33: LandMarkInfo
        public let leftEyeEyelid34: LandMarkInfo
        public let leftEyeEyelid35: LandMarkInfo
        public let leftEyeEyelid36: LandMarkInfo
        public let leftEyeEyelid37: LandMarkInfo
        public let leftEyeEyelid38: LandMarkInfo
        public let leftEyeEyelid39: LandMarkInfo
        public let leftEyeEyelid40: LandMarkInfo
        public let leftEyeEyelid41: LandMarkInfo
        public let leftEyeEyelid42: LandMarkInfo
        public let leftEyeEyelid43: LandMarkInfo
        public let leftEyeEyelid44: LandMarkInfo
        public let leftEyeEyelid45: LandMarkInfo
        public let leftEyeEyelid46: LandMarkInfo
        public let leftEyeEyelid47: LandMarkInfo
        public let leftEyeEyelid48: LandMarkInfo
        public let leftEyeEyelid49: LandMarkInfo
        public let leftEyeEyelid50: LandMarkInfo
        public let leftEyeEyelid51: LandMarkInfo
        public let leftEyeEyelid52: LandMarkInfo
        public let leftEyeEyelid53: LandMarkInfo
        public let leftEyeEyelid54: LandMarkInfo
        public let leftEyeEyelid55: LandMarkInfo
        public let leftEyeEyelid56: LandMarkInfo
        public let leftEyeEyelid57: LandMarkInfo
        public let leftEyeEyelid58: LandMarkInfo
        public let leftEyeEyelid59: LandMarkInfo
        public let leftEyeEyelid60: LandMarkInfo
        public let leftEyeEyelid61: LandMarkInfo
        public let leftEyeEyelid62: LandMarkInfo
        public let leftEyeEyelid63: LandMarkInfo
    }
    /// 左眼外圈关键点集合
    public let leftEyeEyelid: LeftEyeEyelid?
    
    public struct RightEye: Codable {
        // MARK: - 从右眼右端中心位置起始，按逆时针顺序检测到的右眼关键点位置序列
        public let rightEye0: LandMarkInfo
        public let rightEye1: LandMarkInfo
        public let rightEye2: LandMarkInfo
        public let rightEye3: LandMarkInfo
        public let rightEye4: LandMarkInfo
        public let rightEye5: LandMarkInfo
        public let rightEye6: LandMarkInfo
        public let rightEye7: LandMarkInfo
        public let rightEye8: LandMarkInfo
        public let rightEye9: LandMarkInfo
        public let rightEye10: LandMarkInfo
        public let rightEye11: LandMarkInfo
        public let rightEye12: LandMarkInfo
        public let rightEye13: LandMarkInfo
        public let rightEye14: LandMarkInfo
        public let rightEye15: LandMarkInfo
        public let rightEye16: LandMarkInfo
        public let rightEye17: LandMarkInfo
        public let rightEye18: LandMarkInfo
        public let rightEye19: LandMarkInfo
        public let rightEye20: LandMarkInfo
        public let rightEye21: LandMarkInfo
        public let rightEye22: LandMarkInfo
        public let rightEye23: LandMarkInfo
        public let rightEye24: LandMarkInfo
        public let rightEye25: LandMarkInfo
        public let rightEye26: LandMarkInfo
        public let rightEye27: LandMarkInfo
        public let rightEye28: LandMarkInfo
        public let rightEye29: LandMarkInfo
        public let rightEye30: LandMarkInfo
        public let rightEye31: LandMarkInfo
        public let rightEye32: LandMarkInfo
        public let rightEye33: LandMarkInfo
        public let rightEye34: LandMarkInfo
        public let rightEye35: LandMarkInfo
        public let rightEye36: LandMarkInfo
        public let rightEye37: LandMarkInfo
        public let rightEye38: LandMarkInfo
        public let rightEye39: LandMarkInfo
        public let rightEye40: LandMarkInfo
        public let rightEye41: LandMarkInfo
        public let rightEye42: LandMarkInfo
        public let rightEye43: LandMarkInfo
        public let rightEye44: LandMarkInfo
        public let rightEye45: LandMarkInfo
        public let rightEye46: LandMarkInfo
        public let rightEye47: LandMarkInfo
        public let rightEye48: LandMarkInfo
        public let rightEye49: LandMarkInfo
        public let rightEye50: LandMarkInfo
        public let rightEye51: LandMarkInfo
        public let rightEye52: LandMarkInfo
        public let rightEye53: LandMarkInfo
        public let rightEye54: LandMarkInfo
        public let rightEye55: LandMarkInfo
        public let rightEye56: LandMarkInfo
        public let rightEye57: LandMarkInfo
        public let rightEye58: LandMarkInfo
        public let rightEye59: LandMarkInfo
        public let rightEye60: LandMarkInfo
        public let rightEye61: LandMarkInfo
        public let rightEye62: LandMarkInfo
        /// 右眼瞳孔中心位置
        public let rightEyePupilCenter: LandMarkInfo
        /// 右眼瞳孔半径
        public let rightEyePupilRadius: Float
    }
    /// 右眼内圈关键点集合
    public let rightEye: RightEye?
    
    public struct RightEyeEyelid: Codable {
        // MARK: - 从右眼外眼角位置起始，按逆时针顺序检测到的左眼外圈关键点位置序列。
        public let rightEyeEyelid0: LandMarkInfo
        public let rightEyeEyelid1: LandMarkInfo
        public let rightEyeEyelid2: LandMarkInfo
        public let rightEyeEyelid3: LandMarkInfo
        public let rightEyeEyelid4: LandMarkInfo
        public let rightEyeEyelid5: LandMarkInfo
        public let rightEyeEyelid6: LandMarkInfo
        public let rightEyeEyelid7: LandMarkInfo
        public let rightEyeEyelid8: LandMarkInfo
        public let rightEyeEyelid9: LandMarkInfo
        public let rightEyeEyelid10: LandMarkInfo
        public let rightEyeEyelid11: LandMarkInfo
        public let rightEyeEyelid12: LandMarkInfo
        public let rightEyeEyelid13: LandMarkInfo
        public let rightEyeEyelid14: LandMarkInfo
        public let rightEyeEyelid15: LandMarkInfo
        public let rightEyeEyelid16: LandMarkInfo
        public let rightEyeEyelid17: LandMarkInfo
        public let rightEyeEyelid18: LandMarkInfo
        public let rightEyeEyelid19: LandMarkInfo
        public let rightEyeEyelid20: LandMarkInfo
        public let rightEyeEyelid21: LandMarkInfo
        public let rightEyeEyelid22: LandMarkInfo
        public let rightEyeEyelid23: LandMarkInfo
        public let rightEyeEyelid24: LandMarkInfo
        public let rightEyeEyelid25: LandMarkInfo
        public let rightEyeEyelid26: LandMarkInfo
        public let rightEyeEyelid27: LandMarkInfo
        public let rightEyeEyelid28: LandMarkInfo
        public let rightEyeEyelid29: LandMarkInfo
        public let rightEyeEyelid30: LandMarkInfo
        public let rightEyeEyelid31: LandMarkInfo
        public let rightEyeEyelid32: LandMarkInfo
        public let rightEyeEyelid33: LandMarkInfo
        public let rightEyeEyelid34: LandMarkInfo
        public let rightEyeEyelid35: LandMarkInfo
        public let rightEyeEyelid36: LandMarkInfo
        public let rightEyeEyelid37: LandMarkInfo
        public let rightEyeEyelid38: LandMarkInfo
        public let rightEyeEyelid39: LandMarkInfo
        public let rightEyeEyelid40: LandMarkInfo
        public let rightEyeEyelid41: LandMarkInfo
        public let rightEyeEyelid42: LandMarkInfo
        public let rightEyeEyelid43: LandMarkInfo
        public let rightEyeEyelid44: LandMarkInfo
        public let rightEyeEyelid45: LandMarkInfo
        public let rightEyeEyelid46: LandMarkInfo
        public let rightEyeEyelid47: LandMarkInfo
        public let rightEyeEyelid48: LandMarkInfo
        public let rightEyeEyelid49: LandMarkInfo
        public let rightEyeEyelid50: LandMarkInfo
        public let rightEyeEyelid51: LandMarkInfo
        public let rightEyeEyelid52: LandMarkInfo
        public let rightEyeEyelid53: LandMarkInfo
        public let rightEyeEyelid54: LandMarkInfo
        public let rightEyeEyelid55: LandMarkInfo
        public let rightEyeEyelid56: LandMarkInfo
        public let rightEyeEyelid57: LandMarkInfo
        public let rightEyeEyelid58: LandMarkInfo
        public let rightEyeEyelid59: LandMarkInfo
        public let rightEyeEyelid60: LandMarkInfo
        public let rightEyeEyelid61: LandMarkInfo
        public let rightEyeEyelid62: LandMarkInfo
        public let rightEyeEyelid63: LandMarkInfo
    }
    /// 右眼外圈关键点集合
    public let rightEyeEyelid: RightEyeEyelid?
    
    public struct Nose: Codable {
        // MARK: - 从鼻子上部左端位置起始到鼻尖，顺序检测到的鼻子关键点位置序列。
        public let noseLeft0: LandMarkInfo
        public let noseLeft1: LandMarkInfo
        public let noseLeft2: LandMarkInfo
        public let noseLeft3: LandMarkInfo
        public let noseLeft4: LandMarkInfo
        public let noseLeft5: LandMarkInfo
        public let noseLeft6: LandMarkInfo
        public let noseLeft7: LandMarkInfo
        public let noseLeft8: LandMarkInfo
        public let noseLeft9: LandMarkInfo
        public let noseLeft10: LandMarkInfo
        public let noseLeft11: LandMarkInfo
        public let noseLeft12: LandMarkInfo
        public let noseLeft13: LandMarkInfo
        public let noseLeft14: LandMarkInfo
        public let noseLeft15: LandMarkInfo
        public let noseLeft16: LandMarkInfo
        public let noseLeft17: LandMarkInfo
        public let noseLeft18: LandMarkInfo
        public let noseLeft19: LandMarkInfo
        public let noseLeft20: LandMarkInfo
        public let noseLeft21: LandMarkInfo
        public let noseLeft22: LandMarkInfo
        public let noseLeft23: LandMarkInfo
        public let noseLeft24: LandMarkInfo
        public let noseLeft25: LandMarkInfo
        public let noseLeft26: LandMarkInfo
        public let noseLeft27: LandMarkInfo
        public let noseLeft28: LandMarkInfo
        public let noseLeft29: LandMarkInfo
        public let noseLeft30: LandMarkInfo
        public let noseLeft31: LandMarkInfo
        public let noseLeft32: LandMarkInfo
        public let noseLeft33: LandMarkInfo
        public let noseLeft34: LandMarkInfo
        public let noseLeft35: LandMarkInfo
        public let noseLeft36: LandMarkInfo
        public let noseLeft37: LandMarkInfo
        public let noseLeft38: LandMarkInfo
        public let noseLeft39: LandMarkInfo
        public let noseLeft40: LandMarkInfo
        public let noseLeft41: LandMarkInfo
        public let noseLeft42: LandMarkInfo
        public let noseLeft43: LandMarkInfo
        public let noseLeft44: LandMarkInfo
        public let noseLeft45: LandMarkInfo
        public let noseLeft46: LandMarkInfo
        public let noseLeft47: LandMarkInfo
        public let noseLeft48: LandMarkInfo
        public let noseLeft49: LandMarkInfo
        public let noseLeft50: LandMarkInfo
        public let noseLeft51: LandMarkInfo
        public let noseLeft52: LandMarkInfo
        public let noseLeft53: LandMarkInfo
        public let noseLeft54: LandMarkInfo
        public let noseLeft55: LandMarkInfo
        public let noseLeft56: LandMarkInfo
        public let noseLeft57: LandMarkInfo
        public let noseLeft58: LandMarkInfo
        public let noseLeft59: LandMarkInfo
        public let noseLeft60: LandMarkInfo
        public let noseLeft61: LandMarkInfo
        public let noseLeft62: LandMarkInfo
        // MARK: - 从鼻子上部右端端位置起始到鼻尖，顺序检测到的鼻子关键点位置序列
        public let noseRight0: LandMarkInfo
        public let noseRight1: LandMarkInfo
        public let noseRight2: LandMarkInfo
        public let noseRight3: LandMarkInfo
        public let noseRight4: LandMarkInfo
        public let noseRight5: LandMarkInfo
        public let noseRight6: LandMarkInfo
        public let noseRight7: LandMarkInfo
        public let noseRight8: LandMarkInfo
        public let noseRight9: LandMarkInfo
        public let noseRight10: LandMarkInfo
        public let noseRight11: LandMarkInfo
        public let noseRight12: LandMarkInfo
        public let noseRight13: LandMarkInfo
        public let noseRight14: LandMarkInfo
        public let noseRight15: LandMarkInfo
        public let noseRight16: LandMarkInfo
        public let noseRight17: LandMarkInfo
        public let noseRight18: LandMarkInfo
        public let noseRight19: LandMarkInfo
        public let noseRight20: LandMarkInfo
        public let noseRight21: LandMarkInfo
        public let noseRight22: LandMarkInfo
        public let noseRight23: LandMarkInfo
        public let noseRight24: LandMarkInfo
        public let noseRight25: LandMarkInfo
        public let noseRight26: LandMarkInfo
        public let noseRight27: LandMarkInfo
        public let noseRight28: LandMarkInfo
        public let noseRight29: LandMarkInfo
        public let noseRight30: LandMarkInfo
        public let noseRight31: LandMarkInfo
        public let noseRight32: LandMarkInfo
        public let noseRight33: LandMarkInfo
        public let noseRight34: LandMarkInfo
        public let noseRight35: LandMarkInfo
        public let noseRight36: LandMarkInfo
        public let noseRight37: LandMarkInfo
        public let noseRight38: LandMarkInfo
        public let noseRight39: LandMarkInfo
        public let noseRight40: LandMarkInfo
        public let noseRight41: LandMarkInfo
        public let noseRight42: LandMarkInfo
        public let noseRight43: LandMarkInfo
        public let noseRight44: LandMarkInfo
        public let noseRight45: LandMarkInfo
        public let noseRight46: LandMarkInfo
        public let noseRight47: LandMarkInfo
        public let noseRight48: LandMarkInfo
        public let noseRight49: LandMarkInfo
        public let noseRight50: LandMarkInfo
        public let noseRight51: LandMarkInfo
        public let noseRight52: LandMarkInfo
        public let noseRight53: LandMarkInfo
        public let noseRight54: LandMarkInfo
        public let noseRight55: LandMarkInfo
        public let noseRight56: LandMarkInfo
        public let noseRight57: LandMarkInfo
        public let noseRight58: LandMarkInfo
        public let noseRight59: LandMarkInfo
        public let noseRight60: LandMarkInfo
        public let noseRight61: LandMarkInfo
        public let noseRight62: LandMarkInfo
        /// 左鼻孔位置（鼻孔上边缘中心）
        public let leftNostril: LandMarkInfo
        /// 右鼻孔位置（鼻孔上边缘中心）
        public let rightNostril: LandMarkInfo
        // MAKR: - 从眉心中间到人中，从上到下顺序检测到的鼻子中线关键点位置序列
        public let noseMidline0: LandMarkInfo
        public let noseMidline1: LandMarkInfo
        public let noseMidline2: LandMarkInfo
        public let noseMidline3: LandMarkInfo
        public let noseMidline4: LandMarkInfo
        public let noseMidline5: LandMarkInfo
        public let noseMidline6: LandMarkInfo
        public let noseMidline7: LandMarkInfo
        public let noseMidline8: LandMarkInfo
        public let noseMidline9: LandMarkInfo
        public let noseMidline10: LandMarkInfo
        public let noseMidline11: LandMarkInfo
        public let noseMidline12: LandMarkInfo
        public let noseMidline13: LandMarkInfo
        public let noseMidline14: LandMarkInfo
        public let noseMidline15: LandMarkInfo
        public let noseMidline16: LandMarkInfo
        public let noseMidline17: LandMarkInfo
        public let noseMidline18: LandMarkInfo
        public let noseMidline19: LandMarkInfo
        public let noseMidline20: LandMarkInfo
        public let noseMidline21: LandMarkInfo
        public let noseMidline22: LandMarkInfo
        public let noseMidline23: LandMarkInfo
        public let noseMidline24: LandMarkInfo
        public let noseMidline25: LandMarkInfo
        public let noseMidline26: LandMarkInfo
        public let noseMidline27: LandMarkInfo
        public let noseMidline28: LandMarkInfo
        public let noseMidline29: LandMarkInfo
        public let noseMidline30: LandMarkInfo
        public let noseMidline31: LandMarkInfo
        public let noseMidline32: LandMarkInfo
        public let noseMidline33: LandMarkInfo
        public let noseMidline34: LandMarkInfo
        public let noseMidline35: LandMarkInfo
        public let noseMidline36: LandMarkInfo
        public let noseMidline37: LandMarkInfo
        public let noseMidline38: LandMarkInfo
        public let noseMidline39: LandMarkInfo
        public let noseMidline40: LandMarkInfo
        public let noseMidline41: LandMarkInfo
        public let noseMidline42: LandMarkInfo
        public let noseMidline43: LandMarkInfo
        public let noseMidline44: LandMarkInfo
        public let noseMidline45: LandMarkInfo
        public let noseMidline46: LandMarkInfo
        public let noseMidline47: LandMarkInfo
        public let noseMidline48: LandMarkInfo
        public let noseMidline49: LandMarkInfo
        public let noseMidline50: LandMarkInfo
        public let noseMidline51: LandMarkInfo
        public let noseMidline52: LandMarkInfo
        public let noseMidline53: LandMarkInfo
        public let noseMidline54: LandMarkInfo
        public let noseMidline55: LandMarkInfo
        public let noseMidline56: LandMarkInfo
        public let noseMidline57: LandMarkInfo
        public let noseMidline58: LandMarkInfo
        public let noseMidline59: LandMarkInfo
    }
    /// 鼻子关键点集合
    public let nose: Nose?
    
    public struct Mouth {
        // MARK: - 上嘴唇的上边缘。从左边嘴角开始，从左到右检测到的上嘴唇上边缘关键点位置序列。
        public let upperLip0: LandMarkInfo
        public let upperLip1: LandMarkInfo
        public let upperLip2: LandMarkInfo
        public let upperLip3: LandMarkInfo
        public let upperLip4: LandMarkInfo
        public let upperLip5: LandMarkInfo
        public let upperLip6: LandMarkInfo
        public let upperLip7: LandMarkInfo
        public let upperLip8: LandMarkInfo
        public let upperLip9: LandMarkInfo
        public let upperLip10: LandMarkInfo
        public let upperLip11: LandMarkInfo
        public let upperLip12: LandMarkInfo
        public let upperLip13: LandMarkInfo
        public let upperLip14: LandMarkInfo
        public let upperLip15: LandMarkInfo
        public let upperLip16: LandMarkInfo
        public let upperLip17: LandMarkInfo
        public let upperLip18: LandMarkInfo
        public let upperLip19: LandMarkInfo
        public let upperLip20: LandMarkInfo
        public let upperLip21: LandMarkInfo
        public let upperLip22: LandMarkInfo
        public let upperLip23: LandMarkInfo
        public let upperLip24: LandMarkInfo
        public let upperLip25: LandMarkInfo
        public let upperLip26: LandMarkInfo
        public let upperLip27: LandMarkInfo
        public let upperLip28: LandMarkInfo
        public let upperLip29: LandMarkInfo
        public let upperLip30: LandMarkInfo
        public let upperLip31: LandMarkInfo
        // MARK: - 上嘴唇的下边缘。从右到左检测到的上嘴唇下边缘关键点位置序列。
        public let upperLip32: LandMarkInfo
        public let upperLip33: LandMarkInfo
        public let upperLip34: LandMarkInfo
        public let upperLip35: LandMarkInfo
        public let upperLip36: LandMarkInfo
        public let upperLip37: LandMarkInfo
        public let upperLip38: LandMarkInfo
        public let upperLip39: LandMarkInfo
        public let upperLip40: LandMarkInfo
        public let upperLip41: LandMarkInfo
        public let upperLip42: LandMarkInfo
        public let upperLip43: LandMarkInfo
        public let upperLip44: LandMarkInfo
        public let upperLip45: LandMarkInfo
        public let upperLip46: LandMarkInfo
        public let upperLip47: LandMarkInfo
        public let upperLip48: LandMarkInfo
        public let upperLip49: LandMarkInfo
        public let upperLip50: LandMarkInfo
        public let upperLip51: LandMarkInfo
        public let upperLip52: LandMarkInfo
        public let upperLip53: LandMarkInfo
        public let upperLip54: LandMarkInfo
        public let upperLip55: LandMarkInfo
        public let upperLip56: LandMarkInfo
        public let upperLip57: LandMarkInfo
        public let upperLip58: LandMarkInfo
        public let upperLip59: LandMarkInfo
        public let upperLip60: LandMarkInfo
        public let upperLip61: LandMarkInfo
        public let upperLip62: LandMarkInfo
        public let upperLip63: LandMarkInfo
        // MARK: - 下嘴唇的下边缘。从左边嘴角开始，从左到右检测到的下嘴唇下边缘关键点位置序列。
        public let lowerLip0: LandMarkInfo
        public let lowerLip1: LandMarkInfo
        public let lowerLip2: LandMarkInfo
        public let lowerLip3: LandMarkInfo
        public let lowerLip4: LandMarkInfo
        public let lowerLip5: LandMarkInfo
        public let lowerLip6: LandMarkInfo
        public let lowerLip7: LandMarkInfo
        public let lowerLip8: LandMarkInfo
        public let lowerLip9: LandMarkInfo
        public let lowerLip10: LandMarkInfo
        public let lowerLip11: LandMarkInfo
        public let lowerLip12: LandMarkInfo
        public let lowerLip13: LandMarkInfo
        public let lowerLip14: LandMarkInfo
        public let lowerLip15: LandMarkInfo
        public let lowerLip16: LandMarkInfo
        public let lowerLip17: LandMarkInfo
        public let lowerLip18: LandMarkInfo
        public let lowerLip19: LandMarkInfo
        public let lowerLip20: LandMarkInfo
        public let lowerLip21: LandMarkInfo
        public let lowerLip22: LandMarkInfo
        public let lowerLip23: LandMarkInfo
        public let lowerLip24: LandMarkInfo
        public let lowerLip25: LandMarkInfo
        public let lowerLip26: LandMarkInfo
        public let lowerLip27: LandMarkInfo
        public let lowerLip28: LandMarkInfo
        public let lowerLip29: LandMarkInfo
        public let lowerLip30: LandMarkInfo
        public let lowerLip31: LandMarkInfo
        // MARK: - 下嘴唇的上边缘。从右到左检测到的下嘴唇上边缘关键点位置序列。
        public let lowerLip32: LandMarkInfo
        public let lowerLip33: LandMarkInfo
        public let lowerLip34: LandMarkInfo
        public let lowerLip35: LandMarkInfo
        public let lowerLip36: LandMarkInfo
        public let lowerLip37: LandMarkInfo
        public let lowerLip38: LandMarkInfo
        public let lowerLip39: LandMarkInfo
        public let lowerLip40: LandMarkInfo
        public let lowerLip41: LandMarkInfo
        public let lowerLip42: LandMarkInfo
        public let lowerLip43: LandMarkInfo
        public let lowerLip44: LandMarkInfo
        public let lowerLip45: LandMarkInfo
        public let lowerLip46: LandMarkInfo
        public let lowerLip47: LandMarkInfo
        public let lowerLip48: LandMarkInfo
        public let lowerLip49: LandMarkInfo
        public let lowerLip50: LandMarkInfo
        public let lowerLip51: LandMarkInfo
        public let lowerLip52: LandMarkInfo
        public let lowerLip53: LandMarkInfo
        public let lowerLip54: LandMarkInfo
        public let lowerLip55: LandMarkInfo
        public let lowerLip56: LandMarkInfo
        public let lowerLip57: LandMarkInfo
        public let lowerLip58: LandMarkInfo
        public let lowerLip59: LandMarkInfo
        public let lowerLip60: LandMarkInfo
        public let lowerLip61: LandMarkInfo
        public let lowerLip62: LandMarkInfo
        public let lowerLip63: LandMarkInfo
    }
}