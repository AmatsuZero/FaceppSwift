//
//  SkeletonDetect.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/13.
// Wiki: https://console.faceplusplus.com.cn/documents/37664576
//

import Foundation

/**
 传入图片进行人体检测和骨骼关键点检测，返回人体14个关键点

 支持对图片中的所有人体进行骨骼检测
 */
@objc(FppSkeletonDetectOption)
public class SkeletonDetectOption: FaceppBaseRequest {
    override var requsetURL: URL? {
        return kHumanBodyV1URL?.appendingPathComponent("skeleton")
    }
}

public struct SkeletonDetectResponse: FaceppResponseProtocol {
    public var requestId: String?
    public var errorMessage: String?
    public var timeUsed: Int?
    /// 被检测的图片在系统中的标识
    public let imageId: String?

    public struct LandMark: Codable, Hashable {
        /// 头部
        public let head: FaceppPoint
        /// 脖子
        public let neck: FaceppPoint
        /// 左肩
        public let leftShoulder: FaceppPoint
        /// 左肘
        public let leftElbow: FaceppPoint
        /// 左手
        public let leftHand: FaceppPoint
        /// 右肩
        public let rightShoulder: FaceppPoint
        /// 右肘
        public let rightElbow: FaceppPoint
        /// 右手
        public let rightHand: FaceppPoint
        /// 左臀
        public let leftButtocks: FaceppPoint
        /// 左膝
        public let leftKnee: FaceppPoint
        /// 左脚
        public let leftFoot: FaceppPoint
        /// 右臀
        public let rightButtocks: FaceppPoint
        /// 右膝
        public let rightKnee: FaceppPoint
        /// 右脚
        public let rightFoot: FaceppPoint
    }

    public struct Skeleton: Codable, Hashable {
        /// 人体矩形框的位置，包括以下属性。
        public let bodyRectangle: FaceppRectangle
        /// 包含14个骨骼关键点的对象类型
        public let landmark: LandMark
    }
    /**
     被检测出的人体数组，具体包含内容见下文。

     注：如果没有检测出人体则为空
     */
    public let skeletons: [Skeleton]?
}
