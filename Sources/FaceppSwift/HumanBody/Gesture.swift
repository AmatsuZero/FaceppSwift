//
//  Gesture.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/13.
//  Wiki: https://console.faceplusplus.com.cn/documents/10065649
//

import Foundation
/**
 调用者提供图片文件或者图片URL，检测图片中出现的所有的手部，并返回其在图片中的矩形框位置与相应的手势含义。
 目前可以识别 19 种手势。
 识别出的手部位置会以一个矩形框表示。矩形框包含的范围从手腕到指尖。
 注意：本算法目前是专为移动设备自拍场景设计，在其他场景下对手势的识别精度可能不足。
 */
public class HumanBodyGestureOption: FaceppBaseRequest {
    /// 是否计算并返回每个手的手势信息
    public var returnGesture = true

    override var requsetURL: URL? {
        return kHumanBodyBaseV1URL?.appendingPathComponent("gesture")
    }

    override func params(apiKey: String, apiSecret: String) throws -> (Params, [Params]?) {
        var (params, files) = try super.params(apiKey: apiKey, apiSecret: apiSecret)
        params["return_gesture"] = returnGesture ? 1 : 0
        return (params, files)
    }
}

public struct HumanBodyGestureResponse: ResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串。
    public var requestId: String?
    /// 当请求失败时才会返回此字符串，具体返回内容见后续错误信息章节。否则此字段不存在。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒。
    public var timeUsed: Int?
    /// 整个请求所花费的时间，单位为毫秒。
    public let imageId: String?

    /// 手势，参考Wiki：https://console.faceplusplus.com.cn/documents/10065685
    public struct Gesture: Codable {
        /// 未定义手势
        public let unknown: Float
        /// 比心 A
        public let heartA: Float
        /// 比心 B
        public let heartB: Float
        /// 比心 C
        public let heartC: Float
        /// 比心 D
        public let heartD: Float
        /// OK
        public let ok: Float
        /// 手张开
        public let handOpen: Float
        /// 大拇指向上
        public let thumbUp: Float
        /// 大拇指向下
        public let thumbDown: Float
        /// ROCK
        public let rock: Float
        /// 合十
        public let namaste: Float
        /// 手心向上
        public let palmUp: Float
        /// 握拳
        public let fist: Float
        /// 食指朝上
        public let indexFingerUp: Float
        /// 双指朝上
        public let doubleFingerUp: Float
        /// 胜利
        public let victory: Float
        /// 大 V 字
        public let bigV: Float
        /// 打电话
        public let phonecall: Float
        /// 作揖
        public let beg: Float
        /// 感谢
        public let thanks: Float
    }

    public struct Hands: Codable {
        /// 手部矩形框，坐标数字为整数，代表像素点坐标
        public let handRectangle: FaceppRectangle
        /// 手势识别结果，包括以下字段。每个字段的值是一个浮点数，范围 [0,100]，小数点后3位有效数字，总和等于100。
        public let gesture: Gesture
    }
    /**
     被检测出的手部数组
     注：如果没有检测出手则为空数组
     */
    public let hands: [Hands]?
}