//
//  FaceAlbum.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/10.
//

import Foundation
import ArgumentParser
import FaceppSwift

final class FppAFaceAlbumCreateCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "create",
        abstract: "创建一个人脸相册 FaceAlbum，用于存储相片的image_id、相片中人脸标识face_token、以及人脸标识对应的聚类分组group_id。一个FaceAlbum能够存储10000个face_token。",
        discussion: """
        注意：免费用户可最多创建10个FaceAlbum，而付费用户没有相册数量限制。
        免费用户的相册自创建后会保存100天，然后会被删除。如果付费用户透支账户余额后，创建的FaceAlbum会保留30天，然后被删除。
        """
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

    func run() throws {
        var option = CreateFaceAlbumOption()
        option.setup(self)
        try setup()
        semaRun { sema in
            var id: Int?
            id = FaceAlbum.create(option: option) { error, resp in
                commonResponseHandler(sema, taskID: id, error: error, resp: resp)
                }?.taskIdentifier
        }
    }
}

final class FppFaceAlbumDeleteCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "del",
        abstract: "删除 FaceAlbum，该相册对应的image_id, face_token，face_token对应的group_id也都会被删除"
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

    @Argument(help: "FaceAlbum 标识")
    var token: String

    @Flag(default: false,
          inversion: .prefixedEnableDisable,
          help: "删除时是否检查 FaceAlbum 中是否存在 face_token")
    var emptyCheck: Bool

    func run() throws {
        var option = FaceAlbumDeleteOption(facealbumToken: token)
        option.checkEmpty = emptyCheck
        option.setup(self)
        try setup()
        semaRun { sema in
            var id: Int?
            id = FaceAlbum.delete(option: option) { err, resp in
                commonResponseHandler(sema, taskID: id, error: err, resp: resp)
                }?.taskIdentifier
        }
    }
}

final class FppFaceAlbumFindCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "find",
        abstract: "查找与某一分组相似的分组，用于在同一个人的人脸被分为多个组的情况下，提示用户确认两个分组的人脸是否属于同一个人"
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

    @Option(help: "FaceAlbum 标识")
    var token: String

    @Option(name: .customLong("id"), help: "用以查找相似分组的人脸分组的标识GroupID 不能为 0 或者 -1")
    var groupId: String

    func run() throws {
        var option = FaceAlbumFindCandidateOption(token: token, groupId: groupId)
        option.setup(self)
        try setup()
        semaRun { sema in
            var id: Int?
            id = FaceAlbum.findCandidate(option: option) { err, resp in
                commonResponseHandler(sema, taskID: id, error: err, resp: resp)
                }?.taskIdentifier
        }
    }
}

final class FppFaceAlbumSearchCommand: FaceCLIBasicCommand {
    static var configuration = CommandConfiguration(
        commandName: "search",
        abstract: "调用者提供图片（可通过图片URL，File，base64三种方式），对图片中人脸进行检测和分析，然后根据图片中face_token搜索FaceAlbum里拥有该face的相片的image_id的集合",
        discussion: """
        注意：

        1）本接口旨在让用户能用一个人的图片来搜索已聚类相册里拥有该人的相片集，建议输入图片只有一个人脸。如果输入图片中多于5个人脸，最多随机返回5个人脸的搜索结果。
        2）此接口是基于相册聚类结果进行搜索，如果相册加入新face_token后没有调用groupface API, 仅在所有已聚类图片中进行搜索，正常返回结果。

        该接口为异步接口，聚类结果可通过 facepp album query search --id <task_id> 来查询。
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

    @Option(help: "FaceAlbum 标识")
    var token: String

    @Option(name: .customLong("cb"),
            help: """
一个URL。API任务完成后会调用该url，通知用户任务完成。
注：任务完成后，会向传入的 callback_url 发送一个 GET 请求，将 task_id 作为 querystring 中的 task_id 参数传递给用户，
例：http://cburl?task_id=xxxxxxx
""")
    var callback: String?

    func run() throws {
        var option = FaceAlbumSearchImageOption(facealbumToken: token)
        option.setup(self)
        try setup()
        if let url = callback {
            option.callbackURL = URL(string: url)
        }
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
        semaRun { sema in
            var id: Int?
            id = FaceAlbum.searchImage(option: option) { err, resp in
                commonResponseHandler(sema, taskID: id, error: err, resp: resp)
                }?.taskIdentifier
        }
    }
}

final class FppFaceAlbumUpdateCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "update",
        abstract: "更新指定 FaceAlbum 中某个或某些face_token 的分组信息"
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

    @Option(name: .customLong("id"),
            help: """
            人脸的新的分组信息。可以传入三类值：如果传入一个已经存在的 group_id，则人脸会被分到相应的组中。如果传入“CreateNewGroup”，则会为传入人脸创建一个新的分组，并返回新的 group_id。
            如果传入 -1，则人脸会被置为“未分组”状态
            """)
    var newGroupId: String

    @Argument(help: "由人脸标识 face_token 组成的字符串。至少传入一个 face_token，最多不超过10个，多个用逗号分隔")
    var faceTokens: [String]

    @Option(help: "FaceAlbum 标识")
    var token: String

    func run() throws {
        var option = FaceAlbumUpdateFaceOption(faceTokens: faceTokens,
                                               newGroupId: newGroupId,
                                               faceAlbumToken: token)
        option.setup(self)
        try setup()
        semaRun { sema in
            var id: Int?
            id = FaceAlbum.updateFace(option: option) { err, resp in
                commonResponseHandler(sema, taskID: id, error: err, resp: resp)
                }?.taskIdentifier
        }
    }
}

final class FppFaceAlbumAddFaceCommand: FaceCLIBasicCommand {
    static var configuration = CommandConfiguration(
        commandName: "add",
        abstract: """
        调用者提供图片（可通过图片URL，File，bae64三种方式），对图片中人脸进行检测和分析，然后将图片中face_token加入FaceAlubm中。
        """,
        discussion: """
        注意：
        1）加入 FaceAlbum 的人脸的分组信息 group_id 会置为 -1，代表未分组。
        2）同一个FaceAlbum最多存储10000个facetoken，如果需要更多，请联系face++商务。
        3）如需处理多于十张人脸的图片，建议使用添加图片（异步）API。

        异步接口适用于人数较多的图片。添加结果可通过 facepp album query add --id <task_id> 来查询。
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

    @Option(help: "FaceAlbum 标识")
    var token: String

    @Option(name: .customLong("cb"),
            help: """
    一个URL。API任务完成后会调用该url，通知用户任务完成。
    注：任务完成后，会向传入的 callback_url 发送一个 GET 请求，将 task_id 作为 querystring 中的 task_id 参数传递给用户，
    例：http://cburl?task_id=xxxxxxx
    """)
    var callback: String?

    @Flag(default: false, inversion: .prefixedEnableDisable, help: "是否异步")
    var async: Bool

    func run() throws {
        if async {
            try runAsync()
        } else {
            try runSync()
        }
    }

    func runSync() throws {
        var option = FaceAlbumAddImageOption(facealbumToken: token)
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
        semaRun { sema in
            var id: Int?
            id = FaceAlbum.addImage(option: option) { err, resp in
                commonResponseHandler(sema, taskID: id, error: err, resp: resp)
                }?.taskIdentifier
        }
    }

    func runAsync() throws {
        var option = FaceAlbumAddImageAsyncOption(facealbumToken: token)
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
        if let url = callback {
            option.callbackURL = URL(string: url)
        }
        semaRun { sema in
            var id: Int?
            id = FaceAlbum.addImageAsync(option: option) { err, resp in
                commonResponseHandler(sema, taskID: id, error: err, resp: resp)
                }?.taskIdentifier
        }
    }
}

final class FppFaceAlbumGetDetailCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "fdetail",
        abstract: "查看某个人脸的信息"
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

    @Option(help: "FaceAlbum 标识")
    var token: String

    @Option(help: "人脸标识face_token字符串")
    var face: String

    func run() throws {
        var option = FaceAblbumGetFaceDetailOption(faceAlbumToken: token,
                                                   faceToken: face)
        option.setup(self)
        try setup()
        semaRun { sema in
            var id: Int?
            id = FaceAlbum.getFaceDetail(option: option) { err, resp in
                commonResponseHandler(sema, taskID: id, error: err, resp: resp)
                }?.taskIdentifier
        }
    }
}

final class FppGetImageDetailCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "idetail",
        abstract: "查看某个图片的信息"
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

    @Option(help: "FaceAlbum 标识")
    var token: String

    @Option(name: .customLong("id"), help: "要查看图片在系统中的标识")
    var imageId: String

    func run() throws {
        var option = FaceAlbumGetImageDetailOption(faceAlbumToken: token,
                                                   imageId: imageId)
        option.setup(self)
        try setup()
        semaRun { sema in
            var id: Int?
            id = FaceAlbum.getImageDetail(option: option) { err, resp in
                commonResponseHandler(sema, taskID: id, error: err, resp: resp)
                }?.taskIdentifier
        }
    }
}

final class FppGetAllFaceAlbumFCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "all",
        abstract: """
        获取某一 API Key 下的 FaceAlbum 列表及其 facealbum_token信息。
        单次查询最多返回 100 个 FaceAlbum。如需获取全量数据，需要配合使用 start 和 next 参数。
        """
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

    @Option(default: 1, help: """
    一个数字 n，表示开始返回的 faceset_token 在传入的 API Key 下的序号。 n 是 [1,9999999] 间的一个整数。
    通过传入数字 n，可以控制本 API 从第 n 个 faceset_token 开始返回。返回的 faceset_token 按照创建时间排序，每次返回 100 个 faceset_token。
    默认值为 1。
    您可以输入之前请求本 API 返回的 next 值，用以获得接下来的 100 个 faceset_token。
    """)
    var start: Int

    func run() throws {
        var option = FaceAblumGetAllOption(start: start)
        option.setup(self)
        try setup()
        semaRun { sema in
            var id: Int?
            id = FaceAlbum.getAll(option: option) { err, resp in
                commonResponseHandler(sema, taskID: id, error: err, resp: resp)
                }?.taskIdentifier
        }
    }
}

final class FppFaceAlbumGetdetailCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "detail",
        abstract: "查看获取 FaceAlbum 详情"
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

    @Option(help: "FaceAlbum 标识")
    var token: String

    @Option(name: .customLong("startToken"),
            help: "之前请求本 API 返回的 next_token 标识，用来获取下100个 face_token。默认值为空，返回 FaceAlbum 下前100个 face_token")
    var startToken: String?

    func run() throws {
        var option = FaceAlbumGetAlbumDetailOption(facealbumToken: token)
        option.setup(self)
        try setup()
        semaRun { sema in
            var id: Int?
            id = FaceAlbum.getAlbumDetail(option: option) { err, resp in
                commonResponseHandler(sema, taskID: id, error: err, resp: resp)
                }?.taskIdentifier
        }
    }
}

final class FppFaceAlbumRemoveFaceCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "rmf",
        abstract: "移除FaceAlbum的某些或全部人脸",
        discussion: """
        注意：当把一个face_token（或image_id）从FaceAlbum里移除后，该face_token（或image_id）就无法被查看接口所查到。
        当一个image_id所属的所有face_token从FaceAlbum里移除后，该image_id也被移除了。
        """
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

    @Option(help: "FaceAlbum 标识")
    var token: String

    @Option(name: .customLong("faceTokens"), help: "需要移除的人脸标识字符串，至少传入一个 face_token，最多不超过10个，多个用逗号分隔")
    var faceTokens: String?

    @Option(name: .customLong("id"), help: "需要移除的一个图片id字符串，删除该image_id拥有的所有face_token")
    var imageId: String?

    func run() throws {
        var option = FaceAlbumDeleteFaceOption(facealbumToken: token)
        option.faceTokens = faceTokens?.components(separatedBy: ",")
        option.imageId = imageId
        option.setup(self)
        try setup()
        semaRun { sema in
            var id: Int?
            id = FaceAlbum.deleteFace(option: option) { err, resp in
                commonResponseHandler(sema, taskID: id, error: err, resp: resp)
                }?.taskIdentifier
        }
    }
}

extension FaceAlbumGroupFaceOption.OperationType: ExpressibleByArgument, Decodable {}

final class FppFaceAlbumGroupFaceCommand: FaceCLIBaseCommand {
    static var configuration = CommandConfiguration(
        commandName: "group",
        abstract: "对FaceAlbum中的人脸进行全量或者增量的分组操作。分组之后每一个face_token会带有一个group_id",
        discussion: """
        当一个人脸未与任何人脸组成一个分组时，group_id=0 。增量表示只对group_id=-1和group_id=0的face_token进行分组，已经在某个分组内的人脸（group_id>0）结果将保持不变。

        该接口为异步接口，聚类结果可通过facepp album query group --id <task_id> 来查询。
        该接口的执行时间与要聚类的face_token数量有关系，请参考下表来确定查询接口的等待时间。
        """
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

    @Option(help: "FaceAlbum 标识")
    var token: String

    @Option(name: .customLong("cb"), help: """
    一个URL。API任务完成后会调用该url，通知用户任务完成。
    注：任务完成后，会向传入的 callback_url 发送一个 GET 请求，将 task_id 作为 querystring 中的 task_id 参数传递给用户，
    例：http://cburl?task_id=xxxxxxx
    """)
    var callbackURL: String?

    @Option(default: .incremental, help: "人脸分组操作类型")
    var type: FaceAlbumGroupFaceOption.OperationType

    func run() throws {
        var option = FaceAlbumGroupFaceOption(facealbumToken: token)
        if let url = callbackURL {
            option.callbackURL = URL(string: url)
        }
        option.setup(self)
        try setup()
        semaRun { sema in
            var id: Int?
            id = FaceAlbum.groupFace(option: option) { err, resp in
                commonResponseHandler(sema, taskID: id, error: err, resp: resp)
                }?.taskIdentifier
        }
    }
}
