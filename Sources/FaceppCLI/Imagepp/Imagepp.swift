//
//  Imagepp.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/10.
//

import Foundation
import ArgumentParser

struct FppFaceAlbumCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "album",
        abstract: "调用者可以通过此API在云端建立或删除人脸相册(Album)，相册可以根据相片中的人脸对相片进行智能分组，调用者也可通过图片中人脸来搜索该人脸所属分组的相片",
        discussion: """
        图片要求:

        -- 图片格式：JPG(JPEG)，PNG
        -- 图片像素尺寸：最小 48*48 像素，最大 4096*4096 像素
        -- 图片文件大小：2MB
        -- 最小人脸像素尺寸：系统能够检测到的人脸框为一个正方形，正方形边长的最小值为 150 像素。
        """,
        subcommands: [
            FppAFaceAlbumCreateCommand.self,
            FppFaceAlbumDeleteCommand.self,
            FppFaceAlbumFindCommand.self,
            FppFaceAlbumSearchCommand.self,
            FppFaceAlbumUpdateCommand.self,
            FppFaceAlbumAddFaceCommand.self,
            FppFaceAlbumGetDetailCommand.self,
            FppGetImageDetailCommand.self,
            FppGetAllFaceAlbumFCommand.self,
            FppFaceAlbumGetdetailCommand.self,
            FppFaceAlbumRemoveFaceCommand.self,
            FppFaceAlbumGroupFaceCommand.self,
            FppFaceAlbumTaskQueryCommand.self
        ],
        defaultSubcommand: FppGetAllFaceAlbumFCommand.self
    )
}

struct FppImageppCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "image",
        abstract: "图像识别",
        subcommands: [
            FppLicensePlateCommand.self,
            FppMergeFaceCommand.self,
            FppRecognizeTextCommand.self,
            FppDetectSceneAndObjectCommand.self
        ]
    )
}

struct FppFaceAlbumTaskQueryCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "query",
        abstract: "异步任务查询",
        subcommands: [
            FppFaceAlbumSearchTaskQueryCommand.self,
            FppFaceAlbumAddTaskQueryCommand.self,
            FppFaceAlbumGroupTaskQueryCommand.self
        ]
    )
}
