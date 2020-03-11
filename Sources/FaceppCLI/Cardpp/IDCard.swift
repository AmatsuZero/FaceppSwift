//
//  IDCard.swift
//  ArgumentParser
//
//  Created by 姜振华 on 2020/3/10.
//

import Foundation
import FaceppSwift
import ArgumentParser

struct FppIDCardCommand: FaceCLIBasicCommand {
    static var configuration = CommandConfiguration(
        commandName: "idcard",
        abstract: "检测和识别中华人民共和国第二代身份证的关键字段内容，并支持返回身份证正反面信息、身份证照片分类判断",
        discussion: """
        图片要求 ：

        -- 图片格式：JPG(JPEG)，PNG
        -- 图片像素尺寸：最小48*48像素，最大4096*4096像素。 建议身份证在整张图片中面积占比大于1/10。
        -- 图片文件大小：2MB
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

    @Flag(default: false, inversion: .prefixedNo, help: "是否返回身份证照片合法性检查结果")
    var legality: Bool

    func run() throws {
        let option = try OCRIDCardOption(self)
        option.needLegality = legality
        semaRun { sema in
            Cardpp.idCard(option: option) { err, resp in
                commonResponseHandler(sema, error: err, resp: resp)
            }.request()
        }
    }
}
