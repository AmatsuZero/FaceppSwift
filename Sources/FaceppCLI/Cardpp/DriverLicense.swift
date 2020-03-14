//
//  DriverLicense.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/10.
//

import Foundation
import ArgumentParser
import FaceppSwift

extension OCRDriverLicenseV2Option.Mode: ExpressibleByArgument, Decodable {}

final class FppDriverLicenseCommand: FaceCLIBasicCommand {
    static var configuration = CommandConfiguration(
        commandName: "driverlicense",
        abstract: "检测和识别中华人民共和国机动车驾驶证（以下称“驾照”）图像，并转化为结构化的文字信息",
        discussion: """
        V1: 只支持驾照主页正面，不支持副页正面反面.
        -- 驾照图像须为正拍（垂直角度拍摄），但是允许有一定程度的旋转角度；
        -- 仅支持图像里有一个驾照的主页正面，如果同时出现多页、或正副页同时出现，可能会返回空结果。

        V2: 只可识别驾照正本(main sheet)正面和副本(second sheet)正面，一张照片最多可识别一个正本正面和一个副本正面。
        -- 驾照图像须为正拍（垂直角度拍摄），但是允许有一定程度的旋转角度；
        -- 图片最小 100*100 像素，长宽不得超过4096像素，否则会抛出错误；
        -- 支持图像里有一个或多个驾照的正本正面或副本正面，仅返回置信度最高的一个正本识别结果和一个副本识别结果，如果没有则该项返回为空。

        图片要求：

        -- 图片格式：JPG(JPEG)，PNG
        -- 图片像素尺寸：最小48*48像素，最大4096*4096像素
        -- 图片文件大小：2MB
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
    var apiVersion: FppAPIVersion

    @Flag(default: false, inversion: .prefixedNo, help: "当传入照片输出OCR结果时，是否同时返回置信度")
    var score: Bool

    @Option(name: .shortAndLong, default: .complete, help: "使用该API的快速识别模式还是完备识别模式，可选参数为fast和complete")
    var mode: OCRDriverLicenseV2Option.Mode

    func run() throws {
        switch apiVersion {
        case .v1:
            try runV1()
        case .v2:
            try runV2()
        default:
            break
        }
    }

    func runV1() throws {
        let option = try OCRDriverLicenseV1Option(self)
        semaRun { sema in
            Cardpp.driverLicenseV1(option: option) { err, resp in
                commonResponseHandler(sema, error: err, resp: resp)
            }.request()
        }
    }

    func runV2() throws {
        let option = try OCRDriverLicenseV2Option(self)
        option.needReturnScore = score
        option.mode = mode
        semaRun { sema in
            Cardpp.driverLicenseV2(option: option) { err, resp in
                commonResponseHandler(sema, error: err, resp: resp)
            }.request()
        }
    }
}
