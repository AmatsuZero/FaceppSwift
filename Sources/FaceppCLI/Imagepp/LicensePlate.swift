//
//  LicensePlate.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/10.
//

import Foundation
import FaceppSwift
import ArgumentParser

final class FppLicensePlateCommand: FaceCLIBasicCommand {
    static var configuration = CommandConfiguration(
        commandName: "plate",
        abstract: "调用者传入一张图片文件或图片URL，检测并返回图片中车牌框并识别车牌颜色和车牌号。当传入图片中有多个车牌时，按照车牌框大小排序依次输出",
        discussion: """
        图片要求:

        -- 图片格式：JPG(JPEG)，PNG
        -- 图片像素尺寸：最小 48*48 像素，最大 4096*4096 像素
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

    func run() throws {
        let option = try ImageppLicensePlateOption(self)
        semaRun { sema in
            Imagepp.licensePlate(option: option) { err, resp in
                commonResponseHandler(sema, error: err, resp: resp)
            }.request()
        }
    }
}
