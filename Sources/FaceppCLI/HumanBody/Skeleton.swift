//
//  Skeleton.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/9.
//

import Foundation
import FaceppSwift
import ArgumentParser

final class FppHumanBodySkeleton: FaceCLIBasicCommand {
    static var configuration = CommandConfiguration(
        commandName: "skeleton",
        abstract: "传入图片进行人体检测和骨骼关键点检测，返回人体14个关键点",
        discussion: """
              支持对图片中的所有人体进行骨骼检测。

              图片要求:

              -- 图片格式：JPG(JPEG)
              -- 图片像素尺寸：最小 100*100 像素，最大 4096*4096 像素
              -- 图片文件大小：2 MB
              -- 为了保证较好的识别结果，人体矩形框大小建议在200*200像素及以上
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
        let option = try SkeletonDetectOption(self)
        semaRun { sema in
            FaceppHumanBody.skeleton(option: option) { error, resp in
                commonResponseHandler(sema, error: error, resp: resp)
            }.request()
        }
    }
}
