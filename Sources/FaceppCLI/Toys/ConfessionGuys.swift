//
//  ConfessionGuys.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/8.
//

#if os(OSX)
import Cocoa
import AppKit
#else
import Foundation
#endif
import ArgumentParser

struct FppConfesssionGuysCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "confess",
        abstract: "生成告白小人图片",
        discussion: "仅限于 macOS 平台"
    )
    let zipURL = URL(string: "https://github.com/AmatsuZero/FaceppSwift/raw/master/Resources/ConfessionGuys.zip")
    let dirURL: URL? = {
        return  FppToysCommand.dirURL?.appendingPathComponent("Confession")
    }()

    @Argument(help: "显示的消息文本")
    var texts: [String]

    @Option(name: .shortAndLong, help: "图片输出路径")
    var output: String

    @Option(name: .shortAndLong, default: "#F1B64E", help: "背景色")
    var bgColor: String

    func run() throws {
        guard #available(macOS 10.10, *) else {
            writeError(RuntimeError("仅限于 macOS 使用"))
            return
        }

        let group = DispatchGroup()
        var images: [NSImage]?
        var error: Error?

        group.enter()
        loadImages { err, imgs in
            error = err
            images = imgs
            group.leave()
        }

        group.notify(queue: .main) {
            defer {
                Self.exit(withError: error)
            }
            guard let imgs = images else {
                return
            }
            do {
                try self.draw(images: imgs)
            } catch let e {
                error = e
            }
        }

        RunLoop.current.run()
    }
}

@available(macOS 10.10, *)
extension FppConfesssionGuysCommand {
    func loadImages(completionHandler: @escaping (Error?, [NSImage]?) -> Void) {
        guard let folderURL = dirURL else {
            return
        }
        let mgr = FileManager.default
        guard mgr.fileExists(atPath: folderURL.path) else {
            guard let dest = folderURL.createDirIfNotExist() else {
                completionHandler(RuntimeError("创建文件夹失败"), nil)
                return
            }
            zipURL?.fetchZipAndExtract(at: dest) { isSuccess, err in
                guard isSuccess else {
                    do {
                        try mgr.removeItem(at: dest)
                        completionHandler(err, nil)
                    } catch {
                        completionHandler(error, nil)
                    }
                    return
                }
                self.loadImages(completionHandler: completionHandler)
            }
            return
        }
        do {
            let urls = try mgr.contentsOfDirectory(at: folderURL,
                                                   includingPropertiesForKeys: nil,
                                                   options: .skipsHiddenFiles)
            completionHandler(nil, urls.compactMap { NSImage(contentsOf: $0)})
        } catch {
            completionHandler(error, nil)
        }
    }

    var manHeight: CGFloat {
        return 199
    }

    var manWidth: CGFloat {
        return 103
    }

    var manMargin: CGFloat {
        return 20
    }

    var manGradient: CGFloat {
        return 20
    }

    var canvasSize: CGSize {
        let txts = texts.reversed()
        var calH = CGFloat(txts.count) * manHeight
        if let n = txts.last?.count {
            calH += CGFloat(n) * manGradient
        }
        var calW: CGFloat = 0
        for text in txts where Int(calW) < text.count {
            calW = CGFloat(text.count)
        }
        calW *= manWidth
        return CGSize(width: calW + manMargin, height: calH)
    }

    var backgroundColor: NSColor? {
        return NSColor(hexString: bgColor, alpha: 1)
    }

    func draw(images: [NSImage]) throws {
        let im = NSImage(size: canvasSize)
        guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                         pixelsWide: Int(im.size.width),
                                         pixelsHigh: Int(im.size.height),
                                         bitsPerSample: 8,
                                         samplesPerPixel: 4,
                                         hasAlpha: true,
                                         isPlanar: false,
                                         colorSpaceName: .calibratedRGB,
                                         bytesPerRow: 0,
                                         bitsPerPixel: 0) else {
                                            return
        }
        im.addRepresentation(rep)
        im.lockFocus()
        guard let ctx = NSGraphicsContext.current?.cgContext else {
            return
        }
        // 添加背景色
        backgroundColor?.setFill()
        // 画举牌小人
        drawMen(ctx, images: images)
        im.unlockFocus()
        try im.tiffRepresentation?.write(to: URL(fileURLWithPath: output))
    }

    func drawOneMan(_ ctx: CGContext, image: NSImage, word: String, origin: CGPoint) {
        ctx.saveGState()
        image.draw(in: .init(origin: origin, size: image.size))
        ctx.translateBy(x: origin.x, y: origin.y)
        ctx.rotate(by: -43.5 * .pi / 180)

        let attrStr = NSAttributedString(string: word, attributes: [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 32),
            NSAttributedString.Key.foregroundColor: NSColor.black
        ])
        attrStr.draw(at: .init(x: 10-manWidth, y: manHeight - 56))
        ctx.restoreGState()
    }

    func drawMen(_ ctx: CGContext, images: [NSImage]) {
        let size = canvasSize
        ctx.fill(.init(origin: .zero, size: size))
        let txts = texts.reversed()

        // 计算小人所占宽高
        var calH = CGFloat(txts.count) * manHeight
        if let n = txts.last?.count {
            calH += CGFloat(n) * manGradient
        }
        var calW: CGFloat = 0
        for text in txts where Int(calW) < text.count {
            calW = CGFloat(text.count)
        }
        calW *= manWidth

        var offsetW = manMargin
        if calW < size.width {
            offsetW = (size.width - calW) / 2
        }

        var offsetH = manMargin
        if calH < size.height {
            offsetH = (size.height - calH) / 2
        }

        for (i, text) in txts.enumerated() {
            for (j, char) in text.enumerated() {
                let x = CGFloat(j) * manWidth + offsetW
                let y = CGFloat(i) * manHeight + CGFloat(j) * manGradient + offsetH
                if let randomeImg = images.randomElement() {
                    drawOneMan(ctx, image: randomeImg, word: String(char), origin: .init(x: x, y: y))
                }
            }
        }
    }
}
