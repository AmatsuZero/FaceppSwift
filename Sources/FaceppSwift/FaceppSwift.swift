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
    
    init(apikey key: String, apiSecret secret: String) {
        self.apiKey = key
        self.apiSecret = secret
    }
    
    public func detect(option: DetectOption, completionHanlder: @escaping (Error?, DetectResponse?) -> Void) {
        
        let (request, data) = option.asRequest(apiKey: apiKey, apiSecret: apiSecret)
        
        guard let req = request else {
            return completionHanlder(RequestError.NoPic, nil)
        }
        
        session.uploadTask(with: req, from: data) { (data, _, error) in
            guard error == nil, let data = data else {
                return completionHanlder(error, nil)
            }
            do {
//                let da = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
//                print(da)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let resp = try decoder.decode(DetectResponse.self, from: data)
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
