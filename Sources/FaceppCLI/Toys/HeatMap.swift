//
//  HeatMap.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/4/12.
//

#if os(OSX)
import AppKit
#else
import Foundation
#endif
import Rainbow
import ArgumentParser

struct GithubCommitData {
    let date: Date
    let color: String
    let count: Int
    var weekDay = 0
    var month = 0

    var consoleColor: String {
        switch color {
        case "#ebedf0":
            return BackgroundColor.white.output
        case "#c6e48b":
            return BackgroundColor.green.output
        case "#7bc96f":
            return BackgroundColor.green.output
        case "#239a3b":
            return BackgroundColor.red.output
        default:
            return "  "
        }
    }
}

extension GithubCommitData: CustomStringConvertible {
    var description: String {
        return "On \(dateString), with \(count) commits in color \(color)"
    }
    var dateString: String {
        let formatter = GithubCommitHelper.dateFormatter
        return formatter.string(from: date)
    }
}

final class GithubCommitHelper {
    let userName: String

    init(userName: String) {
        self.userName = userName
    }

    lazy var url: URL? = {
        return URL(string: "https://github.com/users/\(userName)/contributions")
    }()

    lazy var webData: String? = {
        guard let url = self.url else {
            return nil
        }
        return try? String(contentsOf: url, encoding: .utf8)
    }()

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    lazy var regExp: NSRegularExpression = {
        let pattern = "(fill=\")(#[^\"]{6})(\" data-count=\")([^\"]{1,})(\" data-date=\")([^\"]{10})(\"/>)"
        return (try? NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)) ?? NSRegularExpression()
    }()

    func fetchCommit() -> [GithubCommitData]? {
        guard let webData = webData else { return nil }
        let matched = regExp.matches(in: webData, range: NSRange(location: 0, length: webData.count))
        let commitArray: [GithubCommitData] = matched.map { item in
            let substringForRange: (Int) -> String = { index in
                return (webData as NSString).substring(with: item.range(at: index))
            }
            let color = substringForRange(2)
            let count = Int(substringForRange(4))!
            let date = Self.dateFormatter.date(from: substringForRange(6))!
            let itemData = GithubCommitData(date: date, color: color, count: count,
                                            weekDay: date.weekday, month: date.month)

            return itemData
        }
        return commitArray
    }

    func fetchOrganizedCommit() -> [[GithubCommitData]]? {
        guard let tempArray = fetchCommit(), !tempArray.isEmpty else {
            return nil
        }
        var commits = [[GithubCommitData]]()
        let tempArrayLength = tempArray.count - 1
        let today = tempArray.last
        let weekDay = today!.date.weekday
        commits.append((0...weekDay).map { tempArray[tempArrayLength - weekDay + $0]})
        for weekFromNow in 0..<50 {
            commits.append((1...7).map { tempArray[tempArrayLength-weekDay-weekFromNow*7-7+$0]})
        }
        return commits
    }
}

extension Date {
    func component(_ component: Calendar.Component) -> Int {
        let calendar = Calendar.autoupdatingCurrent
        return calendar.component(component, from: self)
    }
    var weekday: Int {
        return component(.weekday)
    }
    var month: Int {
        return component(.month)
    }
}

final class VisualizationHelper {
    let COMMIT_TILE_SIZE_PERCETAGE = 0.85
    let COMMIT_FONT_SIZE_PERCETAGE = 0.6
    let TopMargin  = 4.0
    let BottomMargin = 4.0
    let COMMIT_IMAGE_RIGHT_MARGIN = 4.0
    let COMMIT_IMAGE_LEFT_MARGIN = 4.0
    let COMMIT_VERTIAL_TILE_NUM  = 8.0
    let WEEKS_IN_YEAR = 52.0
    let months = ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"]
    let commitHelper: GithubCommitHelper

    init(userName: String) {
        self.commitHelper = GithubCommitHelper(userName: userName)
    }

    #if os(macOS)
    func commitImageWithRect(rect: CGRect) -> NSImage {
        let im = NSImage(size: rect.size)
        guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                         pixelsWide: Int(rect.width),
                                         pixelsHigh: Int(rect.height),
                                         bitsPerSample: 8,
                                         samplesPerPixel: 4,
                                         hasAlpha: true,
                                         isPlanar: false,
                                         colorSpaceName: .calibratedRGB,
                                         bytesPerRow: 0,
                                         bitsPerPixel: 0) else {
                                            return im
        }
        im.addRepresentation(rep)
        im.lockFocus()
        NSColor.clear.setFill()
        guard let context = NSGraphicsContext.current?.cgContext else {
            return im
        }
        drawCommits(context, rect: rect)
        im.unlockFocus()
        return im
    }

    func drawCommits(_ context: CGContext, rect: CGRect) {
        guard let data = commitHelper.fetchOrganizedCommit() else {
            return
        }
        let squareBlankSize = (Double(rect.size.height) - TopMargin - BottomMargin) / COMMIT_VERTIAL_TILE_NUM
        let squareSize = squareBlankSize * COMMIT_TILE_SIZE_PERCETAGE
        let frameWidth = rect.width - CGFloat(COMMIT_IMAGE_LEFT_MARGIN + COMMIT_IMAGE_RIGHT_MARGIN)
        let width = Int(Double(frameWidth) / squareBlankSize >= WEEKS_IN_YEAR
            ? WEEKS_IN_YEAR - 1
            : Double(frameWidth) / squareBlankSize)
        for weekFromNow in 0..<width {
            let week = data[weekFromNow]
            week.forEach { day in
                let rec = CGRect(x: Double(rect.width)-COMMIT_IMAGE_RIGHT_MARGIN-Double(CGFloat(weekFromNow+1))*squareBlankSize,
                                 y: TopMargin + Double(CGFloat(day.weekDay-1)) * squareBlankSize,
                                 width: squareSize,
                                 height: squareSize)
                NSColor(hexString: day.color)?.setFill()
                context.fill(rec)
            }

            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: CGFloat(squareSize * COMMIT_FONT_SIZE_PERCETAGE)),
                .strokeWidth: 0,
                .foregroundColor: NSColor.lightGray
            ]
            let monthName = NSAttributedString(string: months[week.first!.month-1], attributes: attributes)
            var x = rect.width - CGFloat(COMMIT_IMAGE_RIGHT_MARGIN)
            x -= CGFloat(weekFromNow+1) * CGFloat(squareBlankSize)
            x += CGFloat(squareSize * (1.0-COMMIT_FONT_SIZE_PERCETAGE) / 2.0)
            let y = CGFloat(TopMargin + (COMMIT_VERTIAL_TILE_NUM-1) * squareBlankSize)
            monthName.draw(at: .init(x: x, y: y))
        }
    }
    #endif

    func drawCommitsInConsole() {
//        guard let data = commitHelper.fetchOrganizedCommit() else {
//            return
//        }
//        var result = ""
//        for weekFromNow in 0..<Int(WEEKS_IN_YEAR-1) {
//            let week = data[weekFromNow]
//            week.reversed().forEach { day in
//                result += " " + day.consoleColor
//            }
//        }
//        print(result)
    }
}

final class FppGithubCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "github",
        abstract: "查看Github热力图",
        discussion: "仅支持 macOS 输出图片")

    @Option(name: .long, default: 1024, help: "画布宽度")
    var width: Double

    @Option(name: .long, default: 768, help: "画布宽度")
    var height: Double

    @Option(name: .shortAndLong, help: "Github 用户名")
    var name: String

    @Option(name: .shortAndLong, help: "图片输出路径")
    var output: String?

    @Flag(default: false, inversion: .prefixedEnableDisable, help: "浏览器查看")
    var openInBrowse: Bool

    lazy var visualizeHelper: VisualizationHelper = {
        return VisualizationHelper(userName: name)
    }()

    func run() throws {
        if let path = output {
            guard #available(macOS 10.10, *) else {
                if openInBrowse {
                    try browse()
                }
                writeError(RuntimeError("仅限于 macOS 使用"))
                return
            }
            try visualizeHelper
                .commitImageWithRect(rect: .init(origin: .zero,
                                                 size: .init(width: width, height: height)))
                .tiffRepresentation?
                .write(to: URL(fileURLWithPath: path))
        } else {
            visualizeHelper.drawCommitsInConsole()
        }
        if openInBrowse {
            try browse()
        }
    }

    /// 浏览器查看
    func browse() throws {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        let url = visualizeHelper.commitHelper.url?.absoluteString ?? ""
        #if os(macOS)
        task.arguments = ["open", url]
        #else
        task.arguments = ["xdg-open", url]
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
