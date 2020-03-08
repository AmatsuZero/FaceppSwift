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

struct Facepp: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Face++ 命令行工具",
        subcommands: [
            FppSetupCommand.self,
            FppFacialRecognition.self,
            FppImageUitlCommand.self,
            FppToysCommand.self
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
