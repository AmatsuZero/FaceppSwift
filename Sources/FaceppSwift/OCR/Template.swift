//
//  Template.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/2/11.
//

import Foundation

public class OCRTemplateOption: CardppV1Requst {
    /// 指定的模板ID（模版ID在创建模板后由系统自动生成）
    public var templateId: String
    /**
     表示需要返回的额外信息。当前只支持extra_info=position，表示返回识别域的位置信息（识别域四个点坐标）
     */
    public var extraInfo: [String]?

    public init(templateId: String) {
        self.templateId = templateId
        super.init()
    }

    override var requsetURL: URL? {
        return super.requsetURL?.appendingPathComponent("templateocr")
    }

    override func params(apiKey: String, apiSecret: String) -> (Params, [Params]?) {
        var (params, files) = super.params(apiKey: apiKey, apiSecret: apiSecret)
        params["template_id"] = templateId
        params["extra_info"] = extraInfo?.joined(separator: ",")
        return (params, files)
    }
}

public struct OCRTemplateResponse: ResponseProtocol {
    public var requestId: String?
    public var errorMessage: String?
    public var timeUsed: Int?

    public struct Value: Codable {
        /// 创建模板时定义的识别域名
        public let text: String
        /**
         识别结果。包括一个text字段，说明如下：

         text：表示识别的结果，以列表格式返回，每个元素表示一行的识别结果。
         position：当请求的extra_info为position时，返回识别域四个点的坐标。以列表格式返回，每个元素表示一个点的坐标[x,y]
         */
        public let position: [FaceppPoint]?
    }

    public struct Result: Codable {
        public let key: String
        public let value: Value
    }
    /**
     被检测出的文字信息，由一个或多个data对象组成。

     注：如果没有检测出文字则为空
     */
    public let result: [Result]?
}
