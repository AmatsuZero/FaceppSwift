//
//  VehicleLicense.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/10.
//

import Foundation
import ArgumentParser
import FaceppSwift

final class FppVehicleLicenseCommand: FaceCLIBasicCommand {
    static var configuration = CommandConfiguration(
        commandName: "vehiclelicense",
        abstract: "检测和识别中华人民共和国机动车行驶证（以下称“行驶证”）图像为结构化的文字信息。目前只支持行驶证主页正面，不支持副页正面反面。",
        discussion: """
        行驶证图像须为正拍（垂直角度拍摄），但是允许有一定程度的旋转角度；
        仅支持图像里有一个行驶证的主页正面，如果同时出现多页、或正副页同时出现，可能会返回空结果。

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

    func run() throws {
        let option = try OCRVehicleLicenseOption(self)
        semaRun { sema in
            var id: Int?
            id = Cardpp.vehicleLicense(option: option) { err, resp in
                commonResponseHandler(sema, taskID: id, error: err, resp: resp)
            }.request()?.taskIdentifier
        }
    }
}
