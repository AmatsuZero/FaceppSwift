//
//  DriverLicense.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/10.
// Wiki: https://console.faceplusplus.com.cn/documents/26872594
//

import Foundation

@objc(FppDriverLicenseV1Option)
public class OCRDriverLicenseV1Option: CardppV1Requst {
    override var requsetURL: URL? {
        return super.requsetURL?.appendingPathComponent("ocrdriverlicense")
    }
}

extension OCRDriverLicenseV1Option: FppDataRequestProtocol {
    @objc public func request(completionHandler: @escaping (Error?, OCRDriverLicenseV1Response?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

/**
  检测和识别中华人民共和国机动车驾驶证（以下称“驾照”）图像，并转化为结构化的文字信息。
 只可识别驾照正本(main sheet)正面和副本(second sheet)正面，一张照片最多可识别一个正本正面和一个副本正面。
 */
@objc(FppDriverLicenseV2Option)
@objcMembers public class OCRDriverLicenseV2Option: CardppV1Requst {
    /**
     
     当传入照片输出OCR结果时，是否同时返回置信度
     
     默认不返回置信度。
     
     当经由api_key判断用户为已付费的正式用户，且此参数设定为true时，分别对每部分OCR识别结果同时输出置信度，并同时输出正本/副本的置信度。
     */
    public var needReturnScore = false

    public enum Mode: String {
        /// 快速识别模式
        case fast
        /// 完备识别模式
        case complete
    }
    /**
     
     使用该API的快速识别模式还是完备识别模式，可选参数为fast和complete
     
     默认此参数是complete，即完备识别模式。
     
     快速识别模式只可识别驾照正本(main sheet)正面；完备识别模式支持识别驾照正本和副本。
     */
    public var mode = Mode.fast

    public var modeString: String {
        set {
            mode = Mode(rawValue: newValue) ?? .fast
        }
        get {
            mode.rawValue
        }
    }

    override var requsetURL: URL? {
        return kCardppV2URL?.appendingPathComponent("ocrdriverlicense")
    }

    public required init(params: [String: Any]) {
        if let value = params["return_score"] as? Int {
            needReturnScore = value == 1
        } else {
            needReturnScore = false
        }
        if let value = params["mode"] as? String {
            mode = Mode(rawValue: value) ?? .fast
        } else {
            mode = .fast
        }
        super.init(params: params)
    }

    public override init() {
        mode = .fast
        needReturnScore = false
        super.init()
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, files) = try super.params()
        params["return_score"] = needReturnScore ? 1 : 0
        params["mode"] = mode.rawValue
        return (params, files)
    }
}

@objc(FppDriverLicenseStringModel)
public final class DriverLicenseStringModel: NSObject, Codable {
    public let content: String
    public let confidence: Float?
}

@objc(FppDriverLicenseMain)
@objcMembers public final class OCRDriverLicenseMain: NSObject, Codable {
    /// 返回驾驶证正本置信度，值为一个 [0,100] 的浮点数，小数点后 3 位有效数字，仅正式用户设置return_score值为1时返回。
    public let confidence: Float?

    @objc(FppDriverLicenseMainVersion)
    @objcMembers public class Version: NSObject, Codable {
        /// 表示驾驶证正本版本，int型，返回 2，表示是2013版本驾驶证；返回 1，表示是2008或更早版本驾驶证
        public let content: OCRDriverLicenseV1Response.Version
        /// 表示置信度，值为一个 [0,100] 的浮点数，小数点后 3 位有效数字，仅正式用户设置return_score值为1时返回。
        public let confidence: Float?
    }
    /// 驾驶证正本版本及其置信度
    public let version: Version

    /**
     住址及其置信度，返回字段分为以下两部分：
     
     content：表示住址，string型
     confidence：表示置信度，值为一个 [0,100] 的浮点数，小数点后 3 位有效数字，仅正式用户设置return_score值为1时返回。
     */
    public let address: DriverLicenseStringModel

    @objc(FppDriverLicenseMainDateModel)
    @objcMembers public final class DateModel: NSObject, Codable {
        public let content: Date?
        /// 表示置信度，值为一个 [0,100] 的浮点数，小数点后 3 位有效数字，仅正式用户设置return_score值为1时返回
        public let confidence: Float?

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let date = try container.decode(String.self, forKey: .content)
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-DD"
            content = formatter.date(from: date)
            confidence = container.contains(.confidence)
                ? try container.decode(Float.self, forKey: .confidence)
                : nil
        }
    }
    /// 生日及其置信度
    public let birthday: DateModel

    @objc(FppDriverLicenseMainGender)
    @objcMembers public final class Gender: NSObject, Codable {
        /// 表示性别
        public let content: OCRDriverLicenseV1Response.Gender
        public let confidence: Float?
    }
    /// 性别及其置信度
    public let gender: Gender
    /**
     返回字段分为以下两部分：
     
     content：驾驶证号，string型
     confidence：表示置信度，值为一个 [0,100] 的浮点数，小数点后 3 位有效数字，仅正式用户设置return_score值为1时返回。
     */
    public let licenseNumber: DriverLicenseStringModel
    /**
     姓名及其置信度，返回字段分为以下两部分：
     
     content：姓名，string型
     confidence：表示置信度，值为一个 [0,100] 的浮点数，小数点后 3 位有效数字，仅正式用户设置return_score值为1时返回。
     */
    public let name: DriverLicenseStringModel

    @objc(FppDriverLicenseClass)
    @objcMembers public final class DriverLicenseClass: NSObject, Codable {
        public let content: OCRDriverLicenseV1Response.Class
        public let confidence: Float?
    }
    /**
     准驾车型及其置信度，返回字段分为以下两部分：
     
     content：准驾车型，string型
     confidence：表示置信度，值为一个 [0,100] 的浮点数，小数点后 3 位有效数字，仅正式用户设置return_score值为1时返回。
     */
    @nonobjc public let `class`: DriverLicenseClass

    public var classModel: DriverLicenseClass {
        return self.class
    }
    /**
     国籍及置信度，返回字段分为以下两部分：
     
     content：国籍，，string型
     confidence：表示置信度，值为一个 [0,100] 的浮点数，小数点后 3 位有效数字，仅正式用户设置return_score值为1时返回。
     */
    public let nationality: DriverLicenseStringModel
    /**
     签发机关及置信度，返回字段分为以下两部分：
     
     content：签发机关，string型
     confidence：表示置信度，值为一个 [0,100] 的浮点数，小数点后 3 位有效数字，仅正式用户设置return_score值为1时返回。
     */
    public let issuedBy: DriverLicenseStringModel
    /**
     初次领证日期及置信度，返回字段分为以下两部分：
     
     content：初次领证日期，string型，格式为YYYY-MM-DD
     confidence：表示置信度，值为一个 [0,100] 的浮点数，小数点后 3 位有效数字，仅正式用户设置return_score值为1时返回。
     */
    public let issueDate: DateModel
    /**
     有效日期及置信度，返回字段分为以下两部分：
     
     content：有效日期，，string型，格式为YYYY-MM-DD
     confidence：表示置信度，值为一个 [0,100] 的浮点数，小数点后 3 位有效数字，仅正式用户设置return_score值为1时返回。
     */
    public let validFrom: DateModel?
    /**
     有效年限及置信度，返回字段分为以下两部分：
     
     content：有效年限，string型，例如 6年
     confidence：表示置信度，值为一个 [0,100] 的浮点数，小数点后 3 位有效数字，仅正式用户设置return_score值为1时返回。
     */
    public let validFor: DateModel?

    @objc(FppDriverLicenseMainValidDate)
    @objcMembers public final class ValidDate: NSObject, Codable {
        public let content: [Date?]
        public let confidence: Float?

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let date = try container.decode(String.self, forKey: .content)
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-DD"
            content = date.components(separatedBy: "-")
                .map { formatter.date(from: $0) }
            confidence = container.contains(.confidence)
                ? try container.decode(Float.self, forKey: .confidence)
                : nil
        }
    }
    /**
     有效期限及置信度，返回字段分为以下两部分：
     
     content：有效期限格式为：YYYY-MM-DD至YYYY-MM-DD，string型，
     根据驾驶证版本不同，可能会返回valid_from和valid_for两个字段，另一种情况只返回valid_date字段。
     confidence：值为一个 [0,100] 的浮点数，小数点后 3 位有效数字，仅正式用户设置return_score值为1时返回。
     */
    public let validDate: ValidDate?
}

@objc(FppDriverLicenseSecond)
@objcMembers public final class OCRDriverLicenseSecond: NSObject, Codable {
    /// 返回驾驶证正本置信度，值为一个 [0,100] 的浮点数，小数点后 3 位有效数字，仅正式用户设置return_score值为1时返回。
    public let confidence: Float?
    /**
     驾驶证号及置信度，返回字段分为以下两部分：
     
     content：驾驶证号，string型
     confidence：表示置信度，值为一个 [0,100] 的浮点数，小数点后 3 位有效数字，仅正式用户设置return_score值为1时返回。
     */
    public let licenseNumber: DriverLicenseStringModel
    /**
     档案编号及置信度，返回字段分为以下两部分：
     
     content：档案编号，string型
     confidence：表示置信度，值为一个 [0,100] 的浮点数，小数点后 3 位有效数字，仅正式用户设置return_score值为1时返回。
     */
    public let fileNumber: DriverLicenseStringModel
}

extension OCRDriverLicenseV2Option: FppDataRequestProtocol {
    @objc public func request(completionHandler: @escaping (Error?, OCRDriverLicenseV2Response?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

@objc(FppDriverLicenseV2Response)
@objcMembers public final class OCRDriverLicenseV2Response: NSObject, FaceppResponseProtocol {
    public var requestId: String?
    public var errorMessage: String?
    public var timeUsed: Int?
    /**
     检测出驾驶证正本的数组
     
     注：如果没有检测出正本则为空数组
     */
    public let main: [OCRDriverLicenseMain]?
    /**
     检测出驾驶证副页的数组
     
     注：如果没有检测出副本则为空数组
     */
    public let second: [OCRDriverLicenseSecond]?
}
/**
 检测和识别中华人民共和国机动车驾驶证（以下称“驾照”）图像为结构化的文字信息。目前只支持驾照主页正面，不支持副页正面反面。
 
 驾照图像须为正拍（垂直角度拍摄），但是允许有一定程度的旋转角度；
 仅支持图像里有一个驾照的主页正面，如果同时出现多页、或正副页同时出现，可能会返回空结果。
 
 Wiki: https://console.faceplusplus.com.cn/documents/5671704
 */
@objc(FppDriverLicenseV1Response)
@objcMembers public final class OCRDriverLicenseV1Response: NSObject, FaceppResponseProtocol {
    public var requestId: String?
    public var errorMessage: String?
    public var timeUsed: Int?

    @objc(FppDriverLicenseVersion)
    public enum Version: Int, Codable {
        /// 2008或更早版本驾驶证
        case old = 1
        /// 2013版本驾驶证
        case new = 2
    }

    public enum Gender: String, Codable {
        case male = "男"
        case female = "女"
    }

    public enum Class: String, Codable {
        case A1, A2, A3, B1, B2, C1, C2, C3, C4, C5, D, E, F, M, N, P
    }

    public enum Side: String, Codable {
        case front, back
    }

    @objc(FppDriverLicenseCard)
    @objcMembers public final class Card: NSObject, Codable {
        /// 证件类型。
        public let type: OCRType

        /// 驾驶证版本
        public let version: Version
        /// 住址
        public let address: String
        /// 生日，格式为YYYY-MM-DD
        public let birthday: Date?
        /// 性别（男/女）
        public let gender: Gender
         /// 性别（男/女）
        public var genderString: String {
            return gender.rawValue
        }
        /// 驾驶证号
        public let licenseNumber: String
        /// 姓名
        public let name: String
        /// 准驾车型
        public let `class`: Class?
         /// 准驾车型
        public var classString: String? {
            return self.class?.rawValue
        }
        /// 表示驾驶证的正面或者反面。该字段目前只会返回“front”，表示是正面
        public let side: Side
        /// 国籍
        public let nationality: String
        /// 签发机关
        public let issuedBy: String
        /// 初次领证日期，格式为YYYY-MM-DD
        public let issueDate: Date?
        /// 有效日期，格式为YYYY-MM-DD
        public let validFrom: Date?
        /// 有效年限，例如 6年
        public let validFor: Date?
        /**
         有效期限格式为：YYYY-MM-DD至YYYY-MM-DD
         
         根据驾驶证版本不同，一种情况会返回valid_from和valid_for两个字段，另一种情况只返回valid_date字段
         */
        public let validDate: [Date?]?

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(OCRType.self, forKey: .type)
            version = try container.decode(Version.self, forKey: .version)
            address = try container.decode(String.self, forKey: .address)
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-DD"
            if container.contains(.birthday) {
                let b = try container.decode(String.self, forKey: .birthday)
                birthday = formatter.date(from: b)
            } else {
                birthday = nil
            }
            gender = try container.decode(Gender.self, forKey: .gender)
            licenseNumber = try container.decode(String.self, forKey: .licenseNumber)
            name = try container.decode(String.self, forKey: .name)
            self.class = try container.decode(Class.self, forKey: .class)
            side = try container.decode(Side.self, forKey: .side)
            nationality = try container.decode(String.self, forKey: .nationality)
            issuedBy = try container.decode(String.self, forKey: .issuedBy)
            if container.contains(.issueDate) {
                let i = try container.decode(String.self, forKey: .issueDate)
                issueDate = formatter.date(from: i)
            } else {
                issueDate = nil
            }
            if container.contains(.validFrom) {
                let v = try container.decode(String.self, forKey: .validFrom)
                validFrom = formatter.date(from: v)
            } else {
                validFrom = nil
            }
            if container.contains(.validFor) {
                let v = try container.decode(String.self, forKey: .validFor)
                validFor = formatter.date(from: v)
            } else {
                validFor = nil
            }
            if container.contains(.validDate) {
                let date = try container.decode(String.self, forKey: .validDate)
                validDate = date.components(separatedBy: "-").map { formatter.date(from: $0) }
            } else {
                validDate = nil
            }
        }
    }
    /**
     检测出证件的数组
     
     注：如果没有检测出证件则为空数组
     */
    public let cards: [Card]?
}
