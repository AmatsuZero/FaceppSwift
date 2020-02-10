//
//  VehicleLicense.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/10.
//

import Foundation

public struct OCRVehicleLicenseOption: RequestProtocol {
    /// 图片的URL
    public var imageURL: URL?
    /**
     一个图片，二进制文件，需要用post multipart/form-data的方式上传。图像存储尺寸不能超过2MB，像素尺寸的长或宽都不能超过4096像素。
     
     如果同时传入了image_url和image_file参数，本API将使用image_file参数。
     */
    public var imageFile: URL?
    /**
     base64编码的二进制图片数据
     
     如果同时传入了image_url、image_file和image_base64参数，本API使用顺序为image_file优先，image_url最低。
     */
    public var imageBase64: String?
    
    var requsetURL: URL? {
        return kCardppV1URL?.appendingPathComponent("ocrvehiclelicense")
    }
    
    func paramsCheck() -> Bool {
        return imageURL != nil || imageFile != nil || imageBase64 != nil
    }
    
    func params(apiKey: String, apiSecret: String) -> (Params, [Params]?) {
        var params: Params = [
            "api_key": apiKey,
            "api_secret": apiSecret,
        ]
        var files = [Params]()
        params["image_url"] = imageURL
        params["image_base64"] = imageBase64
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
