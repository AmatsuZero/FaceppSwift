//
//  OCR.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/9.
//

import Foundation
// MARK: - 检测和识别中华人民共和国第二代身份证的关键字段内容，并支持返回身份证正反面信息、身份证照片分类判断结果。
/**
 检测和识别中华人民共和国第二代身份证的关键字段内容，并支持返回身份证正反面信息、身份证照片分类判断结果。
 
 Wiki: https://console.faceplusplus.com.cn/documents/5671702
 */
public class OCRIDCardOption: CardppV1Requst {
    /**
     是否返回身份证照片合法性检查结果
     注意：2017年6月7日之后，只有正式 API Key 能够调用此参数返回分类结果，免费 API Key 调用后无法返回分类结果。
     */
    public var needLegality = false

    override var requsetURL: URL? {
        return super.requsetURL?.appendingPathComponent("ocridcard")
    }

    override func params() throws -> (Params, [Params]?) {
        var (params, files) = try super.params()
        params["legality"] = needLegality ? 1 : 0
        return (params, files)
    }
}

public struct OCRIDCard: Codable {
    /// 证件类型。
    public let type: OCRType
    /// 住址
    public let address: String?
    /// 生日
    public let birthday: Date?

    public enum Gender: String, Codable {
        case male = "男"
        case female = "女"
    }
    /// 性别
    public let gender: Gender?
    /// 身份证号
    public let idCardNumber: String?
    /// 姓名
    public let name: String?
    /// 民族
    public let race: String?

    public enum Side: String, Codable {
        /// 人像面
        case front
        /// 国徽面
        case back
    }
    /// 表示身份证的国徽面或人像面
    public let side: Side
    /// 签发机关
    public let issuedBy: String?
    /**
     有效日期，返回值有两种格式：
     */
    public let validDate: [Date?]?

    public struct Legality: Codable {
        /// 正式身份证照片
        public let idPhoto: Float
        /// 临时身份证照片
        public let temporaryIDPhoto: Float
        /// 正式身份证的复印件
        public let photoCopy: Float
        /// 手机或电脑屏幕翻拍的照片
        public let screen: Float
        /// 用工具合成或者编辑过的身份证图片
        public let edited: Float
    }
    /**
     身份证照片的合法性检查结果。返回结果为身份证五种分类的概率值（取［0，1］区间实数，小数点后3位有效数字，概率值总和等于1.0）。五种分类为：
     注意：此项功能只有正式 API Key 能够调用。如果使用免费 API Key 请求此参数，则返回的五个概率的数值都为0。
     */
    public let legality: Legality

    private enum CodingKeys: String, CodingKey {
        case type, address, birthday, gender, name, race, side, legality, idCardNumber
        case issuedBy
        case validDate
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(OCRType.self, forKey: .type)
        address = container.contains(.address) ? try container.decode(String.self, forKey: .address) : nil
        let formatter = DateFormatter()
        if container.contains(.birthday) {
            let date = try container.decode(String.self, forKey: .birthday)
            formatter.dateFormat = "YYYY-MM-DD"
            birthday = formatter.date(from: date)
        } else {
            birthday = nil
        }
        gender = container.contains(.gender) ? try container.decode(Gender.self, forKey: .gender) : nil
        name = container.contains(.name) ? try container.decode(String.self, forKey: .name) : nil
        race = container.contains(.race) ? try container.decode(String.self, forKey: .race) : nil
        side = try container.decode(Side.self, forKey: .side)
        legality = try container.decode(Legality.self, forKey: .legality)
        idCardNumber = container.contains(.idCardNumber) ? try container.decode(String.self, forKey: .idCardNumber) : nil
        issuedBy = container.contains(.issuedBy) ? try container.decode(String.self, forKey: .issuedBy) : nil
        if container.contains(.validDate) {
            formatter.dateFormat = "YYYY.MM.DD"
            let validDates = try container.decode(String.self, forKey: .validDate)
                .components(separatedBy: "-")
                .map { $0 == "长期" ? Date.distantFuture : formatter.date(from: $0) }
            validDate = [validDates.first ?? Date.distantPast, validDates.last ?? Date.distantFuture]
        } else {
            validDate = nil
        }
    }
}

extension OCRIDCard.Legality {
    private enum CodingKeys: String, CodingKey {
        case idPhoto = "ID Photo"
        case temporaryIDPhoto = "Temporary ID Photo"
        case photoCopy = "Photocopy"
        case screen = "Screen"
        case edited = "Edited"
    }
}

public struct OCRIDCardResponse: ResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 检测出证件的数组
    public let cards: [OCRIDCard]?
}
