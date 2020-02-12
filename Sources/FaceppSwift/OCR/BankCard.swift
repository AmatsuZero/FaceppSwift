//
//  BandCard.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/11.
//

import Foundation

public class OCRBankCardV1Option: CardppV1Requst {
    override var requsetURL: URL? {
        return super.requsetURL?.appendingPathComponent("ocrbankcard")
    }
}

public struct OCRBankCardResponse: ResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 被检测的图片在系统中的标识
    public let imageId: String?
    
    public struct Card: Codable {
        public struct Bound: Codable {
            /// 银行卡右上角的像素点坐标
            public let rightTop: FaceppPoint
            /// 银行卡左上角的像素点坐标
            public let leftTop: FaceppPoint
            /// 银行卡右下角的像素点坐标
            public let rightBottom: FaceppPoint
            /// 银行卡左下角的像素点坐标
            public let leftBottom: FaceppPoint
        }
        /// 银行卡卡片四个角的像素点坐标
        public let bound: Bound
        /**
         银行卡号。返回值为纯数字，无空格。
         
         注：返回值的位数不做合法性校验，只会返回识别到的数字。
         */
        public let number: String?
        /**
         表示所属的银行，内容为银行的名字；
         
         如果没有识别到，则返回“null”
         */
        public let bank: String?
        
        public enum Organization: String, Codable {
            case union, master, visa, jcb
        }
        /// 表示所支持的金融组织服务
        public let organization: [Organization]?
    }
    /**
     检测出证件的数组
     
     注：如果没有检测出证件则为空数组
     */
    public let bankCards: [Card]?
}

public class OCRBankCardBetaOption: CardppV1Requst {
    override var requsetURL: URL? {
        return kCardppBetaURL?.appendingPathComponent("ocrbankcard")
    }
}
