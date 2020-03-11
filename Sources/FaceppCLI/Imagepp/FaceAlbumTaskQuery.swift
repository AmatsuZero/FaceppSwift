//
//  FaceAlbumTaskQuery.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/10.
//

import Foundation
import FaceppSwift
import ArgumentParser

struct FppFaceAlbumSearchTaskQueryCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "search",
        abstract: "通过该接口查询searchimage后的结果"
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

    @Option(name: .customLong("id"), help: "异步任务的唯一标识")
    var taskId: String

    func run() throws {
        var option = FaceAlbumSearchImageTaskQueryOption(taskId: taskId)
        option.setup(self)
        try setup()
        semaRun { sema in
            FaceAlbum.searchImageTaskQuery(option: option) { err, resp in
                commonResponseHandler(sema, error: err, resp: resp)
            }
        }
    }
}

struct FppFaceAlbumAddTaskQueryCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "add",
        abstract: "通过该接口查询addimage后的结果"
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

    @Option(name: .customLong("id"), help: "异步任务的唯一标识")
    var taskId: String

    func run() throws {
        var option = FaceAlbumAddImageTaskQueryOption(taskId: taskId)
        option.setup(self)
        try setup()
        semaRun { sema in
            FaceAlbum.addImageTaskQuery(option: option) { err, resp in
                commonResponseHandler(sema, error: err, resp: resp)
            }
        }
    }
}

struct FppFaceAlbumGroupTaskQueryCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "group",
        abstract: "通过该接口查询groupface后的结果"
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

    @Option(name: .customLong("id"), help: "异步任务的唯一标识")
    var taskId: String

    func run() throws {
        var option = FaceAlbumGroupFaceTaskQueryOption(taskId: taskId)
        option.setup(self)
        try setup()
        semaRun { sema in
            FaceAlbum.groupFaceTaskQuery(option: option) { err, resp in
                commonResponseHandler(sema, error: err, resp: resp)
            }
        }
    }
}
