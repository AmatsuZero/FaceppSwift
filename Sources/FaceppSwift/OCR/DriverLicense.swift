//
//  DriverLicense.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/10.
// Wiki: https://console.faceplusplus.com.cn/documents/26872594
//

import Foundation
/// 检测和识别中华人民共和国机动车驾驶证（以下称“驾照”）图像，并转化为结构化的文字信息。只可识别驾照正本(main sheet)正面和副本(second sheet)正面，一张照片最多可识别一个正本正面和一个副本正面。
public struct OCRDriverLicenseOption: RequestProtocol {
    /// 图片的URL
    public var imageURL: URL?
    /**
     一个图片，二进制文件，需要用post multipart/form-data的方式上传。图像存储尺寸不能超过2MB，像素尺寸的长或宽都不能超过4096像素。
     
     如果同时传入了image_url和image_file参数，本API将使用image_file参数。
     */
    public var imageFile: URL?
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
    
    var requsetURL: URL? {
        return kCardppV2URL?.appendingPathComponent("ocrdriverlicense")
    }
    
    func paramsCheck() -> Bool {
        return imageURL != nil || imageFile != nil
    }
    
    func params(apiKey: String, apiSecret: String) -> (Params, [Params]?) {
        var params: Params = [
            "api_key": apiKey,
            "api_secret": apiSecret,
            "return_score": needReturnScore ? 1 : 0,
            "mode": mode.rawValue
        ]
        var files = [Params]()
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

public struct DriverLicenseStringModel: Codable {
    public let content: String
    public let confidence: Float?
}

public struct OCRDriverLicenseMain: Codable {
    /// 返回驾驶证正本置信度，值为一个 [0,100] 的浮点数，小数点后 3 位有效数字，仅正式用户设置return_score值为1时返回。
    public let confidence: Float?
    
    public struct Version: Codable {
        public enum Content: Int, Codable {
            /// 2008或更早版本驾驶证
            case old = 1
            /// 2013版本驾驶证
            case new = 2
        }
        /// 表示驾驶证正本版本，int型，返回 2，表示是2013版本驾驶证；返回 1，表示是2008或更早版本驾驶证
        public let content: Content
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
    
    public struct DateModel: Codable {
        public let content: Date?
        /// 表示置信度，值为一个 [0,100] 的浮点数，小数点后 3 位有效数字，仅正式用户设置return_score值为1时返回
        public let confidence: Float?
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let date = try container.decode(String.self, forKey: .content)
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-DD"
            content = formatter.date(from: date)
            confidence = container.contains(.confidence) ? try container.decode(Float.self, forKey: .confidence) : nil
        }
    }
    /// 生日及其置信度
    public let birthday: DateModel
    
    public struct Gender: Codable {
        public enum Content: String, Codable {
            case male = "男"
            case female = "女"
        }
        /// 表示性别
        public let content: Content
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
    
    public struct DriverLicenseClass: Codable {
        public enum Class: String, Codable {
            case A1, A2, A3, B1, B2, C1, C2, C3, C4, C5, D, E, F, M, N, P
        }
        public let content: Class
        public let confidence: Float?
    }
    /**
     准驾车型及其置信度，返回字段分为以下两部分：
     
     content：准驾车型，string型
     confidence：表示置信度，值为一个 [0,100] 的浮点数，小数点后 3 位有效数字，仅正式用户设置return_score值为1时返回。
     */
    public let `class`: DriverLicenseStringModel
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
    
    public struct ValidDate: Codable {
        public let content: [Date?]
        public let confidence: Float?
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let date = try container.decode(String.self, forKey: .content)
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-DD"
            content = date.components(separatedBy: "-")
                .map { formatter.date(from: $0) }
            confidence = container.contains(.confidence) ? try container.decode(Float.self, forKey: .confidence) : nil
        }
    }
    /**
     有效期限及置信度，返回字段分为以下两部分：
     
     content：有效期限格式为：YYYY-MM-DD至YYYY-MM-DD，string型，根据驾驶证版本不同，可能会返回valid_from和valid_for两个字段，另一种情况只返回valid_date字段。
     confidence：值为一个 [0,100] 的浮点数，小数点后 3 位有效数字，仅正式用户设置return_score值为1时返回。
     */
    public let validDate: ValidDate?
}

public struct OCRDriverLicenseSecond: Codable {
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

public struct OCRDriverLicenseResponse: ResponseProtocol {
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
