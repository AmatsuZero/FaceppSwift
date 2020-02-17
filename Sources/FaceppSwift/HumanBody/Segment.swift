//
//  Segment.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/13.
//  Wiki: https://console.faceplusplus.com.cn/documents/10071567
//

import Foundation

/**
 识别传入图片中人体的完整轮廓，进行人形抠像。
 当图像中有多个人时，暂不支持从重叠部分区分出单个人的轮廓。
 */
public class HumanBodySegmentV1Option: FaceppBaseRequest {
    override var requsetURL: URL? {
        return kHumanBodyV1URL?.appendingPathComponent("segment")
    }
}

/**
 识别传入图片中人体的完整轮廓，进行人形抠像。
 当图像中有多个人时，暂不支持从重叠部分区分出单个人的轮廓。
 V2 升级内容：增加抠出人像的图片返回。
 */
public class HumanBodySegmentV2Option: FaceppBaseRequest {

    /// 抠像后的返回值
    public enum ReturnGrayScale: Int {
        /// 不返回灰度图，仅返回人像图片
        case figureOnly = 0
        /// 返回灰度图及人像图片
        case grayScaleAndFigure
        /// 只返回灰度图
        case grayScaleOnly
    }
    /**
     抠像后的返回值，默认值为仅返回人像
     注：如果只需要抠出的人像图，建议设置为figureOnly（不返回灰度图）。
     可以节省API调用时间，更快速的得到结果
     */
    public var returnGrayScale = ReturnGrayScale.figureOnly

    override var requsetURL: URL? {
        return kHumanBodyV2URL?.appendingPathComponent("segment")
    }

    override func params(apiKey: String, apiSecret: String) throws -> (Params, [Params]?) {
        var (params, files) = try super.params(apiKey: apiKey, apiSecret: apiSecret)
        params["return_grayscale"] = returnGrayScale.rawValue
        return (params, files)
    }
}

public struct HumanBodySegmentResponse: ResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 被检测的图片在系统中的标识。
    public let imageId: String?
    /**
         
     一个通过 Base64 编码的灰度图文件，图片中每个像素点的灰度值 V = confidence * 255，
     confidence（置信度）为原图对应像素点位于人体轮廓内的置信度，取值范围[0, 1]。

     例如：原图是一个 400*300 的图片，那么返回一个400*300的灰度图，如果一个像素点位于人体轮廓内的置信度为0.91，
     这个像素的灰度值为置信度232（0.91*255）.
     */
    public let result: String?
    /**
     一个通过base64 编码的图片文件。解码后文件为抠出人像的图片，背景为透明色。图片大小与原图一致。

     阈值：置信度大于0.5的像素展示出来。

     （V2添加参数）
     */
    public let bodyImage: String?
}
