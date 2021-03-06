import Foundation
#if os(Linux)
import FoundationNetworking
#endif

@objc(FppClient)
public class FaceppClient: NSObject {
    let apiKey: String
    let apiSecret: String
    lazy var session: URLSession = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()
    @objc public static private(set) var shared: FaceppClient?
    var tasksMap = [URLSessionTask: RequestProtocol]()

    @objc public class func initialization(key: String, secret: String) {
        #if os(Linux)
        if shared == nil { // 原来的 Dispatch once 写法在Linux上无法通过编译，退化
            shared = FaceppClient(apikey: key, apiSecret: secret)
        }
        #else
        DispatchQueue.once(token: "com.daubert.facepp.init") {
            shared = FaceppClient(apikey: key, apiSecret: secret)
        }
        #endif
    }

    /// 最大并发请求数
    @objc public var maxRequestConut: Int {
        get {
            session.configuration.httpMaximumConnectionsPerHost
        }
        set {
            session.configuration.httpMaximumConnectionsPerHost = newValue
        }
    }

    private override init() {
        fatalError("不要调用原来的初始化")
    }

    private init(apikey key: String, apiSecret secret: String) {
        self.apiKey = key
        self.apiSecret = secret
        super.init()
    }
}

public enum Facepp: UseFaceppClientProtocol {
    public enum Face {
        case setUserId(option: FaceSetUserIdOption,
            completionHandler: (Error?, FaceSetUserIdResponse?) -> Void)
        case getDetail(option: FaceGetDetailOption,
            completionHandler: (Error?, FaceGetDetailResponse?) -> Void)
        case analyze(option: FaceAnalyzeOption,
            completionHandler: (Error?, FaceAnalyzeResponse?) -> Void)
    }

    case detect(option: FaceDetectOption,
        completionHandler: (Error?, FaceDetectResponse?) -> Void)
    case compare(option: CompareOption,
        completionHandler: (Error?, CompareResponse?) -> Void)
    case beautifyV1(option: BeautifyV1Option,
        completionHandler: (Error?, BeautifyResponse?) -> Void)
    case beautifyV2(option: BeautifyV2Option,
        completionHandler: (Error?, BeautifyResponse?) -> Void)
    case thousandLandmark(option: ThousandLandMarkOption,
        completionHandler: (Error?, ThousandLandmarkResponse?) -> Void)
    case facialFeatures(option: FacialFeaturesOption,
        completionHandler: (Error?, FacialFeaturesResponse?) -> Void)
    case threeDimensionFace(option: ThreeDimensionFaceOption,
        completionHandler: (Error?, ThreeDimensionFaceResponse?) -> Void)
    case skinAnalyze(option: SkinAnalyzeOption,
        completionHandler: (Error?, SkinAnalyzeResponse?) -> Void)
    case skinAnalyzeAdvanced(option: SkinAnalyzeAdvancedOption,
        completionHandler: (Error?, SkinAnalyzeAdvancedResponse?) -> Void)

    @discardableResult
    public func request() -> URLSessionTask? {
        switch self {
        case .detect(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .compare(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .beautifyV1(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .beautifyV2(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .thousandLandmark(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .facialFeatures(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .threeDimensionFace(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .skinAnalyze(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .skinAnalyzeAdvanced(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        }
    }
}

extension Facepp.Face: UseFaceppClientProtocol {
    @discardableResult
    public func request() -> URLSessionTask? {
        switch self {
        case .setUserId(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .getDetail(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        case .analyze(let option, let handler):
            return Self.parse(option: option, completionHandler: handler)
        }
    }
}

extension FaceppClient {

    static func getDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    @discardableResult
    func parse<R: FaceppResponseProtocol>(option: RequestProtocol,
                                          completionHandler: @escaping (Error?, R?) -> Void) -> URLSessionTask? {
        var request: URLRequest?
        var data: Data?
        do {
            (request, data) = try option.asRequest(apiKey: apiKey, apiSecret: apiSecret)
        } catch {
            completionHandler(error, nil)
            return nil
        }

        guard let req = request else {
            completionHandler(FaceppRequestError.argumentsError(.missingArguments), nil)
            return nil
        }

        let task = session.uploadTask(with: req, from: data) { data, _, error in
            guard error == nil, let data = data else {
                return completionHandler(error, nil)
            }
            do {
                let decoder = Self.getDecoder()
                let resp = try decoder.decode(R.self, from: data)
                if let msg = resp.errorMessage {
                    let text = """
                    请求ID：\(resp.requestId ?? "Unknown")
                    原因：\(msg)
                    耗时：\(TimeInterval(resp.timeUsed ?? 0) / 1000)s
                    """
                    completionHandler(FaceppRequestError.faceppError(reason: text), nil)
                } else {
                    completionHandler(error, resp)
                }
            } catch let err {
                completionHandler(FaceppRequestError.parseError(error: err, originalData: data), nil)
            }
        }
        tasksMap[task] = option
        task.resume()
        return task
    }
}

@objc(FppFaceppBaseRequest)
public class FaceppBaseRequest: NSObject, RequestProtocol {
    /// 超时时间
    @objc public var timeoutInterval: TimeInterval = 60
    /// 图片的URL
    @objc public var imageURL: URL?
    /**
     一个图片，二进制文件，需要用post multipart/form-data的方式上传。图像存储尺寸不能超过2MB，像素尺寸的长或宽都不能超过4096像素。
     
     如果同时传入了image_url和image_file参数，本API将使用image_file参数。
     */
    @objc public var imageFile: URL?
    /**
     base64编码的二进制图片数据
     
     如果同时传入了image_url、image_file和image_base64参数，本API使用顺序为image_file优先，image_url最低。
     */
    @objc public var imageBase64: String?

    /// 是否检查参数设置
    @objc public var needCheckParams: Bool = true

    @nonobjc public weak var metricsReporter: FaceppMetricsReporter?

    @objc public override init() {}

    @objc required public init(params: [String: Any]) {
        if let value = params["need_check_params"] as? Bool {
            needCheckParams = value
        } else {
            needCheckParams = true
        }
        if let value = params["timeout_interval"] as? TimeInterval {
            timeoutInterval = value
        } else {
            timeoutInterval = 60
        }
        if let value = params["image_url"] as? String {
            imageURL = URL(string: value)
        }
        if let url = params["image_file"] as? String {
            imageFile = URL(fileURLWithPath: url)
        }
        if let value = params["image_base64"] as? String {
            imageBase64 = value
        }
        super.init()
    }

    var requsetURL: URL? {
        return kFaceBaseURL
    }

    func paramsCheck() throws -> Bool {
        guard needCheckParams else {
            return true
        }
        if let url = imageFile, try !url.fileSizeNotExceed(mb: uploadFileMBSize) {
            throw FaceppRequestError.argumentsError(.fileTooLarge(size: uploadFileMBSize, path: url))
        }
        if let str = imageBase64,
            let count = Data(base64Encoded: str)?.count,
            Double(count) / 1024 / 1024 > uploadFileMBSize {
            throw FaceppRequestError.argumentsError(.invalidArguments(desc:
                "imageBase64大小不应超过\(uploadFileMBSize): \(count / 1024 / 1024)MB"))
        }
        return imageURL != nil || imageFile != nil || imageBase64 != nil
    }

    func params() throws -> (Params, [Params]?) {
        var params = Params()
        var files = [Params]()
        params["image_url"] = imageURL
        params["image_base64"] = imageBase64
        if let url = imageFile {
            let data = try Data(contentsOf: url)
            files.append([
                "fieldName": "image_file",
                "fileType": url.pathExtension,
                "data": data
            ])
        }
        return (params, files)
    }
}

@available(OSX 10.12, iOS 10.0, *)
public protocol FaceppMetricsReporter: class {
    #if !os(Linux)
    func option(_ option: FaceppRequestConfigProtocol, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics)
    #endif
}

#if !os(Linux)
@available(OSX 10.12, iOS 10.0, *)
public extension FaceppMetricsReporter {
    func option(_ option: FaceppRequestConfigProtocol,
                task: URLSessionTask,
                didFinishCollecting metrics: URLSessionTaskMetrics) {}
}
#endif

public protocol FaceppRequestConfigProtocol {
    var timeoutInterval: TimeInterval { get set }
    var needCheckParams: Bool { get set }
    var metricsReporter: FaceppMetricsReporter? { get set }
    init(params: [String: Any])
}

protocol RequestProtocol: FaceppRequestConfigProtocol {
    var requsetURL: URL? { get }
    var uploadFileMBSize: Double { get }
    func paramsCheck() throws -> Bool
    func params() throws -> (Params, [Params]?)
    func asRequest(apiKey: String, apiSecret: String) throws -> (URLRequest?, Data?)
}

extension RequestProtocol {
    var uploadFileMBSize: Double {
        return 2.0
    }

    func paramsCheck() throws -> Bool {
        guard needCheckParams else {
            return true
        }
        return true
    }
    func asRequest(apiKey: String, apiSecret: String) throws -> (URLRequest?, Data?) {
        guard let url = requsetURL, try paramsCheck() else {
            return (nil, nil)
        }
        var (params, files) = try self.params()
        params["api_key"] = apiKey
        params["api_secret"] = apiSecret
        var (request, bodyData) = URLRequest.postRequest(url: url, body: params, filesData: files ?? [])
        request?.timeoutInterval = timeoutInterval
        return (request, bodyData)
    }
}

@objc(FppCardppV1Requst)
public class CardppV1Requst: FaceppBaseRequest {
    override var requsetURL: URL? {
        return kCardppV1URL
    }
}

extension FaceppClient: URLSessionTaskDelegate {
    #if !os(Linux)
    @available(OSX 10.12, iOS 10.0, *)
    public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        guard let option = tasksMap.removeValue(forKey: task) else {
            return
        }
        option.metricsReporter?.option(option, task: task, didFinishCollecting: metrics)
    }
    #endif
}

protocol PropertyLoopable {
    func allProperties() throws -> [String: Any]
}

extension PropertyLoopable {
    func allProperties() throws -> [String: Any] {
        var result: [String: Any] = [:]
        let mirror = Mirror(reflecting: self)
        guard let style = mirror.displayStyle, style == .struct || style == .class else {
            //throw some error
            throw NSError(domain: "com.daubert.facepp.propertyLoop", code: -777, userInfo: nil)
        }
        for (labelMaybe, valueMaybe) in mirror.children {
            guard let label = labelMaybe else {
                continue
            }
            result[label] = valueMaybe
        }
        return result
    }
}

public protocol FppDataRequestProtocol: NSObjectProtocol {
    associatedtype ResponseType: FaceppResponseBaseProtocol
    func request(completionHandler: @escaping (Error?, ResponseType?) -> Void) -> URLSessionTask?
}
