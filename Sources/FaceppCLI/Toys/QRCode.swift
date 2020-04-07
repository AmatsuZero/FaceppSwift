//
//  QRCode.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/4/6.
//

#if os(OSX)
import AppKit
#else
import Foundation
#endif
import ArgumentParser

enum ANSIColor: Int, ExpressibleByArgument {
    case Black = 30, Red, Green, Yellow, Blue, Magenta, Cyan, White
    case BackgroundBlack = 40, BackgroundRed, BackgroundGreen, BackgroundYellow,
    BackgroundBlue, BackgroundMagenta, BackgroundCyan, BackgroundWhite
    case BrightBlack = 90, BrightRed, BrightGreen, BrightYellow, BrightBlue, BrightMagenta, BrightCyan, BrightWhite

    private static let Reset = "\u{001B}[0m"

    private var color: String {
        return "\u{001B}[\(rawValue)m"
    }

    private var bgColor: String {
        return "\u{001B}[\(rawValue+10)m"
    }

    var fgOutput: String {
        return "\(color)  \(ANSIColor.Reset)"
    }

    var bgOutput: String {
        return "\(bgColor)  \(ANSIColor.Reset)"
    }
}

final class FppQRCodeCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "qrcode",
        abstract: "终端生成二维码",
        discussion: "仅限于 macOS 平台"
    )

    @Option(name: .shortAndLong, default: .White, help: "字体颜色")
    var foregroundColor: ANSIColor

    @Option(name: .shortAndLong, default: .Black, help: "字体背景颜色")
    var backgroundColor: ANSIColor
    
    @Option(name: .shortAndLong, help: "二维码文案")
    var text: String

    func run() throws {
        guard #available(macOS 10.10, *) else {
            writeError(RuntimeError("仅限于 macOS 使用"))
            return
        }
        #if os(macOS)
        if let qrCode = text.createQRCodeANSI(background: foregroundColor, foreground: backgroundColor) {
            print(qrCode)
        }
        #endif
    }
}

#if os(macOS)
extension String {
    func createQRCodeANSI(background backgroundColor: ANSIColor = .White,
                          foreground foregroundColor: ANSIColor = .Black) -> String? {
        // 生成二维码
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        guard let data = data(using: .utf8) else {
            return nil
        }
        filter?.setValue(data, forKey: "inputMessage")
        // 着色
        let colorFilter = CIFilter(name: "CIFalseColor")
        colorFilter?.setDefaults()
        colorFilter?.setValue(filter?.outputImage, forKey: "inputImage")
        colorFilter?.setValue(CIColor(color: .white), forKey: "inputColor0")
        colorFilter?.setValue(CIColor(color: .black), forKey: "inputColor1")
        let context = CIContext(options: [
            .useSoftwareRenderer : false
        ])
        guard let outputCIImage = colorFilter?.outputImage,
            let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return nil
        }
        let bmpImgRef = NSBitmapImageRep(cgImage: cgImage)
        let w = bmpImgRef.pixelsWide
        let h = bmpImgRef.pixelsHigh
        let blackColor = NSColor.black.usingColorSpace(.genericRGB)
        var result = ""
        for x in 0..<w {
            for y in 0..<h {
                if let color = bmpImgRef.colorAt(x: x, y: y) {
                    if color.usingColorSpace(.genericRGB) == blackColor {
                        result += backgroundColor.bgOutput
                    } else {
                        result += foregroundColor.bgOutput
                    }
                }
            }
            result += "\n"
        }
        return result
    }
}

#endif
