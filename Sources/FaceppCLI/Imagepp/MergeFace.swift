//
//  MergeFace.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/10.
//

import Foundation
import ArgumentParser
import FaceppSwift

struct FppMergeFaceCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "merge",
        abstract: "使用本 API，可以对模板图和融合图中的人脸进行融合操作。融合后的图片中将包含融合图中的人脸特征，以及模板图中的其他外貌特征与内容。返回值是一段 JSON，包含融合完成后图片的 Base64 编码。",
        discussion: """
        图片要求:

        -- 图片格式：JPG(JPEG)
        -- 图片像素尺寸：最小200*200像素，最大4096*4096像素
        -- 图片文件大小：最大 2 MB
        -- 最小人脸像素尺寸： 为了保证融合效果，推荐图片中人脸框（正方形）边长的最小值不低于200像素。
        -- 人脸质量：人脸质量越高，则融合效果越好。影响人脸质量的因素包括：对人脸五官的遮挡、不当的光照（强光、暗光、逆光）、过大的人脸角度（推荐 yaw ≤ ±10°, pitch ≤ ±10°）等。
        -- 目前不支持黑白照片。
        """
    )

    @Flag(default: true, inversion: .prefixedEnableDisable, help: "检查参数")
    var checkParams: Bool

    @available(OSX 10.12, *)
    @Flag(default: false, inversion: .prefixedEnableDisable, help: "请求报告，macOS only")
    var metrics: Bool

    @Option(name:[.customShort("T"), .long], default: 60, help: "超时时间，默认60s")
    var timeout: TimeInterval

    @Option(name: .customLong("tURL"), help: "模板图片的 URL")
    var templateURL: String?

    @Option(name: .customLong("tFile"), help: "模板图片路径")
    var templateFile: String?

    @Option(name: .customLong("tBase64"), help: "base64 编码的二进制图片数据")
    var templateBase64: String?

    @Option(name: .customLong("key"), help: "调用此API的API Key")
    var apiKey: String?

    @Option(name: .customLong("secret"), help: "调用此API的API Secret")
    var apiSecret: String?

    @Option(name: .customLong("tRect"), help: "指定模板图中进行人脸融合的人脸框位置")
    var templateRectangle: FaceppRectangle?

    @Option(name: .customLong("mURL"), help: "融合图的图片URL")
    var mergeURL: String?

    @Option(name: .customLong("mFile"), help: "融合图的二进制文件")
    var mergeFile: String?

    @Option(name: .customLong("mBase64"), help: "融合图的 Base64 编码二进制文件")
    var mergeBase64: String?

    @Option(name: .customLong("mRect"), help: "指定融合图中用以融合的人脸框位置")
    var mergeRectangle: FaceppRectangle?

    @Option(name: .customLong("mRate"),
            default: 50,
            help: "融合比例，范围 [0,100]。数字越大融合结果包含越多融合图 (merge_url, merge_file, merge_base64 代表图片) 特征。")
    var mergeRate: UInt

    @Option(name: .customLong("fRate"),
            default: 50,
            help: "五官融合比例，范围 [0,100]。主要调节融合结果图中人像五官相对位置，数字越小融合图 (merge_url, merge_file, merge_base64 代表图片)中人像五官相对更集中 。")
    var featureRate: UInt

    func run() throws {
        var option = ImageppMergeFaceOption()
        option.setup(self)
        try setup()
        if let url = templateURL {
           option.templateURL = URL(string: url)
        }
        if let url = templateFile {
            option.templateFile = URL(fileURLWithPath: url)
        }
        option.templateBase64 = templateBase64
        option.templateRectangle = templateRectangle
        if let url = mergeURL {
            option.mergeURL = URL(string: url)
        }
        if let url = mergeFile {
            option.mergeFile = URL(fileURLWithPath: url)
        }
        option.mergeBase64 = mergeBase64
        option.mergeRectangle = mergeRectangle
        option.mergeRate = mergeRate
        option.featureRate = featureRate
        semaRun { sema in
            Imagepp.mergeFace(option: option) { err, resp in
                commonResponseHandler(sema, error: err, resp: resp)
            }.request()
        }
    }
}
