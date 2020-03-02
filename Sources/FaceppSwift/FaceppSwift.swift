import Foundation

public class FaceppClient: NSObject {
    private let apiKey: String
    private let apiSecret: String
    private lazy var session: URLSession = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()
    static private(set) var shared: FaceppClient?
    private var tasksMap = [URLSessionTask: RequestProtocol]()

    public class func initialization(key: String, secret: String) {
        DispatchQueue.once(token: "com.daubert.faceapp.init") {
            shared = FaceppClient(apikey: key, apiSecret: secret)
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
        completionHandler:  (Error?, FacialFeaturesResponse?) -> Void)
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

public class FaceppBaseRequest: RequestProtocol {
    /// 超时时间
    public var timeoutInterval: TimeInterval = 60
    /// 图片的URL
    public var imageURL: URL?
    /**
     一个图片，二进制文件，需要用post multipart/form-data的方式上传。图像存储尺寸不能超过2MB，像素尺寸的长或宽都不能超过4096像素。
     
     如果同时传入了image_url和image_file参数，本API将使用image_file参数。
     */
    public var imageFile: URL?
    /**
     base64编码的二进制图片数据
     
     如果同时传入了image_url、image_file和image_base64参数，本API使用顺序为image_file优先，image_url最低。
     */
    public var imageBase64: String?

    /// 是否检查参数设置
    public var needCheckParams: Bool = true

    public weak var metricsReporter: FaceppMetricsReporter?

    public init() {}

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

public protocol FaceppMetricsReporter: class {
    @available(OSX 10.12, iOS 10.0, *)
    func option(_ option: FaceppRequestConfigProtocol, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics)
}

public extension FaceppMetricsReporter {
    @available(OSX 10.12, iOS 10.0, *)
    func option(_ option: FaceppRequestConfigProtocol,
                task: URLSessionTask,
                didFinishCollecting metrics: URLSessionTaskMetrics) {}
}

public protocol FaceppRequestConfigProtocol {
    var timeoutInterval: TimeInterval { get set }
    var needCheckParams: Bool { get set }
    var metricsReporter: FaceppMetricsReporter? { get set }
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

public class CardppV1Requst: FaceppBaseRequest {
    override var requsetURL: URL? {
        return kCardppV1URL
    }
}

extension FaceppClient: URLSessionTaskDelegate {
    @available(OSX 10.12, iOS 10.0, *)
    public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        guard let option = tasksMap.removeValue(forKey: task) else {
            return
        }
        option.metricsReporter?.option(option, task: task, didFinishCollecting: metrics)
    }
}
