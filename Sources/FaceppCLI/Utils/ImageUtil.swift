//
//  ImageUtil.swift
//  ArgumentParser
//
//  Created by 姜振华 on 2020/3/7.
//

import Foundation
import ArgumentParser
import SwiftGD

struct FppImageUitlCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "util",
        abstract: "内置工具"
    )
}

extension URL {
    func fetchImageData(completionHandler: @escaping (Swift.Error?, Data?) -> Void) {
        FppConfig.session.dataTask(with: self) { data, _, error in
            completionHandler(error, data)
        }.resume()
    }

    func fetchImageBase64(completionHandler: @escaping (Swift.Error?, String?) -> Void) {
        fetchImageData { error, data in
            completionHandler(error,
                              data?.base64EncodedString(options: .lineLength64Characters))
        }
    }

    func fetchImage(completionHandler: @escaping (Swift.Error?, Image?) -> Void) {
        fetchImageData { error, data in
            guard let data = data else {
                completionHandler(error, nil)
                return
            }
            do {
                let img = try Image(data: data)
                completionHandler(error, img)
            } catch let e {
                completionHandler(e, nil)
            }
        }
    }

    func createDirIfNotExist() -> URL? {
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default
                .createDirectory(at: self, withIntermediateDirectories: false, attributes: nil)
            } catch {
                return nil
            }
        }
        return self
    }
}
