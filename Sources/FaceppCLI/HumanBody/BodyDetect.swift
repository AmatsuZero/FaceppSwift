//
//  BodyDetect.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/9.
//

import Foundation
import ArgumentParser
import FaceppSwift

extension HumanBodyDetectOption.ReturnAttributes: ExpressibleByArgument, Decodable {}

struct FppHumanBodyDetect: FaceCLIBasicCommand {
    static var configuration = CommandConfiguration(
        commandName: "detect",
        abstract: "传入图片进行人体检测和人体属性分析",
        discussion: """
           本 API 支持检测图片内的所有人体，并且支持对检测到的人体直接进行分析，获得每个人体的各类属性信息。

           图片要求:

           -- 图片格式：JPG(JPEG)，PNG
           -- 图片像素尺寸：最小 48*48 像素，最大 1280*1280 像素
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

    @Argument(help: "是否检测并返回根据人体特征判断出的性别，服装颜色等属性")
    var attributes: [HumanBodyDetectOption.ReturnAttributes]

    func run() throws {
        let option = try HumanBodyDetectOption(self)
        if attributes.contains(.none) {
            option.returnAttributes = [.none]
        } else {
            option.returnAttributes = Set(attributes)
        }
        semaRun { sema in
            FaceppHumanBody.bodyDetect(option: option) { err, resp in
                commonResponseHandler(sema, error: err, resp: resp)
            }.request()
        }
    }
}
