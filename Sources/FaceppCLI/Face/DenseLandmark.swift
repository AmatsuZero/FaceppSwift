//
//  DenseLandmark.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/6.
//

import Foundation
import ArgumentParser
import FaceppSwift

final class FppDenseLandmarkCommand: FaceCLIBasicCommand {
    static var configuration = CommandConfiguration(
        commandName: "thousandlandmark",
        abstract: "该API可根据单张正面人脸图片，分析人脸面部特征。",
        discussion: """
            图片要求:
            -- 图片格式：JPG(JPEG)
            -- 图片像素尺寸：最小200*200像素，最大4096*4096像素
            -- 图片文件大小：最大 2 MB
            -- 最小人脸像素尺寸： 为了保证效果，推荐图片中人脸框（正方形）边长的最小值不低于200像素。
            -- 人脸质量：人脸质量越高，则面部特征分析越准确。影响人脸质量的因素包括：对人脸五官的遮挡、图片模糊、不当的光照（强光、暗光、逆光）、过大的人脸角度（要求 roll≤ ±45°, yaw ≤ ±20°, pitch ≤ ±20°）等。
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

    @Option(name: .customLong("token"), help: "人脸标识 face_token，优先使用该参数")
    var faceToken: String?

    @Argument(help: "是否检测并返回人脸关键点")
    var landmarks: [String]

    func run() throws {
        let option = try ThousandLandMarkOption(command: self)
        semaRun { sema in
            FaceppSwift.Facepp.thousandLandmark(option: option) { error, resp in
                commonResponseHandler(sema, error: error, resp: resp)
            }.request()
        }
    }
}

extension ThousandLandMarkOption {
    convenience init(command: FppDenseLandmarkCommand) throws {
        if command.landmarks.contains("all") {
            self.init(returnLandMark: Set<ReturnLandMark>.all)
        } else {
            self.init(returnLandMark: Set(command.landmarks
                .compactMap { ReturnLandMark(rawValue: $0) }))
        }
        try command.setup()
        timeoutInterval = command.timeout
        needCheckParams = command.checkParams
        if #available(OSX 10.12, *), command.metrics {
            metricsReporter = FppConfig.currentUser
        }
        if let url = command.imageURL {
            imageURL = URL(string: url)
        }
        if let url = command.imageFile {
            imageFile = URL(fileURLWithPath: url)
        }
        imageBase64 = command.imageBase64
        faceToken = command.faceToken
    }
}
