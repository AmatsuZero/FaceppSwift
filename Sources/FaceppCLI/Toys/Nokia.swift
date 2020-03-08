//
//  Nokia.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/7.
//

#if os(OSX)
import AppKit
#else
import Foundation
#endif
import ArgumentParser

struct FppNokiaImage: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "nokia",
        abstract: "生成老式诺基亚手机信息图片",
        discussion: "仅限于 macOS 平台"
    )
    let zipURL = URL(string: "https://github.com/AmatsuZero/FaceppSwift/raw/master/Resources/Nokia.zip")
    let dirURL: URL? = {
        return  FppToysCommand.dirURL?.appendingPathComponent("Nokia")
    }()

    @Argument(help: "显示的消息文本")
    var text: String

    @Option(name: .shortAndLong, help: "图片输出路径")
    var output: String

    @Flag(name: .shortAndLong, default: false, inversion: .prefixedNo, help: "绿色包浆")
    var tint: Bool

    func run() throws {
        guard #available(macOS 10.10, *) else {
            writeError(RuntimeError("仅限于 macOS 使用"))
            return
        }

        let group = DispatchGroup()
        var sourceImage: NSImage?
        var sourceFont: NSFont?
        var err: Error?

        group.enter()
        loadResources { error, font, image in
            defer {
                group.leave()
            }
            guard error == nil else {
                err = error
                return
            }
            sourceImage = image
            sourceFont = font
        }

        group.notify(queue: .main) {
            do {
                try self.draw(image: sourceImage, font: sourceFont)
            } catch {
                Self.exit(withError: error)
            }
            Self.exit(withError: err)
        }

        RunLoop.current.run()
    }
}

@available(macOS 10.10, *)
extension FppNokiaImage {
    func loadResources(completionHandler: @escaping (Error?, NSFont?, NSImage?) -> Void) {
        guard let folderURL = dirURL,
            let url = zipURL else {
            return
        }
        let mgr = FileManager.default
        guard mgr.fileExists(atPath: folderURL.path) else {
            guard let dest = folderURL.createDirIfNotExist() else {
                completionHandler(RuntimeError("创建文件夹失败"), nil, nil)
                return
            }
            url.fetchZipAndExtract(at: dest) { isSuccess, err in
                guard isSuccess else {
                    try? mgr.removeItem(at: dest)
                    completionHandler(err, nil, nil)
                    return
                }
                self.loadResources(completionHandler: completionHandler)
            }
            return
        }
        let (imgErr, img) = loadImage()
        guard imgErr == nil else {
            completionHandler(imgErr, nil, nil)
            return
        }
        let (fontErr, font) = loadFont()
        guard fontErr == nil else {
            completionHandler(fontErr, nil, nil)
            return
        }
        completionHandler(nil, font, img)
    }

    func loadFont() -> (Error?, NSFont?) {
        guard let fileURL = dirURL?.appendingPathComponent("nokia.ttf") else {
            return (RuntimeError("字体文件不存在"), nil)
        }
        var err: Unmanaged<CFError>?
        guard CTFontManagerRegisterFontsForURL(fileURL as CFURL, .process, &err) else {
            return (err!.takeUnretainedValue() as Error, nil)
        }
        return (nil, NSFont(name: "方正像素14", size: 70))
    }

    func loadImage() -> (Error?, NSImage?) {
        guard let fileURL = dirURL?.appendingPathComponent("NokiaMessage.jpg") else {
            return (RuntimeError("图片文件不存在"), nil)
        }
        return (nil, NSImage(contentsOf: fileURL))
    }

    func draw(image: NSImage?, font: NSFont?) throws {
        guard let image = image,
            let font = font else {
                return
        }
        guard let bodyImg = drawBackgroundImage(size: image.size, font: font),
            let subtitleImg = drawSubTitle(size: image.size, font: font) else {
                return
        }

        guard let finalImage = drawText(image: image, bodyImage: bodyImg, subTitleImage: subtitleImg) else {
            return
        }

        try tintColor(image: finalImage)
            .tiffRepresentation?
            .write(to: .init(fileURLWithPath: output))
    }

    // 创建旋转后的文字的图片
    func drawBackgroundImage(size: CGSize, font: NSFont) -> NSImage? {
        guard let textStyle = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle else {
            return nil
        }
        textStyle.lineSpacing = 20
        let attrStr = NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: NSColor.black,
            NSAttributedString.Key.paragraphStyle: textStyle
        ])
        let im = NSImage(size: size)
        guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                         pixelsWide: Int(size.width),
                                         pixelsHigh: Int(size.height),
                                         bitsPerSample: 8,
                                         samplesPerPixel: 4,
                                         hasAlpha: true,
                                         isPlanar: false,
                                         colorSpaceName: .calibratedRGB,
                                         bytesPerRow: 0,
                                         bitsPerPixel: 0) else {
                                            return nil
        }
        im.addRepresentation(rep)
        im.lockFocus()
        guard let ctx = NSGraphicsContext.current?.cgContext else {
            return nil
        }
        ctx.rotate(by: -9.8 * .pi / 180.0)
        let textSize = attrStr.boundingRect(with: .init(width: 680, height: 450),
                                            options: .usesLineFragmentOrigin).size

        attrStr.draw(in: .init(origin: .init(x: 130, y: 860 - textSize.height), size: textSize))
        im.unlockFocus()
        return im
    }

    // 将旋转的文字图片画到原来的图片上
    func drawText(image: NSImage,
                  bodyImage: NSImage,
                  subTitleImage: NSImage) -> NSImage? {
        let im = NSImage(size: image.size)
        guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                         pixelsWide: Int(image.size.width),
                                         pixelsHigh: Int(image.size.height),
                                         bitsPerSample: 8,
                                         samplesPerPixel: 4,
                                         hasAlpha: true,
                                         isPlanar: false,
                                         colorSpaceName: .calibratedRGB,
                                         bytesPerRow: 0,
                                         bitsPerPixel: 0) else {
                                            return nil
        }
        im.addRepresentation(rep)
        im.lockFocus()
        let rect = NSRect(origin: .zero, size: image.size)
        image.draw(in: rect)
        bodyImage.draw(in: rect)
        subTitleImage.draw(in: rect)
        im.unlockFocus()
        return im
    }

    // 字数
    func drawSubTitle(size: CGSize, font: NSFont) -> NSImage? {
        guard let textStyle = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle else {
            return nil
        }
        let attrStr = NSAttributedString(string: "\(text.count)/900", attributes: [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: NSColor(red: 129/255, green: 212/255, blue: 250/255, alpha: 1),
            NSAttributedString.Key.paragraphStyle: textStyle
        ])

        let im = NSImage(size: size)
        guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                         pixelsWide: Int(size.width),
                                         pixelsHigh: Int(size.height),
                                         bitsPerSample: 8,
                                         samplesPerPixel: 4,
                                         hasAlpha: true,
                                         isPlanar: false,
                                         colorSpaceName: .calibratedRGB,
                                         bytesPerRow: 0,
                                         bitsPerPixel: 0) else {
                                            return nil
        }
        im.addRepresentation(rep)
        im.lockFocus()
        guard let ctx = NSGraphicsContext.current?.cgContext else {
            return nil
        }
        ctx.rotate(by: -9.8 * .pi / 180.0)
        let textSize = attrStr.boundingRect(with: .init(width: 680, height: 450)).size
        attrStr.draw(in: .init(origin: .init(x: size.width - textSize.width - 380, y: -180), size: size))
        im.unlockFocus()
        return im
    }

    // 绿色包浆
    func tintColor(image: NSImage) -> NSImage {
        guard tint, let img = image.copy() as? NSImage else {
            return image
        }
        img.lockFocus()
        guard let ctx = NSGraphicsContext.current?.cgContext else {
            return image
        }
        ctx.rotate(by: -9.0 * .pi / 180.0)
        NSColor(red: 100 / 255, green: 212 / 255, blue: 56 / 255, alpha: 0.2).set()
        let x: CGFloat = 100
        let y: CGFloat = 240
        NSRect(origin: CGPoint(x: x, y: y),
               size: CGSize(width: 800, height: 800))
            .fill()
        img.unlockFocus()
        return img
    }
}
