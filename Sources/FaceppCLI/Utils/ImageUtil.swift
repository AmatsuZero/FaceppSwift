//
//  ImageUtil.swift
//  ArgumentParser
//
//  Created by 姜振华 on 2020/3/7.
//

#if os(OSX)
import AppKit
#else
import Foundation
#endif
import ArgumentParser

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

#if os(macOS)
extension String {
    func conformsTo(pattern: String) -> Bool {
        let pattern = NSPredicate(format: "SELF MATCHES %@", pattern)
        return pattern.evaluate(with: self)
    }
}

@available(macOS 10.10, *)
extension NSColor {
    convenience init(hex: Int, alpha: Float) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        self.init(calibratedRed: red, green: green, blue: blue, alpha: 1.0)
    }

    convenience init?(hexString hex: String, alpha: Float) {
        // Handle two types of literals: 0x and # prefixed
        var cleanedString = ""
        if hex.hasPrefix("0x") {
            cleanedString = (hex as NSString).substring(from: 2)
        } else {
            cleanedString = (hex as NSString).substring(from: 1)
        }

        // Ensure it only contains valid hex characters 0
        let validHexPattern = "[a-fA-F0-9]+"
        guard cleanedString.conformsTo(pattern: validHexPattern) else {
            return nil
        }
        var theInt: UInt32 = 0
        let scanner = Scanner(string: cleanedString)
        guard scanner.scanHexInt32(&theInt) else {
            return nil
        }
        self.init(hex: Int(theInt), alpha: alpha)
    }
}
#endif