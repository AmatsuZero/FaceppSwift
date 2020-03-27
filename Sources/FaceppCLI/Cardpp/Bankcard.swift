//
//  Bankcard.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/10.
//

import Foundation
import ArgumentParser
import FaceppSwift

final class FppBankcardCommand: FaceCLIBasicCommand {
    static var configuration = CommandConfiguration(
        commandName: "bank",
        abstract: "检测和识别各类银行卡，并返回银行卡卡片边框坐标、银行卡号码、所属银行及支持的金融组织服务。支持任意角度的识别",
        discussion: """
        图片要求 ：

        -- 图片格式：JPG(JPEG)，PNG
        -- 图片文件大小：2 MB
        -- 卡片像素尺寸：最小 100*100 像素，最大 4096*4096 像素，短边不得低于 100 像素。
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

    @Option(name: .customLong("apiVersion"), default: .v1, help: "API 版本")
    var apiVersion: FppAPIVersion

    func run() throws {
        switch apiVersion {
        case .v1:
            try runV1()
        case .beta:
            try runBeta()
        default:
            break
        }
    }

    func runV1() throws {
        let option = try OCRBankCardV1Option(self)
        semaRun { sema in
            var id: Int?
            let task = Cardpp.bankCardV1(option: option) { err, resp in
                commonResponseHandler(sema, taskID: id, error: err, resp: resp)
            }.request()
            id = task?.taskIdentifier
        }
    }

    func runBeta() throws {
        let option = try OCRBankCardBetaOption(self)
        semaRun { sema in
            var id: Int?
            let task = Cardpp.bankCardBeta(option: option) { err, resp in
                commonResponseHandler(sema, taskID: id, error: err, resp: resp)
            }.request()
            id = task?.taskIdentifier
        }
    }
}
