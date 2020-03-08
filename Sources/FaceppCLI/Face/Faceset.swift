//
//  Faceset.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/8.
//

import Foundation
import FaceppSwift
import ArgumentParser

struct FppCreateFacesetCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "create",
        abstract: "创建一个人脸的集合 FaceSet，用于存储人脸标识 face_token。一个 FaceSet 能够存储10000个 face_token。",
        discussion: "试用API Key可以创建1000个FaceSet，正式API Key可以创建10000个FaceSet。"
    )
    @Flag(default: true, inversion: .prefixedEnableDisable, help: "检查参数")
    var checkParams: Bool
    
    @Flag(default: false, inversion: .prefixedEnableDisable, help: "请求报告，macOS only")
    var metrics: Bool
    
    @Option(name:[.customShort("T"), .long], default: 60, help: "超时时间，默认60s")
    var timeout: TimeInterval
    
    @Option(name: .customLong("key"), help: "调用此API的API Key")
    var apiKey: String?
    
    @Option(name: .customLong("secret"), help: "调用此API的API Secret")
    var apiSecret: String?
    
    @Option(name: .customLong("name"), help: "人脸集合的名字，最长256个字符，不能包括字符^@,&=*'\"")
    var displayName: String?
    
    @Option(name: .customLong("id"), help: "账号下全局唯一的 FaceSet 自定义标识，可以用来管理 FaceSet 对象。最长255个字符，不能包括字符^@,&=*'\"")
    var outerId: String?
    
    @Option(help: "FaceSet 自定义标签组成的字符串，用来对 FaceSet 分组。最长255个字符，多个 tag 用逗号分隔，每个 tag 不能包括字符^@,&=*'\"")
    var tags: String?
    
    @Option(name: .customLong("tokens"), help: "人脸标识 face_token，可以是一个或者多个，用逗号分隔。最多不超过5个 face_token")
    var faceTokens: String?
    
    @Option(name: .customLong("data"), help: "自定义用户信息，不大于16 KB，不能包括字符^@,&=*'\"")
    var userData: String?
    
    @Flag(name: .customLong("force"), default: false, inversion: .prefixedEnableDisable,
          help: "在传入 outer_id 的情况下，如果 outer_id 已经存在，是否将 face_token 加入已经存在的 FaceSet 中")
    var forceMerge: Bool
    
    func run() throws {
        var option = FaceSetCreateOption()
        option.setup(self)
        try setup()
        option.forceMerge = forceMerge ? 1 : 0
        option.displayName = displayName
        option.outerId = outerId
        option.tags = tags?.components(separatedBy: ",")
        option.faceTokens = faceTokens?.components(separatedBy: ",")
        option.userData = userData
        
        semaRun { sema in
            FaceSet.create(option: option) { error, resp in
                commonResponseHandler(sema, error: error, resp: resp)
            }
        }
    }
}

struct FppFacesetGetAllCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "sets",
        abstract: "获取某一 API Key 下的 FaceSet 列表及其 faceset_token、outer_id、display_name 和 tags 等信息",
        discussion: ""
    )
    @Flag(default: false, inversion: .prefixedEnableDisable, help: "检查参数")
    var checkParams: Bool
    
    @Flag(default: false, inversion: .prefixedEnableDisable, help: "请求报告，macOS only")
    var metrics: Bool
    
    @Option(name:[.customShort("T"), .long], default: 60, help: "超时时间，默认60s")
    var timeout: TimeInterval
    
    @Option(name: .customLong("key"), help: "调用此API的API Key")
    var apiKey: String?
    
    @Option(name: .customLong("secret"), help: "调用此API的API Secret")
    var apiSecret: String?
    
    @Option(help: "FaceSet 自定义标签组成的字符串，用来对 FaceSet 分组。最长255个字符，多个 tag 用逗号分隔，每个 tag 不能包括字符^@,&=*'\"")
    var tags: String?
    
    @Option(default: 1, help: "一个数字 n，表示开始返回的 faceset_token 在传入的 API Key 下的序号")
    var start: Int
    
    func run() throws {
        var option = FaceSetGetOption(tags: tags?.components(separatedBy: ","))
        option.setup(self)
        try setup()
        option.start = start
        
        semaRun { sema in
            FaceSet.getFaceSets(option: option) { err, resp in
                commonResponseHandler(sema, error: err, resp: resp)
            }
        }
    }
}

struct FppFacesetDetailCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "detail",
        abstract: """
        获取一个 FaceSet 的所有信息，包括此 FaceSet 的 faceset_token, outer_id, display_name 的信息，以及此 FaceSet 中存放的 face_token 数量与列表。
        """,
        discussion: """
        注意：2017年8月16日后，调用本接口将不会一次性返回全部的 face_token 列表。
        单次查询最多返回 100 个 face_token。如需获取全量数据，需要配合使用 start 和 next 参数。请尽快修改调整您的程序。
        """
    )
    
    @Flag(default: false, inversion: .prefixedEnableDisable, help: "检查参数")
    var checkParams: Bool
    
    @Flag(default: false, inversion: .prefixedEnableDisable, help: "请求报告，macOS only")
    var metrics: Bool
    
    @Option(name:[.customShort("T"), .long], default: 60, help: "超时时间，默认60s")
    var timeout: TimeInterval
    
    @Option(name: .customLong("key"), help: "调用此API的API Key")
    var apiKey: String?
    
    @Option(name: .customLong("secret"), help: "调用此API的API Secret")
    var apiSecret: String?
    
    @Option(name: .customLong("id"), help: "账号下全局唯一的 FaceSet 自定义标识，可以用来管理 FaceSet 对象。最长255个字符，不能包括字符^@,&=*'\"")
    var outerId: String?
    
    @Option(default: 1, help: "一个数字 n，表示开始返回的 faceset_token 在传入的 API Key 下的序号")
    var start: Int
    
    @Option(name: .customLong("token"), help: "FaceSet的标识")
    var facesetToken: String?
    
    func run() throws {
        var option = FacesetGetDetailOption(facesetToken: facesetToken, outerId: outerId)
        option.setup(self)
        try setup()
        option.start = start
        
        semaRun { sema in
            FaceSet.detail(option: option) { err, resp in
                commonResponseHandler(sema, error: err, resp: resp)
            }
        }
    }
}
