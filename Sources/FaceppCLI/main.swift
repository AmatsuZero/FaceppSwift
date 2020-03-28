import ArgumentParser
import Foundation

enum CommonError: Error {
    case invalidInput(String)
}

func leave(error: Error? = nil) {
    if let err = error {
        writeError(err)
        exit(-1)
    } else {
        exit(EXIT_SUCCESS)
    }
}

let configDir = FileManager.default
    .urls(for: .documentDirectory, in: .userDomainMask).first?
    .appendingPathComponent("com.daubertjiang.faceppcli")
    .createDirIfNotExist()

struct FappRegisterCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "register",
        abstract: "前去官网注册"
    )

    let website = "https://console.faceplusplus.com.cn/register"

    func run() throws {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        #if os(macOS)
        task.arguments = ["open", website]
        #else
        task.arguments = ["xdg-open", website]
        #endif
        if #available(OSX 10.13, *) {
            try task.run()
        } else {
            let pipe = Pipe()
            task.standardError = pipe
            task.launch()

            let errorData = pipe.fileHandleForReading.readDataToEndOfFile()
            let error = String(decoding: errorData, as: UTF8.self)
            if !error.isEmpty {
                throw NSError(domain: error, code: -1, userInfo: nil)
            }
        }
    }
}

struct Facepp: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Face++ 命令行工具",
        subcommands: [
            FppSetupCommand.self,
            FppFacialRecognition.self,
            FppFacesetCommand.self,
            FppHumanBodyCommand.self,
            FppCardppCommand.self,
            FppImageppCommand.self,
            FppFaceAlbumCommand.self,
            FppToysCommand.self,
            FappRegisterCommand.self
        ])

    @Flag(name: .shortAndLong, help: "版本号")
    var version: Bool

    func run() throws {
        var output = ""
        if version {
            output += kVersion
        }
        print(output)
    }
}

Facepp.main()
