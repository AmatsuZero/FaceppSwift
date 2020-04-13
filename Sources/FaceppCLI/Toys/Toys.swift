//
//  File.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/7.
//
import Foundation
import ArgumentParser

struct FppToysCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "toys",
        abstract: "内置的小玩具",
        subcommands: [
            FppNokiaImage.self,
            FppConfesssionGuysCommand.self,
            FppPornhubCommand.self,
            FppQRCodeCommand.self,
            FppGithubCommand.self
        ]
    )

    static let dirURL: URL? = {
        return configDir?.appendingPathComponent("Toys").createDirIfNotExist()
    }()
}
