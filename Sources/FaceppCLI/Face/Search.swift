//
//  Search.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/6.
//

import Foundation
import FaceppSwift
import ArgumentParser

final class FppFaceSearchCommand: FaceCLIBasicCommand {
    static var configuration =  CommandConfiguration(
        commandName: "search",
        abstract: """
        在一个已有的 FaceSet 中找出与目标人脸最相似的一张或多张人脸，返回置信度和不同误识率下的阈值。

        支持传入图片或 face_token 进行人脸搜索。使用图片进行搜索时会选取图片中检测到人脸尺寸最大的一个人脸。
        """,
        discussion: """
        图片要求:

        -- 图片格式：JPG(JPEG)，PNG
        -- 图片像素尺寸：最小 48*48 像素，最大 4096*4096 像素
        -- 图片文件大小：2MB
        -- 最小人脸像素尺寸： 系统能够检测到的人脸框为一个正方形，正方形边长的最小值为 150 像素。
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

    @Option(name: .customLong("token"), help: "进行搜索的目标人脸的 face_token，优先使用该参数")
    var faceToken: String?

    @Option(name: .customLong("settoken"), help: "用来搜索的 FaceSet 的标识")
    var facesetToken: String?

    @Option(name: .customLong("id"), help: "用户自定义的 FaceSet 标识")
    var outerId: String?

    @Option(name: .customLong("count"), default: 1, help: "控制返回比对置信度最高的结果的数量。合法值为一个范围 [1,5] 的整数。默认值为 1")
    var returnResultCount: UInt

    @Option(name: .customLong("rect"), help: "当传入图片进行人脸检测时，是否指定人脸框位置进行检测。")
    var faceRectangle: FaceppRectangle?

    func run() throws {
        let option = try SearchOption(self)
        option.faceToken = faceToken
        option.faceRectangle = faceRectangle
        option.outerId = outerId
        option.returnResultCount = returnResultCount
        option.facesetToken = facesetToken

        semaRun { sema in
            var id: Int?
            id = FaceppSwift.FaceSet.search(option: option) { error, resp in
                commonResponseHandler(sema, taskID: id, error: error, resp: resp)
                }?.taskIdentifier
        }
    }
}

final class FaceSetUserIdCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "sid",
        abstract: "为检测出的某一个人脸添加标识信息，该信息会在Search接口结果中返回，用来确定用户身份"
    )

    @Flag(default: true, inversion: .prefixedEnableDisable, help: "检查参数")
    var checkParams: Bool

    @available(OSX 10.12, *)
    @Flag(default: false, inversion: .prefixedEnableDisable, help: "请求报告，macOS only")
    var metrics: Bool

    @Option(name:[.customShort("T"), .long], default: 60, help: "超时时间，默认60s")
    var timeout: TimeInterval

    @Option(name: .customLong("key"), help: "调用此API的API Key")
    var apiKey: String?

    @Option(name: .customLong("secret"), help: "调用此API的API Secret")
    var apiSecret: String?

    @Option(name: .customLong("token"), help: "人脸标识face_token")
    var faceToken: String

    @Option(name: .customLong("id"), help: "用户自定义的user_id，不超过255个字符，不能包括^@,&=*'\"建议将同一个人的多个face_token设置同样的user_id")
    var userId: String

    func run() throws {
        try setup()
        var option = FaceSetUserIdOption(token: faceToken, id: userId)
        option.setup(self)
        semaRun { sema in
            var id: Int?
            id = FaceppSwift.Facepp.Face.setUserId(option: option) { error, resp in
                commonResponseHandler(sema, taskID: id, error: error, resp: resp)
            }.request()?.taskIdentifier
        }
    }
}
