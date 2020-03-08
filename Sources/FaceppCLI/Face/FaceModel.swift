//
//  FaceModel.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/6.
//

import Foundation
import FaceppSwift
import ArgumentParser

struct FppFaceModelCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "model",
        abstract: "该API可根据单张或多张单人人脸图片，重建3D人脸效果。",
        discussion: """
        图片要求:
        -- 图片格式：JPG(JPEG)
        -- 图片像素尺寸：最小200*200像素，最大4096*4096像素
        -- 图片文件大小：最大 2 MB
        -- 最小人脸像素尺寸： 为了保证重建效果，推荐图片中人脸框（正方形）边长的最小值不低于200像素。
        -- 人脸质量：人脸质量越高，则重建效果越好。影响人脸质量的因素包括：对人脸五官的遮挡、不当的光照（强光、暗光、逆光）、图片模糊等。
        """
    )

    @Option(name: .customLong("key"), help: "调用此API的API Key")
    var apiKey: String?

    @Option(name: .customLong("secret"), help: "调用此API的API Secret")
    var apiSecret: String?

    @Flag(default: true, inversion: .prefixedEnableDisable, help: "检查参数")
    var checkParams: Bool

    @Flag(default: false, inversion: .prefixedEnableDisable, help: "请求报告，macOS only")
    var metrics: Bool

    @Option(name:[.customShort("T"), .long], default: 60, help: "超时时间，默认60s")
    var timeout: TimeInterval

    @Option(name: .customLong("url1"), help: "人脸正脸图片的 URL")
    var imageURL1: String?

    @Option(name: .customLong("file1"), help: "人脸正脸图片的路径")
    var imageFile1: String?

    @Option(name: .customLong("base64-1"), help: "第一张图片base64 编码的二进制图片数据")
    var imageBase641: String?

    @Option(name: .customLong("url2"), help: "第二张图片的 URL，建议传入左侧侧脸图片")
    var imageURL2: String?

    @Option(name: .customLong("file2"), help: "第二张图片路径")
    var imageFile2: String?

    @Option(name: .customLong("base64-2"), help: "第二张图片base64 编码的二进制图片数据")
    var imageBase642: String?

    @Option(name: .customLong("url2"), help: "第三张图片的 URL，建议传入右侧侧脸图片")
    var imageURL3: String?

    @Option(name: .customLong("file2"), help: "第三张图片路径")
    var imageFile3: String?

    @Option(name: .customLong("base64-2"), help: "第三张图片base64 编码的二进制图片数据")
    var imageBase643: String?

    @Flag(inversion: .prefixedNo, help: "是否返回纹理图")
    var texture: Bool

    @Flag(inversion: .prefixedNo, help: "是否返回mtl文件")
    var mtl: Bool

    @Option(name: .shortAndLong, help: "输出路径")
    var output: String?

    func run() throws {
        try setup()
        var option = ThreeDimensionFaceOption()
        option.setup(self)
        option.imageBase641 = imageBase641
        option.imageBase642 = imageBase642
        option.imageBase643 = imageBase643
        option.needMtl = mtl
        option.needTexture = texture

        if let url = imageURL1 {
            option.imageURL1 = URL(string: url)
        }
        if let url = imageFile1 {
            option.imageFile1 = URL(fileURLWithPath: url)
        }

        if let url = imageURL2 {
            option.imageURL2 = URL(string: url)
        }
        if let url = imageFile2 {
            option.imageFile2 = URL(fileURLWithPath: url)
        }

        if let url = imageURL3 {
            option.imageURL3 = URL(string: url)
        }
        if let url = imageFile3 {
            option.imageFile3 = URL(fileURLWithPath: url)
        }

        semaRun { sema in
            FaceppSwift.Facepp.threeDimensionFace(option: option) { error, resp in
                if let url = self.output {
                    do {
                        try resp?.saveFaceModel(in: .init(fileURLWithPath: url))
                    } catch let e {
                        writeError(e)
                    }
                }
                commonResponseHandler(sema, error: error, resp: resp)
            }.request()
        }
    }
}

extension ThreeDimensionFaceResponse {
    public enum FileError: Error {
        case folderNotExist
        case invalidResponse
    }

    /// 保存人脸模型
    /// - Parameters:
    ///   - folderURL: 目标文件夹
    ///   - createFolder: 是否自动创建目标文件夹
    public func saveFaceModel(in folderURL: URL, createFolder: Bool = true) throws {
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            if createFolder {
                try FileManager.default.createDirectory(at: folderURL,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } else {
                throw FileError.folderNotExist
            }
        }
        // 保存材质文件
        if let texture = textureImg,
            let data = Data(base64Encoded: texture) {
            let dest = folderURL
                .appendingPathComponent("tex")
                .appendingPathExtension("jpg")
            try data.write(to: dest, options: .atomic)
        }

        // 保存.obj文件
        if let objFile = objFile,
            let data = Data(base64Encoded: objFile) {
            let dest = folderURL
                .appendingPathComponent("face")
                .appendingPathExtension("obj")
            try data.write(to: dest, options: .atomic)
        }

        // 保存.mtl文件
        if let mtlFile = mtlFile,
            let data = Data(base64Encoded: mtlFile) {
            let dest = folderURL
                .appendingPathComponent("face")
                .appendingPathExtension("mtl")
            try data.write(to: dest, options: .atomic)
        }
    }
}
