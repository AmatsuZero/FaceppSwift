//
//  Cardpp.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/10.
//

import Foundation
import ArgumentParser

struct FppCardppCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "card",
        abstract: "证件识别",
        subcommands: [
            FppIDCardCommand.self,
            FppDriverLicenseCommand.self,
            FppVehicleLicenseCommand.self,
            FppBankcardCommand.self,
            FppTemplateOCRCommand.self
        ]
    )
}
