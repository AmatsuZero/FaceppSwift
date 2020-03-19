import WebKit

struct FppHandlerRuntimeError: Error, CustomStringConvertible {
    var description: String
    init(_ desc: String) {
        description = desc
    }
}

@available(iOS 11.0, *)
@objc public protocol FaceppSchemeHandlerDelegate: class, NSObjectProtocol {
    @objc optional func schemeHandler(_ handler: FaceppBaseSchemeHandler,
                                      loadRemoteImage url: URL,
                                      completionHandler: @escaping (Error?, UIImage?) -> Void)
}

/**
 自定义 scheme 拦截器，如果需要处理的资源是全路径，host部分以“[本来的scheme]^[host]”标记
 # 例子：
 `fppobj://file^folder/picture.jpg`
 
 `fppobj://http^foo/bar.jpg`
 
 如果不设置 host，则以当前 WebView 的地址作为 baseURL 进行拼接处理
 */
@available(iOS 11.0, *)
public class FaceppBaseSchemeHandler: NSObject, WKURLSchemeHandler {
    /// 资源如果是本地的话，传入要访问的资源文件夹路径，入股不传入，以当前WebView的上一级路径当作相对路径
    public var resourceDirURL: URL?

    var tasks = [URLRequest: URLSessionTask]()

    public weak var delegate: FaceppSchemeHandlerDelegate?

    public func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {

    }

    public func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        tasks[urlSchemeTask.request]?.cancel()
        tasks.removeValue(forKey: urlSchemeTask.request)
    }

    func extraOriginalImage(url: URL, completionHandler:@escaping (Error?, UIImage?) -> Void) {
        var image: UIImage?
        if url.scheme == "file" {
            image = UIImage(contentsOfFile: url.path)
            completionHandler(nil, image)
        } else {
            if delegate?
                .responds(to:
                    #selector(FaceppSchemeHandlerDelegate.schemeHandler(_:loadRemoteImage:completionHandler:))) == true {
                delegate?.schemeHandler?(self, loadRemoteImage: url, completionHandler: completionHandler)
                return
            }
            let req = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: req) { [weak self] data, _, error in
                guard let data = data else {
                    completionHandler(error, nil)
                    return
                }
                self?.tasks.removeValue(forKey: req)
                completionHandler(nil, UIImage(data: data))
            }
            tasks[req] = task
            task.resume()
        }
    }

    deinit {
        tasks.values.forEach { $0.cancel() }
        tasks.removeAll()
    }
}

/// 美颜拦截器
@available(iOS 11.0, *)
public class FaceppBeautifySchemeHandler: FaceppBaseSchemeHandler {
    public override func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let (picURL, params) = urlSchemeTask.request.url?
            .customURL(webviewURL: webView.url, resourceDir: resourceDirURL)  else {
                urlSchemeTask.didFailWithError(FppHandlerRuntimeError("Not Support"))
                return
        }
        // 创建Option
        let option = BeautifyV2Option(picURL: picURL, params: params)
        let task = Facepp.beautifyV2(option: option) { [weak self] error, resp in
            self?.handleResponse(task: urlSchemeTask, error: error, response: resp)
        }.request()
        tasks[urlSchemeTask.request] = task
    }
}

@available(iOS 11.0, *)
extension FaceppBeautifySchemeHandler {
    func handleResponse(task: WKURLSchemeTask, error: Error?, response: BeautifyResponse?) {
        defer {
            tasks.removeValue(forKey: task.request)
        }
        guard let str = response?.result,
            let data = Data(base64Encoded: str) else {
                task.didFailWithError(error ?? FppHandlerRuntimeError("未知错误"))
                return
        }
        let response = URLResponse(url: task.request.url!,
                                   mimeType: "image/jpeg",
                                   expectedContentLength: data.count,
                                   textEncodingName: nil)
        task.didReceive(response)
        task.didReceive(data)
        task.didFinish()
    }
}

extension String {
    var uintValue: UInt? {
        return UInt(self)
    }

    var integerValue: Int? {
        return Int(self)
    }
}

extension URL {
    func customURL(webviewURL: URL?, resourceDir: URL?) -> (picURL: URL?, params: [String: String])? {
        guard var components = URLComponents(string: absoluteString) else {
            return nil
        }

        // 取出参数
        var params = [String: String]()
        components.queryItems?.forEach { params[$0.name] = $0.value }
        components.query = nil

        // 拼接图片URL
        let parts: [String]? = components.host?.contains("^") == true
            ? components.host?.components(separatedBy: "^")
            : nil
        if let host = parts?.first {// 绝对路径
            components.scheme = host
            components.host = parts?.last
        } else {// 相对路径，根据当前WebView的地址设置
            var path = components.host ?? "/"
            path += components.path
            var url: URL?
            if webviewURL?.scheme == "file" {
                var isDir = ObjCBool(false)
                guard FileManager.default.fileExists(atPath: webviewURL!.path, isDirectory: &isDir) else {
                    return (nil, params)
                }
                let relativeURL = isDir.boolValue ? webviewURL : webviewURL?.deletingLastPathComponent()
                url = URL(fileURLWithPath: path, relativeTo: resourceDir ?? relativeURL)
            } else {
                let relativeURL = webviewURL?.pathExtension.isEmpty == true
                    ? webviewURL
                    : webviewURL?.deletingLastPathComponent()
                url = URL(string: path, relativeTo: relativeURL)
            }
            return (url?.absoluteURL, params)
        }

        var path = components.host ?? "/"
        path += components.path
        if components.scheme == "file" {
            let picUrl = URL(fileURLWithPath: path,
                             relativeTo: resourceDir ??  webviewURL?.deletingLastPathComponent())
            return (picUrl, params)
        }
        return (components.url, params)
    }
}

extension FaceppBaseRequest {
    convenience init(picURL: URL?) {
        self.init()
        if picURL?.scheme == "file" {
            imageFile = picURL
        } else {
            imageURL = picURL
        }
    }
}

extension BeautifyV2Option {
    convenience init(picURL: URL?, params: [String: String]) {
        self.init(picURL: picURL)
        if let filter = params["filter_type"] {
            filterType = BeautifyV2Option.FilterType(rawValue: filter)
        }
        if let value = params["enlarge_eye"]?.uintValue {
            enlargeEye = value
        }
        if let value = params["whitening"]?.uintValue {
            whitening = value
        }
        if let value = params["smoothing"]?.uintValue {
            smoothing = value
        }
        if let value = params["shrink_face"]?.uintValue {
            shrinkFace = value
        }
        if let value = params["thin_face"]?.uintValue {
            thinface = value
        }
        if let value = params["remove_eye_brow"]?.uintValue {
            removeEyebrow = value
        }
    }
}

@available(iOS 11.0, *)
extension WKURLSchemeTask {
    func complete(with newImage: UIImage) {
        guard let data = newImage.imageData() else {
            didFailWithError(FppHandlerRuntimeError("转换图片失败"))
            return
        }
        let response = URLResponse(url: request.url!,
                                   mimeType: "image/jpeg",
                                   expectedContentLength: data.count,
                                   textEncodingName: nil)
        didReceive(response)
        didReceive(data)
        didFinish()
    }
}
