//
//  DetectSceneAndObject.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/10.
//

import Foundation
import FaceppSwift
import ArgumentParser

final class FppDetectSceneAndObjectCommand: FaceCLIBasicCommand {
    static var configuration = CommandConfiguration(
        commandName: "detect",
        abstract: "调用者提供图片文件或者图片URL，进行图片分析，识别图片场景和图片主体",
        discussion: """
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
        let option = try ImageppDetectScenceAndObjectOption(self)
        semaRun { sema in
            var id: Int?
            id = Imagepp.detectsceneandobject(option: option) { err, resp in
                commonResponseHandler(sema, taskID: id, error: err, resp: resp)
            }.request()?.taskIdentifier
        }
    }
}
