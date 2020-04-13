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
import Rainbow

extension BackgroundColor: ExpressibleByArgument {
    private var color: String {
        return "\u{001B}[\(rawValue)m"
    }
    var output: String {
        return "\(color)  \u{001B}[0m"
    }
}

extension Color: ExpressibleByArgument {
    private var color: String {
        return "\u{001B}[\(rawValue)m"
    }
    var output: String {
        return "\(color)  \u{001B}[0m"
    }
}

final class FppQRCodeCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "qrcode",
        abstract: "终端生成二维码",
        discussion: "仅限于 macOS 平台"
    )

    @Option(name: .shortAndLong, default: .green, help: "字体颜色")
    var foregroundColor: Color

    @Option(name: .shortAndLong, default: .white, help: "字体背景颜色")
    var backgroundColor: BackgroundColor

    @Option(name: .shortAndLong, help: "二维码文案")
    var text: String

    func run() throws {
        guard #available(macOS 10.10, *) else {
            writeError(RuntimeError("仅限于 macOS 使用"))
            return
        }
        #if os(macOS)
        if let qrCode = text.createQRCodeANSI(background: backgroundColor, foreground: foregroundColor) {
            print(qrCode)
        }
        #endif
    }
}

#if os(macOS)
extension String {
    func createQRCodeANSI(background backgroundColor: BackgroundColor = .white,
                          foreground foregroundColor: Color = .black) -> String? {
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
            .useSoftwareRenderer: false
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
                        result += backgroundColor.output
                    } else {
                        result += foregroundColor.output
                    }
                }
            }
            result += "\n"
        }
        return result
    }
}

#endif
