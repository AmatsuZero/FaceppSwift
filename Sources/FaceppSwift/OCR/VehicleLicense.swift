//
//  VehicleLicense.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/10.
//

import Foundation

public class OCRVehicleLicenseOption: CardppV1Requst {
    public override var requsetURL: URL? {
        return super.requsetURL?.appendingPathComponent("ocrvehiclelicense")
    }
}

public struct OCRVehicleLicenseResponse: ResponseProtocol {
    public var requestId: String?
    public var errorMessage: String?
    public var timeUsed: Int?
    
    public struct Card: Codable {
        /// 证件版本。
        public let type: OCRType
        /// 号牌号码
        public let plateNo: String?
        /// 车辆类型
        public let vehicleType: String?
        /// 所有人
        public let owner: String?
        /// 住址
        public let address: String?
        /// 使用性质
        public let useCharacter: String?
        /// 品牌型号
        public let model: String?
        /// 车辆识别代号。
        public let vin: String?
        /// 发动机号码
        public let engineNo: String?
        /// 注册日期
        public let registerDate: Date?
        /// 发证日期
        public let issueDate: Date?
        /// 签发机关。
        public let issuedBy: String?
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(OCRType.self, forKey: .type)
            address = try container.decode(String.self, forKey: .address)
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-DD"
            issuedBy = try container.decode(String.self, forKey: .issuedBy)
            if container.contains(.issueDate) {
                let i = try container.decode(String.self, forKey: .issueDate)
                issueDate = formatter.date(from: i)
            } else {
                issueDate = nil
            }
            plateNo = container.contains(.plateNo) ? try container.decode(String.self, forKey: .plateNo) : nil
            vehicleType = container.contains(.vehicleType) ? try container.decode(String.self, forKey: .vehicleType) : nil
            owner = container.contains(.owner) ? try container.decode(String.self, forKey: .owner) : nil
            useCharacter = container.contains(.useCharacter) ? try container.decode(String.self, forKey: .useCharacter) : nil
            model = container.contains(.model) ? try container.decode(String.self, forKey: .model) : nil
            vin = container.contains(.vin) ? try container.decode(String.self, forKey: .vin) : nil
            engineNo = container.contains(.engineNo) ? try container.decode(String.self, forKey: .engineNo) : nil
            if container.contains(.registerDate) {
                let r = try container.decode(String.self, forKey: .registerDate)
                registerDate = formatter.date(from: r)
            } else {
                registerDate = nil
            }
        }
    }
    /// 检测出证件的数组
    public let cards: [Card]?
}
