//
//  TemplateOCR.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/10.
//

import Foundation
import ArgumentParser
import FaceppSwift

final class FppTemplateOCRCommand: FaceCLIBasicCommand {
    static var configuration = CommandConfiguration(
        commandName: "template",
        abstract: "用户通过控制台生成自定义模板并发布后，调用此API传入待识别图片及模板ID，返回模板定义的识别域内容",
        discussion: """
        注意：
        -- 只能识别已发布的模板
        -- 一次只能识别一张待识别图片

        图片要求：

        -- 图片格式：支持JPEG，JPG，PNG，BMP
        -- 图片尺寸：图片最长边不超过4096像素，最短边不少于512像素
        -- 图片大小：图片大小不超过4M
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

    @Option(name: .customLong("id"), help: "指定的模板ID（模版ID在创建模板后由系统自动生成）")
    var templateId: String

    @Option(name: .customLong("extra"), help: """
    该参数的值是一个单字符串或者以英文逗号分割的字符串，表示需要返回的额外信息。
    当前只支持extra_info=position，表示返回识别域的位置信息（识别域四个点坐标
    """)
    var extraInfo: String?

    func run() throws {
        var option = OCRTemplateOption(templateId: templateId)
        option.setup(self)
        try setup()
        option.timeoutInterval = timeout
        option.needCheckParams = checkParams
        if #available(OSX 10.12, *), metrics {
            option.metricsReporter = FppConfig.currentUser
        }
        if let url = imageURL {
            option.imageURL = URL(string: url)
        }
        if let url = imageFile {
            option.imageFile = URL(fileURLWithPath: url)
        }
        option.imageBase64 = imageBase64
        option.extraInfo = extraInfo?.components(separatedBy: ",")

        semaRun { sema in
            Cardpp.templateOCR(option: option) { err, resp in
                commonResponseHandler(sema, error: err, resp: resp)
            }.request()
        }
    }
}
