//
//  Beautify.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/7.
// - Wiki: https://console.faceplusplus.com.cn/documents/34878217
//

import Foundation

@objc(FppBeautifyV1Option)
public class BeautifyV1Option: FaceppBaseRequest {
    /**
     
     美白程度，取值范围[0,100]
     
     0不美白，100代表最高程度
     
     本参数默认值为 V1默认值为100，V2为50
     */
    @objc public var whitening: UInt
    /**
     磨皮程度，取值范围 [0,100]
     
     0不磨皮，100代表最高程度
     
     本参数默认值为 V1默认值为100，V2为50
     */
    @objc public var smoothing: UInt

    @objc public override init() {
        whitening = 100
        smoothing = 100
        super.init()
    }

    @objc required public init(params: [String: Any]) {
        if let value = params["whitening"] as? UInt {
            whitening = value
        } else {
            whitening = 100
        }
        if let value = params["smoothing"] as? UInt {
            smoothing = value
        } else {
            smoothing = 100
        }
        super.init(params: params)
    }

    override var requsetURL: URL? {
        return kFaceappV1URL?.appendingPathComponent("beautify")
    }

    override func paramsCheck() throws -> Bool {
        guard needCheckParams else {
            return true
        }
        guard whitening <= 100 else {
            throw FaceppRequestError.argumentsError(.invalidArguments(desc: "whitening输入需要在[0, 100]: \(whitening)"))
        }
        guard smoothing <= 100 else {
            throw FaceppRequestError.argumentsError(.invalidArguments(desc: "smoothing输入需要在[0, 100]: \(smoothing)"))
        }
        return try super.paramsCheck()
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, files) = try super.params()
        params["whitening"] = whitening
        params["smoothing"] = smoothing
        return (params, files)
    }
}

@objc(FppBeautifyV2Option)
public class BeautifyV2Option: BeautifyV1Option {
    /**
     瘦脸程度，取值范围 [0,100]
     
     0无瘦脸效果，100代表最高程度
     
     本参数默认值为50
     */
    @objc public var thinface: UInt = 50
    /**
     小脸程度，取值范围 [0,100]
     
     0无小脸效果，100代表最高程度
     
     本参数默认值为50
     */
    @objc public var shrinkFace: UInt = 50
    /**
     大眼程度，取值范围 [0,100]
     
     0无大眼效果，100代表最高程度
     
     本参数默认值为50
     */
    @objc public var enlargeEye: UInt = 50
    /**
     去眉毛程度，取值范围 [0,100]
     
     0无去眉毛效果，100代表最高程度
     
     本参数默认值为50
     */
    @objc public var removeEyebrow: UInt = 50

    public enum FilterType: String {
        /// 黑白
        case blackWhite = "black_white"
        /// 平静
        case calm
        /// 晴天
        case sunny
        ///  桃花
        case blossom
        /// 粉黛
        case pink
        /// 江南
        case jiangNan = "jiang_nan"
        /// 布拉格
        case prague
        /// 香奈儿
        case chanel
        /// 薰衣草
        case lavender
        /// 绚烂
        case glitter
        /// 暖暖
        case warm
        /// 补光灯
        case wlight
        /// 阿宝色
        case abao
        /// 故事
        case story
        /// 早春
        case spring
        /// 旧时光
        case oldTimes
        /// LOMO
        case lomo
        /// 时光
        case times
        /// 巴黎
        case paris
        /// 冰美人
        case iceLady = "ice_lady"
        /// 回忆
        case memory
        /// 花香
        case flowers
        /// 卓别林
        case chaplin
        /// 亮肤
        case whiten
        /// 下午茶
        case teaTime
        /// 柔光灯
        case clight
        /// 十七岁
        case seventeen = "17_years_old"
        /// 樱花
        case sakura
        /// 纽约
        case newYork = "new_york"
        /// 可人儿
        case macaron
        /// 唯美
        case cutie
        /// 王家卫
        case wangjiawei
        /// 美肤
        case beautify
        /// 旅程
        case trip
    }
    /**
     滤镜名称，滤镜名称列表见下方
     
     默认无滤镜效果
     */
    @nonobjc public var filterType: FilterType?

    @objc public var filterString: String? {
        set {
            if let value = newValue {
                filterType = FilterType(rawValue: value)
            }
        }
        get {
            filterType?.rawValue
        }
    }

    override var requsetURL: URL? {
        return kFaceappV2URL?.appendingPathComponent("beautify")
    }

    @objc public override init() {
        super.init()
        whitening = 50
        smoothing = 50
    }

    @objc required public init(params: [String: Any]) {
        var params = params
        if let value = params["thin_face"] as? UInt {
            thinface = value
        } else {
            thinface = 50
        }
        if let value = params["shrink_face"] as? UInt {
            shrinkFace = value
        } else {
            shrinkFace = 50
        }
        if let value = params["enlarge_eye"] as? UInt {
            enlargeEye = value
        } else {
            enlargeEye = 50
        }
        if let value = params["remove_eyebrow"] as? UInt {
            removeEyebrow = value
        } else {
            removeEyebrow = 50
        }
        if let value = params["filter_type"] as? String {
            filterType = FilterType(rawValue: value)
        }
        if params["whitening"] == nil {
            params["whitening"] = 50
        }
        if params["smoothing"] == nil {
            params["smoothing"] = 50
        }
        super.init(params: params)
    }

    override func paramsCheck() throws -> Bool {
        guard needCheckParams else {
            return true
        }
        guard thinface <= 100 else {
            throw FaceppRequestError.argumentsError(.invalidArguments(desc: "thinface输入需要在[0, 100]: \(thinface)"))
        }
        guard shrinkFace <= 100 else {
            throw FaceppRequestError.argumentsError(.invalidArguments(desc: "shrinkFace输入需要在[0, 100]: \(shrinkFace)"))
        }
        guard enlargeEye <= 100 else {
            throw FaceppRequestError.argumentsError(.invalidArguments(desc: "enlargeEye输入需要在[0, 100]: \(enlargeEye)"))
        }
        guard removeEyebrow <= 100 else {
            throw FaceppRequestError.argumentsError(.invalidArguments(desc: "removeEyebrow输入需要在[0, 100]: \(removeEyebrow)"))
        }
        return try super.paramsCheck()
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, files) = try super.params()
        params["thinface"] = thinface
        params["shrink_face"] = shrinkFace
        params["enlarge_eye"] = enlargeEye
        params["remove_eyebrow"] = removeEyebrow
        params["filter_type"] = filterType?.rawValue
        return (params, files)
    }
}

@objc(FppBeautifyResponse)
@objcMembers public final class BeautifyResponse: NSObject, FaceppResponseProtocol {
    public var requestId: String?
    /// 当发生错误时才返回。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 美化后的图片，jpg格式。base64 编码的二进制图片数据。图片尺寸大小与底图一致。
    public let result: String?
}
