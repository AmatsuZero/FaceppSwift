//
//  Segment.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/9.
//

import Foundation
import ArgumentParser
import FaceppSwift

enum FppSegmentVersion: Int, ExpressibleByArgument, Decodable {
    case v1 = 1, v2
}

extension HumanBodySegmentV2Option.ReturnGrayScale: ExpressibleByArgument, Decodable {}

struct FppHumanBodySegment: FaceCLIBasicCommand {
    static var configuration = CommandConfiguration(
        commandName: "segment",
        abstract: "识别传入图片中人体的完整轮廓，进行人形抠像。",
        discussion: """
        当图像中有多个人时，暂不支持从重叠部分区分出单个人的轮廓。
        2.0支持抠出人像的图片返回。

        图片要求:

        -- 图片格式：JPG(JPEG)，PNG
        -- 图片像素尺寸：最小 48*48 像素，最大1080*1080 像素
        -- 图片文件大小：2 MB
        """
    )

    @Flag(default: true, inversion: .prefixedEnableDisable, help: "检查参数")
    var checkParams: Bool

    @available(OSX 10.12, *)
    @Flag(default: false, inversion: .prefixedEnableDisable, help: "请求报告，macOS only")
    var metrics: Bool

    @Option(name:[.customShort("T"), .long], default: 60, help: "超时时间，默认60s")
    var timeout: TimeInterval

    @Option(name: [.customShort("U"), .customLong("url")], help: "图片的 URL")
    var imageURL: String?

    @Option(name: [.customShort("F"), .customLong("file")], help: "图片路径")
    var imageFile: String?

    @Option(name: .customLong("base64"), help: "base64 编码的二进制图片数据")
    var imageBase64: String?

    @Option(name: .customLong("key"), help: "调用此API的API Key")
    var apiKey: String?

    @Option(name: .customLong("secret"), help: "调用此API的API Secret")
    var apiSecret: String?

    @Option(name: .customLong("apiVersion"), default: .v2, help: "API 版本")
    var apiVersion: FppSegmentVersion

    @Option(name: .customLong("grayScale"), default: .grayScaleAndFigure, help: "抠像后的返回值, 默认都返回")
    var grayScale: HumanBodySegmentV2Option.ReturnGrayScale

    func run() throws {
        switch apiVersion {
        case .v2:
            try runV2()
        case .v1:
            try runV1()
        }
    }

    func runV1() throws {
        let option = try HumanBodySegmentV1Option(self)
        semaRun { sema in
            FaceppHumanBody.segmentV1(option: option) { error, resp in
                commonResponseHandler(sema, error: error, resp: resp)
            }.request()
        }
    }

    func runV2() throws {
        let option = try HumanBodySegmentV2Option(self)
        option.returnGrayScale = grayScale
        semaRun { sema in
            FaceppHumanBody.segmentV2(option: option) { err, resp in
                commonResponseHandler(sema, error: err, resp: resp)
            }.request()
        }
    }
}
