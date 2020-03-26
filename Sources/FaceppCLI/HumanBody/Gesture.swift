//
//  Gesture.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/9.
//

import Foundation
import ArgumentParser
import FaceppSwift

final class FppHumanBodyGesture: FaceCLIBasicCommand {
    static var configuration = CommandConfiguration(
        commandName: "gesture",
        abstract: "调用者提供图片文件或者图片URL，检测图片中出现的所有的手部，并返回其在图片中的矩形框位置与相应的手势含义",
        discussion: """
        目前可以识别 19 种手势。
        识别出的手部位置会以一个矩形框表示。矩形框包含的范围从手腕到指尖。
        注意：本算法目前是专为移动设备自拍场景设计，在其他场景下对手势的识别精度可能不足。

        图片要求:

        -- 图片格式：JPG(JPEG)，PNG
        -- 图片像素尺寸：最小 300*300 像素，最大 4096*4096 像素。图片短边不得低于 300 像素。
        -- 图片文件大小：2MB

        最小手部像素尺寸： 系统能够检测到的手部框为一个矩形框。矩形框的最短边边长建议不小于图片最短边边长的 1 / 10。
        例如图片为 4096*3200 像素，则建议的最小手部框最短边尺寸为 320 像素。如果不满足此要求，则可能会影响识别精度。
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

    @Flag(default: true, inversion: .prefixedNo, help: "是否计算并返回每个手的手势信息")
    var detail: Bool

    func run() throws {
        let option = try HumanBodyGestureOption(self)
        option.returnGesture = detail
        semaRun { sema in
            var id: Int?
            let task = FaceppHumanBody.gesture(option: option) { error, resp in
                commonResponseHandler(sema, taskID: id, error: error, resp: resp)
            }.request()
            id = task?.taskIdentifier
        }
    }
}
