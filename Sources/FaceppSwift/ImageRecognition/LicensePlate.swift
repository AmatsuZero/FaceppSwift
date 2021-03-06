//
//  LicensePlate.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/13.
//

import Foundation

/**
 /// 调用者传入一张图片文件或图片URL，检测并返回图片中车牌框并识别车牌颜色和车牌号。
 当传入图片中有多个车牌时，按照车牌框大小排序依次输出。
 */
@objc(FppLicensePlateOption)
public class ImageppLicensePlateOption: FaceppBaseRequest {
    override var requsetURL: URL? {
        return kImageppV1URL?.appendingPathComponent("licenseplate")
    }
}

extension ImageppLicensePlateOption: FppDataRequestProtocol {
    @objc public func request(completionHandler: @escaping (Error?, ImageppLicensePlateResponse?) -> Void) -> URLSessionTask? {
        return FaceppClient.shared?.parse(option: self, completionHandler: completionHandler)
    }
}

@objc(FppLicensePlateRespons)
@objcMembers public final class ImageppLicensePlateResponse: NSObject, FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒
    public var timeUsed: Int?
    /// 被检测的图片在系统中的标识
    public let imageId: String?

    @objc(FppLicensePlateColor)
    public enum Color: Int, Codable {
        case blue = 0, yellow, black, white, green
        /// 小型新能源
        case smallNewEnergy
        /// 大型新能源
        case largeNewEnergy
        /// 缺失
        case missing
        /// 无效
        case invalid
    }

    @objc(FppLicensePlateResult)
    @objcMembers public final class Result: NSObject, Codable {
        /// 车牌四个角的像素点坐标
        public let bound: FaceppBound
        /// 识别出的车牌底色
        public let color: Color
        /// 识别出的车牌号结果
        public let licensePlateNumber: String
    }
    /**
     检测出的车牌数组，具体包含内容见下文
     注：如果没有检出车牌，则返回结果为空数组
     */
    public let results: [Result]?
}
