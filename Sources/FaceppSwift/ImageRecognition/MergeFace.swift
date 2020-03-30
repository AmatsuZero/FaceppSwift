//
//  MergeFace.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/14.
//

import Foundation

@objc(FppMergeFaceOption)
@objcMembers public final class ImageppMergeFaceOption: NSObject, RequestProtocol {
    public var needCheckParams: Bool = true
    /// 超时时间
    public var timeoutInterval: TimeInterval = 60
    /**
     用于人脸融合的模板图
     如果未传入 template_rectangle 参数，则会取此图片中人脸框面积最大的人脸用以融合。
     请注意，此时图片中必须有人脸。
     如果传入了 template_rectangle 参数，则会取 template_rectangle 所标识的区域中的人脸。
     */
    /// 模板图图片的 URL。
    public var templateURL: URL?
    /// 模板图图片的二进制文件，需要用 post multipart/form-data 的方式上传。
    public var templateFile: URL?
    /// 模板图图片的 Base64 编码二进制文件。
    public var templateBase64: String?
    /// 指定模板图中进行人脸融合的人脸框位置。
    public var templateRectangle: FaceppRectangle?
    /**
     用于人脸融合的融合图
     如果未传入 merge_rectangle 参数，则会取此图片中人脸框面积最大的人脸用以融合。
     请注意，此时图片中必须有人脸。
     如果传入了 merge_rectangle 参数，则会取 merge_rectangle 所标识的区域中的人脸。
     */
    /// 融合图的图片URL。
    public var mergeURL: URL?
    /// 融合图的二进制文件，需要用 post multipart/form-data 的方式上传。
    public var mergeFile: URL?
    /// 融合图的 Base64 编码二进制文件。
    public var mergeBase64: String?
    /// 指定融合图中用以融合的人脸框位置。
    public var mergeRectangle: FaceppRectangle?
    /**
     融合比例，范围 [0,100]。
     数字越大融合结果包含越多融合图 (merge_url, merge_file, merge_base64 代表图片) 特征。
     默认值为50
     */
    public var mergeRate: UInt = 50
    /**
     五官融合比例，范围 [0,100]。
     主要调节融合结果图中人像五官相对位置，数字越小融合图 (merge_url, merge_file, merge_base64 代表图片)中人像五官相对更集中 。
     默认值为45
     */
    public var featureRate: UInt = 45

    public weak var metricsReporter: FaceppMetricsReporter?

    public override init() {
        super.init()
    }

    public init(params: [String: Any]) {
        if let value = params["need_check_params"] as? Bool {
            needCheckParams = value
        }
        if let value = params["timeout_interval"] as? TimeInterval {
            timeoutInterval = value
        }
        if let url = params["template_url"] as? String {
            templateURL = URL(string: url)
        }
        if let url = params["template_file"] as? String {
            templateFile = URL(fileURLWithPath: url)
        }
        if let value = params["template_base64"] as? String {
            templateBase64 = value
        }
        if let value = params["template_rectangle"] as? String {
            templateRectangle = FaceppRectangle(string: value)
        }
        if let value = params["merge_url"] as? String {
            mergeURL = URL(string: value)
        }
        if let value = params["merge_file"] as? String {
            mergeFile = URL(fileURLWithPath: value)
        }
        if let value = params["merge_base64"] as? String {
            mergeBase64 = value
        }
        if let value = params["merge_rectangle"] as? String {
            mergeRectangle = FaceppRectangle(string: value)
        }
        if let value = params["merge_rate"] as? UInt {
            mergeRate = value
        }
        if let value = params["feature_rate"] as? UInt {
            featureRate = value
        }
        super.init()
    }

    public var requsetURL: URL? {
        return kImageppV1URL?.appendingPathComponent("mergeface")
    }

    func paramsCheck() throws -> Bool {
        guard needCheckParams else {
            return true
        }
        guard mergeRate <= 100 else {
            throw FaceppRequestError.argumentsError(.invalidArguments(desc: "mergeRate输入需要在[0, 100]: \(mergeRate)"))
        }
        guard featureRate <= 100 else {
            throw FaceppRequestError.argumentsError(.invalidArguments(desc: "featureRate输入需要在[0, 100]: \(featureRate)"))
        }
        if let url = templateFile, try !url.fileSizeNotExceed(mb: uploadFileMBSize) {
            throw FaceppRequestError.argumentsError(.fileTooLarge(size: uploadFileMBSize, path: url))
        }
        if let url = templateFile, try !url.fileSizeNotExceed(mb: uploadFileMBSize) {
            throw FaceppRequestError.argumentsError(.fileTooLarge(size: uploadFileMBSize, path: url))
        }
        if let str = templateBase64,
            let count = Data(base64Encoded: str)?.count,
            Double(count) / 1024 / 1024 > uploadFileMBSize {
            throw FaceppRequestError.argumentsError(.invalidArguments(desc:
                "templateBase64大小不应超过\(uploadFileMBSize): \(count / 1024 / 1024)MB"))
        }
        if let str = mergeBase64,
            let count = Data(base64Encoded: str)?.count,
            Double(count) / 1024 / 1024 > uploadFileMBSize {
            throw FaceppRequestError.argumentsError(.invalidArguments(desc:
                "mergeBase64大小不应超过\(uploadFileMBSize): \(count / 1024 / 1024)MB"))
        }
        return (templateURL != nil || templateFile != nil || templateBase64 != nil)
            || (mergeURL != nil || mergeBase64 != nil || mergeFile != nil)
    }

    func params() throws -> (Params, [Params]?) {
        var params = Params()
        var files = [Params]()
        params["template_url"] = templateURL
        params["template_base64"] = templateBase64
        if let url = templateFile {
            let data = try Data(contentsOf: url)
            files.append([
                "fieldName": "template_file",
                "fileType": url.pathExtension,
                "data": data
            ])
        }
        params["merge_url"] = mergeURL
        params["merge_base64"] = mergeBase64
        if let url = mergeFile {
            let data = try Data(contentsOf: url)
            files.append([
                "fieldName": "merge_file",
                "fileType": url.pathExtension,
                "data": data
            ])
        }
        if let rectangle = mergeRectangle {
            params["merge_rectangle"] = "\(rectangle)"
        }
        params["merge_rate"] = mergeRate
        params["feature_rate"] = featureRate
        return (params, files)
    }
}

public struct ImageppMergeFaceResponse: FaceppResponseProtocol {
    /// 用于区分每一次请求的唯一的字符串
    public var requestId: String?
    /// 当发生错误时才返回。
    public var errorMessage: String?
    /// 整个请求所花费的时间，单位为毫秒
    public var timeUsed: Int?
    /// 融合后的图片，jpg 格式。base64 编码的二进制图片数据。图片尺寸大小与模板图一致。
    public let result: String?
}
