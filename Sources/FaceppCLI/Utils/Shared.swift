//
//  Utils.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/4.
//

import Foundation
import ArgumentParser
import FaceppSwift
import ZIPFoundation
import Rainbow

let kVersion = "0.1.9"

struct RuntimeError: Swift.Error, CustomStringConvertible {
    var description: String
    init(_ desc: String) {
        description = desc
    }
}

extension FaceppRectangle: ExpressibleByArgument {
    public convenience init?(argument: String) {
        self.init(string: argument)
    }
}

protocol FaceCLIBaseCommand: ParsableCommand {
    var apiKey: String? { get set }
    var apiSecret: String? { get set }
    var checkParams: Bool { get set }
    var timeout: TimeInterval { get set }
    @available(OSX 10.12, *)
    var metrics: Bool { get set }
}

extension FaceCLIBaseCommand {
    func setup() throws {
        guard let key = apiKey ?? FppConfig.currentUser?.key,
            let secret = apiSecret ?? FppConfig.currentUser?.secret else {
                throw RuntimeError("缺少 api key 和 api secret")
        }
        FaceppClient.initialization(key: key, secret: secret)
    }
}

protocol FaceCLIBasicCommand: FaceCLIBaseCommand {
    var imageURL: String? { get set }
    var imageFile: String? { get set }
    var imageBase64: String? { get set }
}

extension FaceppRequestConfigProtocol {
    mutating func setup(_ command: FaceCLIBaseCommand) {
        timeoutInterval = command.timeout
        needCheckParams = command.checkParams
        if #available(OSX 10.12, *), command.metrics {
            metricsReporter = FppConfig.currentUser
        }
    }
}

extension FaceppBaseRequest {
    convenience init(_ command: FaceCLIBasicCommand) throws {
        self.init()
        try command.setup()
        timeoutInterval = command.timeout
        needCheckParams = command.checkParams
        if #available(OSX 10.12, *), command.metrics {
            metricsReporter = FppConfig.currentUser
        }
        if let url = command.imageURL {
            imageURL = URL(string: url)
        }
        if let url = command.imageFile {
            imageFile = URL(fileURLWithPath: url)
        }
        imageBase64 = command.imageBase64
    }
}

func commonResponseHandler<R: FaceppResponseProtocol>(_ sema: DispatchSemaphore,
                                                      taskID: Int?,
                                                      error: Swift.Error? = nil,
                                                      resp: R? = nil) {
    guard error == nil else {
        leave(error: error)
        return
    }
    writeMessage(resp, taskId: taskID)
    sema.signal()
}

enum OutputType {
    case error
    case standard
}

func writeMessage<R: FaceppResponseProtocol>(_ message: R?, taskId: Int?, error: Swift.Error? = nil) {
    if let err = error {
        writeError(err)
    } else if let resp = message {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            let data = try encoder.encode(resp)
            var output = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if var dict = output as? [String: Any], let id = taskId {
                dict["metrics"] = FppConfig.reports[id]
                output = dict
            }
            let outputStr = String(data: try JSONSerialization.data(withJSONObject: output,
                                                                options: .prettyPrinted),
                               encoding: .utf8) ?? ""
            print(outputStr.green)
        } catch {
            writeError(error)
        }
    }
}

func writeError(_ error: Swift.Error) {
    fputs("\(error.localizedDescription)\n".applyingCodes(Color.red, BackgroundColor.white, Style.bold),
          stderr)
}

extension URL {
    func fetchZip(destination: URL, completionHandler: @escaping (Bool, Swift.Error?) -> Void) {
        FppConfig.session.dataTask(with: self) { data, _, err in
            guard let data = data else {
                completionHandler(false, err)
                return
            }
            do {
                try data.write(to: destination)
                completionHandler(true, nil)
            } catch {
                completionHandler(false, error)
            }
        }.resume()
    }

    func fetchZipAndExtract(at folderURL: URL, completionHandler: @escaping (Bool, Swift.Error?) -> Void) {
        let tmpZip = folderURL.appendingPathComponent("\(UUID().uuidString).zip")
        fetchZip(destination: tmpZip) { isSuccess, err in
            guard isSuccess else {
                completionHandler(isSuccess, err)
                return
            }
            do {
                try FileManager.default.unzipItem(at: tmpZip, to: folderURL)
                try FileManager.default.removeItem(at: tmpZip)
                completionHandler(true, nil)
            } catch {
                completionHandler(false, error)
            }
        }
    }
}

enum FppAPIVersion: String, ExpressibleByArgument, Decodable {
    case v1, v2, beta
}
