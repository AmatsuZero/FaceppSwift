//
//  Face.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/4.
//

import Foundation
import ArgumentParser

struct FppFacesetCommand: ParsableCommand {
    static var configuration =  CommandConfiguration(
        commandName: "faceset",
        abstract: "人脸集合",
        subcommands: [

        ])
}

struct FppFacialRecognition: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "face",
        abstract: "人脸识别",
        subcommands: [
            FppDetectCommand.self,
            FppFaceCompareCommand.self,
            FppFaceSearchCommand.self,
            FppFacesetCommand.self,
            FppFaceBeautifyCommand.self,
            FppDenseLandmarkCommand.self,
            FppFeaturesCommand.self,
            FppSkinAnalyzeCommand.self,
            FppFaceModelCommand.self
        ]
    )
}
