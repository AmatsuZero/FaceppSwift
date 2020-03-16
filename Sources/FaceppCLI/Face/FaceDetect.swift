//
//  FaceDetect.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/4.
//

import Foundation
import ArgumentParser
import FaceppSwift

extension FaceDetectOption.ReturnAttributes: ExpressibleByArgument, Decodable {}

extension FaceDetectOption.ReturnLandmark: ExpressibleByArgument, Decodable {}

final class FppDetectCommand: FaceCLIBasicCommand {
    static var configuration =  CommandConfiguration(
        commandName: "detect",
        abstract: """
        传入图片进行人脸检测和人脸分析。

        可以检测图片内的所有人脸，对于每个检测出的人脸，会给出其唯一标识 face_token，可用于后续的人脸分析、人脸比对等操作。对于正式 API Key，支持指定图片的某一区域进行人脸检测。

        本 API 支持对检测到的人脸直接进行分析，获得人脸的关键点和各类属性信息。对于试用 API Key，
        最多只对人脸框面积最大的5个人脸进行分析，其他检测到的人脸可以使用 Face Analyze API 进行分析。
        对于正式 API Key，支持分析所有检测到的人脸。
        """,
        discussion: """
        关于 face_token:
        -- 如果您需要将检测出的人脸用于后续的分析、比对等操作，建议将对应的 face_token 添加到 FaceSet 中。如果一个 face_token 在 72小时内没有存放在任一 FaceSet 中，则该 face_token 将会失效。

        如果对同一张图片进行多次人脸检测，同一个人脸得到的 face_token 是不同的。

        图片要求:

        -- 图片格式：JPG(JPEG)，PNG
        -- 图片像素尺寸：最小 48*48 像素，最大 4096*4096 像素
        -- 图片文件大小：2 MB
        -- 最小人脸像素尺寸： 系统能够检测到的人脸框为一个正方形，正方形边长的最小值为图像短边长度的 48 分之一，最小值不低于 48 像素。例如图片为4096*3200 像素，则最小人脸像素尺寸为 66*66 像素。
        """)

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

    @Option(name: .customLong("landmark"), default: .no, help: "是否检测并返回人脸关键点")
    var returnLandmark: FaceDetectOption.ReturnLandmark

    @Option(help: "是否检测并返回人脸关键点")
    var attributes: [FaceDetectOption.ReturnAttributes]

    @Option(name: .shortAndLong, help: "是否指定人脸框位置进行人脸检测")
    var faceRectangle: FaceppRectangle?

    @Option(name:.customLong("min"), default: 0, help: "颜值评分分数区间的最小值。默认为0")
    var beautyScoreMin: Int

    @Option(name: .customLong("max"), default: 100, help: "颜值评分分数区间的最小值。默认为0")
    var beautyScoreMax: Int

    @Option(name: .customLong("all"), help: "是否检测并返回所有人脸的人脸关键点和人脸属性")
    var calculateAll: Int?

    func run() throws {
        let option = try FaceDetectOption(self)
        if attributes.contains(.none) {
            option.returnAttributes = [.none]
        } else {
            option.returnAttributes = Set(attributes)
        }
        option.returnLandmark = returnLandmark
        if let flag = calculateAll {
            option.calculateAll = flag == 1
        }
        option.beautyScoreMax = beautyScoreMax
        option.beautyScoreMin = beautyScoreMin
        semaRun { sema in
            FaceppSwift.Facepp.detect(option: option) { error, resp in
                commonResponseHandler(sema, error: error, resp: resp)
            }.request()
        }
    }
}

final class FaceGetDetailCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "detail",
        abstract: "通过传入在Detect API检测出的人脸标识face_token，获取一个人脸的关联信息，包括源图片ID、归属的FaceSet"
    )

    @Flag(default: true, inversion: .prefixedEnableDisable, help: "检查参数")
    var checkParams: Bool

    @available(OSX 10.12, *)
    @Flag(default: false, inversion: .prefixedEnableDisable, help: "请求报告，macOS only")
    var metrics: Bool

    @Option(name:[.customShort("T"), .long], default: 60, help: "超时时间，默认60s")
    var timeout: TimeInterval

    @Option(name: .customLong("key"), help: "调用此API的API Key")
    var apiKey: String?

    @Option(name: .customLong("secret"), help: "调用此API的API Secret")
    var apiSecret: String?

    @Option(name: .customLong("token"), help: "人脸标识face_token")
    var faceToken: String

    func run() throws {
        try setup()
        var option = FaceGetDetailOption(token: faceToken)
        option.setup(self)
        semaRun { sema in
            FaceppSwift.Facepp.Face.getDetail(option: option) { error, resp in
                commonResponseHandler(sema, error: error, resp: resp)
            }.request()
        }
    }
}

final class FaceAnalyzeCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "analyze",
        abstract: "传入在 Detect API 检测出的人脸标识 face_token，分析得出人脸关键点，人脸属性信息。一次调用最多支持分析 5 个人脸"
    )

    @Flag(default: true, inversion: .prefixedEnableDisable, help: "检查参数")
    var checkParams: Bool

    @available(OSX 10.12, *)
    @Flag(default: false, inversion: .prefixedEnableDisable, help: "请求报告，macOS only")
    var metrics: Bool

    @Option(name:[.customShort("T"), .long], default: 60, help: "超时时间，默认60s")
    var timeout: TimeInterval

    @Option(name: .customLong("key"), help: "调用此API的API Key")
    var apiKey: String?

    @Option(name: .customLong("secret"), help: "调用此API的API Secret")
    var apiSecret: String?

    @Option(name:.customLong("min"), default: 0, help: "颜值评分分数区间的最小值。默认为0")
    var beautyScoreMin: Int

    @Option(name: .customLong("max"), default: 100, help: "颜值评分分数区间的最小值。默认为0")
    var beautyScoreMax: Int

    @Option(name: .customLong("landmark"), default: .no, help: "是否检测并返回人脸关键点")
    var returnLandmark: FaceDetectOption.ReturnLandmark

    @Option(help: "是否检测并返回人脸关键点")
    var attributes: [FaceDetectOption.ReturnAttributes]

    @Argument(help: "最多支持 5 个 face_token")
    var faceTokens: [String]

    func run() throws {
        try setup()
        var option = FaceAnalyzeOption(tokens: faceTokens)
        option.setup(self)
        if attributes.contains(.none) {
            option.returnAttributes = [.none]
        } else {
            option.returnAttributes = Set(attributes)
        }
        option.returnLandmark = returnLandmark
        option.beautyScoreMax = beautyScoreMax
        option.beautyScoreMin = beautyScoreMin
        semaRun { sema in
            FaceppSwift.Facepp.Face.analyze(option: option) { error, resp in
                commonResponseHandler(sema, error: error, resp: resp)
            }.request()
        }
    }
}
