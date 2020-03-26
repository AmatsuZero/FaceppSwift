//
//  Users.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/3.
//

import ArgumentParser
import Foundation
import FaceppSwift
#if os(macOS)
import Security
#else
import FoundationNetworking
#endif

let configFileURL = configDir?.appendingPathComponent("config")

// MARK: - 设置
class FppConfig: Codable {
    var key: String
    var secret: String

    static let session: URLSession = {
        return URLSession(configuration: .default)
    }()

    static var reports = [Int: String]()

    static var currentUser: FppConfig? = {
        var rawData: Data?
        #if os(macOS)
        let config = FppConfig(key: "", secret: "")
        let secureStore = SecureStore(secureStoreQueryable: config)
        let raw = try? secureStore.getValue()
        rawData = raw?.data(using: .utf8, allowLossyConversion: false)
        #else
        guard let url = configFileURL else {
            return nil
        }
        rawData =  try? Data(contentsOf: url)
        #endif
        guard let data = rawData else {
            return nil
        }
        return try? JSONDecoder().decode(FppConfig.self, from: data)
    }()

    init(key: String, secret: String) {
        self.key = key
        self.secret = secret
    }

    func save() throws {
        let data = try JSONEncoder().encode(self)
        #if os(macOS)
        let secureStore = SecureStore(secureStoreQueryable: self)
        guard let str = String(data: data, encoding: .utf8) else {
            return
        }
        try secureStore.setValue(str)
        #else
        guard let url = configFileURL else {
            return
        }
        try data.write(to: url)
        #endif
    }
}
#if os(macOS)
// MARK: - Key chain存储
protocol SecureStoreQueryable {
    var query: [String: Any] { get }
}
/**
 钥匙串存储
 - note: 参考：https://www.raywenderlich.com/9240-keychain-services-api-tutorial-for-passwords-in-swift
 */
struct SecureStore {
    let secureStoreQueryable: SecureStoreQueryable

    init(secureStoreQueryable: SecureStoreQueryable) {
        self.secureStoreQueryable = secureStoreQueryable
    }

    func setValue(_ value: String, for userAccount: String = NSFullUserName()) throws {
        guard let encodedPassword = value.data(using: .utf8) else {
            throw SecureStoreError.string2DataConversionError
        }

        var query = secureStoreQueryable.query
        query[String(kSecAttrAccount)] = userAccount

        var status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            var attributesToUpdate: [String: Any] = [:]
            attributesToUpdate[String(kSecValueData)] = encodedPassword

            status = SecItemUpdate(query as CFDictionary,
                                   attributesToUpdate as CFDictionary)
            if status != errSecSuccess {
                throw error(from: status)
            }
        case errSecItemNotFound:
            query[String(kSecValueData)] = encodedPassword

            status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                throw error(from: status)
            }
        default:
            throw error(from: status)
        }
    }

    func getValue(for userAccount: String = NSFullUserName()) throws -> String? {
        var query = secureStoreQueryable.query
        query[String(kSecMatchLimit)] = kSecMatchLimitOne
        query[String(kSecReturnAttributes)] = kCFBooleanTrue
        query[String(kSecReturnData)] = kCFBooleanTrue
        query[String(kSecAttrAccount)] = userAccount

        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, $0)
        }

        switch status {
        case errSecSuccess:
            guard
                let queriedItem = queryResult as? [String: Any],
                let passwordData = queriedItem[String(kSecValueData)] as? Data,
                let password = String(data: passwordData, encoding: .utf8)
                else {
                    throw SecureStoreError.data2StringConversionError
            }
            return password
        case errSecItemNotFound:
            return nil
        default:
            throw error(from: status)
        }
    }

    func removeValue(for userAccount: String = NSFullUserName()) throws {
        var query = secureStoreQueryable.query
        query[String(kSecAttrAccount)] = userAccount

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw error(from: status)
        }
    }

    func removeAllValues() throws {
        let query = secureStoreQueryable.query

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw error(from: status)
        }
    }

    func error(from status: OSStatus) -> SecureStoreError {
        let message = SecCopyErrorMessageString(status, nil) as String? ?? NSLocalizedString("Unhandled Error", comment: "")
        return SecureStoreError.unhandledError(message: message)
    }
}

enum SecureStoreError: Error {
    case string2DataConversionError
    case data2StringConversionError
    case unhandledError(message: String)
}

extension SecureStoreError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .string2DataConversionError:
            return NSLocalizedString("String to Data conversion error", comment: "")
        case .data2StringConversionError:
            return NSLocalizedString("Data to String conversion error", comment: "")
        case .unhandledError(let message):
            return NSLocalizedString(message, comment: "")
        }
    }
}

extension FppConfig: SecureStoreQueryable {
    var query: [String: Any] {
        var query: [String: Any] = [:]
        query[String(kSecClass)] = kSecClassGenericPassword
        query[String(kSecAttrService)] = "com.daubert.facepp.cli"
        return query
    }
}
#endif

extension FppConfig: FaceppMetricsReporter {
    #if os(macOS)
    func option(_ option: FaceppRequestConfigProtocol,
                task: URLSessionTask,
                didFinishCollecting metrics: URLSessionTaskMetrics) {
        FppConfig.reports[task.taskIdentifier] = "\(metrics)"
    }
    #endif
}

struct FppSetupCommand: ParsableCommand {
    static var configuration =  CommandConfiguration(
        commandName: "setup",
        abstract: "设置 api key 和 api secret, 后续请求可以不用再传这两个参数",
        discussion: "macOS 通过 Keychain 存储"
    )

    @Option(name:.shortAndLong, help: "api key")
    var key: String

    @Option(name:.shortAndLong, help: "api secret")
    var secret: String

    func run() throws {
        FppConfig.currentUser = FppConfig(key: key, secret: secret)
        try FppConfig.currentUser?.save()
    }
}

func semaRun(_ value: Int = 0, block: (DispatchSemaphore) -> Void) {
    let sema = DispatchSemaphore(value: value)
    block(sema)
    sema.wait()
}
