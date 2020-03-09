//
//  HumanBody.swift
//  ArgumentParser
//
//  Created by 姜振华 on 2020/3/9.
//

import Foundation
import ArgumentParser

struct FppHumanBodyCommand: ParsableCommand {
   static var configuration = CommandConfiguration(
        commandName: "body",
        abstract: "人体识别",
        subcommands: [
            FppHumanBodyDetect.self,
            FppHumanBodySkeleton.self,
            FppHumanBodySegment.self,
            FppHumanBodyGesture.self
        ]
    )
}
