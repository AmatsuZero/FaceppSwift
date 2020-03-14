//
//  Compare.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/5.
//

import ArgumentParser
import FaceppSwift
import Foundation

final class FppFaceCompareCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "compare",
        abstract: """
        将两个人脸进行比对，来判断是否为同一个人，返回比对结果置信度和不同误识率下的阈值。

        支持传入图片或 face_token 进行比对。使用图片时会自动选取图片中检测到人脸尺寸最大的一个人脸。
        """,
        discussion: """
        图片要求:
        -- 图片格式：JPG(JPEG)，PNG
        -- 图片像素尺寸：最小 48*48 像素，最大 4096*4096 像素
        -- 图片文件大小：2MB
        -- 最小人脸像素尺寸： 系统能够检测到的人脸框为一个正方形，正方形边长的最小值为 150 像素。
        """
    )

    @Option(name: .customLong("key"), help: "调用此API的API Key")
    var apiKey: String?

    @Option(name: .customLong("secret"), help: "调用此API的API Secret")
    var apiSecret: String?

    @Flag(default: true, inversion: .prefixedEnableDisable, help: "检查参数")
    var checkParams: Bool

    @available(OSX 10.12, *)
    @Flag(default: false, inversion: .prefixedEnableDisable, help: "请求报告，macOS only")
    var metrics: Bool

    @Option(name:[.customShort("T"), .long], default: 60, help: "超时时间，默认60s")
    var timeout: TimeInterval

    @Option(name: .customLong("url1"), help: "第一张图片的 URL")
    var imageURL1: String?

    @Option(name: .customLong("file1"), help: "第一张图片路径")
    var imageFile1: String?

    @Option(name: .customLong("base64-1"), help: "第一张图片base64 编码的二进制图片数据")
    var imageBase641: String?

    @Option(name: .customLong("token1"), help: "第一个人脸标识 face_token，优先使用该参数")
    var faceToken1: String?

    @Option(name: .customLong("token2"), help: "第二个人脸标识 face_token，优先使用该参数")
    var faceToken2: String?

    @Option(name: .customLong("url2"), help: "第二张图片的 URL")
    var imageURL2: String?

    @Option(name: .customLong("file2"), help: "第二张图片路径")
    var imageFile2: String?

    @Option(name: .customLong("base64-2"), help: "第二张图片base64 编码的二进制图片数据")
    var imageBase642: String?

    @Option(name: .customLong("rect1"), help: "当传入第一张图片进行人脸检测时，是否指定人脸框位置进行检测。")
    var faceRectangle1: FaceppRectangle?

    @Option(name: .customLong("rect2"), help: "当传入第二张图片进行人脸检测时，是否指定人脸框位置进行检测。")
    var faceRectangle2: FaceppRectangle?

    func run() throws {
        try setup()
        var option = CompareOption()
        option.setup(self)
        if let url = imageURL1 {
            option.imageURL1 = URL(string: url)
        }
        if let url = imageFile1 {
            option.imageFile1 = URL(fileURLWithPath: url)
        }
        option.imageBase641 = imageBase641
        option.faceToken1 = faceToken1
        if let url = imageURL2 {
            option.imageURL2 = URL(string: url)
        }
        if let url = imageFile2 {
            option.imageFile2 = URL(fileURLWithPath: url)
        }
        option.imageBase642 = imageBase642
        option.faceToken2 = faceToken2
        option.faceRectangle1 = faceRectangle1
        option.faceRectangle2 = faceRectangle2

        semaRun { sema in
            FaceppSwift.Facepp.compare(option: option) { error, resp in
                commonResponseHandler(sema, error: error, resp: resp)
            }.request()
        }
    }
}
