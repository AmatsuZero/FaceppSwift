import Foundation

public class Facepp {
    
    let apiKey: String
    let apiSecret: String
    let session = URLSession(configuration: .default)
    
    public static private(set) var shared: Facepp?
    
    public class func Initialization(key: String, secret: String) {
        DispatchQueue.once(token: "com.daubert.faceapp.init") {
            shared = Facepp(apikey: key, apiSecret: secret)
        }
    }
    
    private init() {
        fatalError("不要调用原来的初始化")
    }
    
    init(apikey key: String, apiSecret secret: String) {
        self.apiKey = key
        self.apiSecret = secret
    }
    
    public func detect(option: DetectOption, completionHanlder: @escaping (Error?, DetectResponse?) -> Void) {
        parse(option: option, completionHanlder: completionHanlder)
    }
    
    public func compare(option: CompareOption, completionHanlder: @escaping (Error?, CompareResponse?) -> Void) {
        parse(option: option, completionHanlder: completionHanlder)
    }
    
    public func beautify(option: BeautifyOption, completionHanlder: @escaping (Error?, BeautifyResponse?) -> Void) {
        parse(option: option, completionHanlder: completionHanlder)
    }
    
    public func thousandLandmark(option: ThousandLandMarkOption, completionHanlder: @escaping (Error?, ThousandLandmarkResponse?) -> Void) {
        parse(option: option, completionHanlder: completionHanlder)
    }
    
    public func facialFeatures(option: FacialFeaturesOption, completionHandler:  @escaping (Error?, FacialFeaturesResponse?) -> Void) {
        parse(option: option, completionHanlder: completionHandler)
    }
    
    public func threeDimensionFace(option: ThreeDimensionFaceOption, completionHandler: @escaping (Error?, ThreeDimensionFaceResponse?) -> Void) {
        parse(option: option, completionHanlder: completionHandler)
    }
    
    public func skinanalyze(option: SkinAnalyzeOption, completionHandler: @escaping (Error?, SkinAnalyzeResponse?) -> Void) {
        parse(option: option, completionHanlder: completionHandler)
    }
}

extension Facepp {
    func parse<R: ResponseProtocol>(option: RequestProtocol,
                                    completionHanlder: @escaping (Error?, R?) -> Void)  {
        
        let (request, data) = option.asRequest(apiKey: apiKey, apiSecret: apiSecret)
        
        guard let req = request else {
            return completionHanlder(RequestError.MissingArguments, nil)
        }
        
        session.uploadTask(with: req, from: data) { (data, _, error) in
            guard error == nil, let data = data else {
                return completionHanlder(error, nil)
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let resp = try decoder.decode(R.self, from: data)
                if let msg = resp.errorMessage {
                    completionHanlder(RequestError.FaceppError(msg), nil)
                } else {
                    completionHanlder(error, resp)
                }
            } catch(let err) {
                completionHanlder(err, nil)
            }
        }.resume()
    }
}

public class FaceppBaseRequest: RequestProtocol {
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
    
    var requsetURL: URL? {
        return kCardppV1URL
    }
    
    func paramsCheck() -> Bool {
        return imageURL != nil || imageFile != nil || imageBase64 != nil
    }
    
    func params(apiKey: String, apiSecret: String) -> (Params, [Params]?) {
        var params: Params = [
            "api_key": apiKey,
            "api_secret": apiSecret,
        ]
        var files = [Params]()
        params["image_url"] = imageURL
        params["image_base64"] = imageBase64
        if let url = imageFile, let data = try? Data(contentsOf: url) {
            files.append([
                "fieldName": "image_file",
                "fileType": url.pathExtension,
                "data": data
            ])
        }
        return (params, files)
    }
}

public class CardppV1Requst: FaceppBaseRequest {
    override var requsetURL: URL? {
        return kCardppV1URL
    }
}
