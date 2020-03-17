import WebKit

struct FppHandlerRuntimeError: Error, CustomStringConvertible {
    var description: String
    init(_ desc: String) {
        description = desc
    }
}

public class FaceppBeautifySchemeHandler: NSObject {
    /**
     拦截的scheme，如果需要处理的资源是全路径，host部分以“[本来的scheme]^[host]”标记
     例：
        fppbeautify://file^folder/picture.jpg
        fppbeautify://http^dummy/pic.jpg
     如果不设置host，则以当前 WebView 的地址作为 baseURL 进行拼接处理
     */
    public static let scheme = "fppbeautify"
    
    /// 资源如果是本地的话，传入要访问的资源文件夹路径，入股不传入，以当前WebView的上一级路径当作相对路径
    public var resourceDirURL: URL?
    
    public private(set) var tasks = [URLRequest: URLSessionTask]()
    
    deinit {
        tasks.values.forEach { $0.cancel() }
        tasks.removeAll()
    }
}

extension FaceppBeautifySchemeHandler: WKURLSchemeHandler {
    public func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let components = urlSchemeTask.request.url?
            .customURL(webviewURL: webView.url, resourceDir: resourceDirURL)  else {
                urlSchemeTask.didFailWithError(FppHandlerRuntimeError("Not Support"))
                return
        }
        // 取出参数
        let params = components.params
        // 创建Option
        let option = BeautifyV2Option()
        if components.picURL?.scheme == "file" {
            option.imageFile = components.picURL
        } else {
            option.imageURL = components.picURL
        }
        if let filter = params["filter_type"] {
            option.filterType = BeautifyV2Option.FilterType(rawValue: filter)
        }
        if let value = params["enlarge_eye"]?.uintValue {
            option.enlargeEye = value
        }
        if let value = params["whitening"]?.uintValue {
            option.whitening = value
        }
        if let value = params["smoothing"]?.uintValue {
            option.smoothing = value
        }
        if let value = params["shrink_face"]?.uintValue {
            option.shrinkFace = value
        }
        if let value = params["thin_face"]?.uintValue {
            option.thinface = value
        }
        if let value = params["remove_eye_brow"]?.uintValue {
            option.removeEyebrow = value
        }
        let task = Facepp.beautifyV2(option: option) { [weak self] error, resp in
            self?.handleResponse(task: urlSchemeTask, error: error, response: resp)
        }.request()
        tasks[urlSchemeTask.request] = task
    }
    
    public func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        tasks[urlSchemeTask.request]?.cancel()
        tasks.removeValue(forKey: urlSchemeTask.request)
    }
    
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
}

extension URL {
    func customURL(webviewURL: URL?, resourceDir: URL?) -> (picURL:URL?, params: [String: String])? {
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
                url = URL(fileURLWithPath: path, relativeTo: resourceDir ??  webviewURL?.deletingLastPathComponent())
            } else {
                url = URL(string: path, relativeTo: URL(string: "/", relativeTo: webviewURL)?.absoluteURL)
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

