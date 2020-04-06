//
//  Pornhub.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/4/6.
//

#if os(OSX)
import Cocoa
import AppKit
#else
import Foundation
#endif
import ArgumentParser

final class FppPornhubCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "pornhub",
        abstract: "生成 Pornhub 风格的 Logo ",
        discussion: "仅限于 macOS 平台"
    )
    
    @Option(name: .shortAndLong, help: "图片输出路径")
    var output: String
    
    @Option(name: .long, help: "第一部分文本")
    var pornText: String
    
    @Option(name:  .long, help: "第二部分文本")
    var hubText: String
    
    enum Theme: String, ExpressibleByArgument {
        case dark, light
    }
    
    @Option(name: .shortAndLong, default: .dark, help: "主题色")
    var theme: Theme
    
    enum Style: String, ExpressibleByArgument {
        case horizontal, vertical
    }
    
    @Option(name: .shortAndLong, default:.horizontal, help: "样式")
    var style: Style
    
    @Option(name: .long, default: 1024, help: "画布宽度")
    var width: Double
    
    @Option(name: .long, default: 768, help: "画布宽度")
    var height: Double
    
    @Option(name: .shortAndLong, default: 117.76, help: "指定字体大小，近当自动调整字体关闭时生效")
    var fontSize: Double
    
    func run() throws {
        guard #available(macOS 10.10, *) else {
            writeError(RuntimeError("仅限于 macOS 使用"))
            return
        }
        try draw()?.tiffRepresentation?.write(to: .init(fileURLWithPath: output))
    }
}

#if os(macOS)
extension FppPornhubCommand {
    
    func containerView() -> NSView {
        let view = NSStackView(frame: .init(origin: .zero, size: canvasSize))
        view.wantsLayer = true
        view.layer?.backgroundColor = theme == .dark ? .black : .white
        return view
    }
    
    var canvasSize: CGSize {
        return CGSize(width: width, height: height)
    }
    
    var font: NSFont {
        if fontSize <= 0 {
            fontSize = 117.76
        }
        let mgr = NSFontManager.shared
        return mgr.font(withFamily: "Arial", traits: .boldFontMask, weight: 2, size: CGFloat(fontSize))!
    }
    
    var hPadding: CGFloat {
        return 8 * (NSScreen.main?.backingScaleFactor ?? 1)
    }
    
    var vPadding: CGFloat {
        return 6 * (NSScreen.main?.backingScaleFactor ?? 1)
    }
    
    func pornTextField() -> NSTextField {
        let textField = NSTextField(frame: .zero)
        textField.wantsLayer = true
        textField.textColor = theme == .dark ? .white : .black
        textField.font = font
        textField.layer?.backgroundColor = .clear
        // to remove a strange border
        textField.layer?.borderColor = theme == .dark ? NSColor.black.cgColor : NSColor.white.cgColor
        textField.layer?.borderWidth = 4
        textField.stringValue = pornText
        textField.alignment = .center
        textField.sizeToFit()
        return textField
    }
    
    func hubTextField() -> NSTextField {
        let textField = NSTextField(frame: .zero)
        textField.textColor = theme == .dark ? .black : .white
        textField.font = font
        textField.backgroundColor = NSColor(hex: 0xf7971d, alpha: 1)
        textField.stringValue = hubText
        textField.alignment = .center
        textField.sizeToFit()
        textField.wantsLayer = true
        textField.layer?.cornerRadius = 4
        return textField
    }
    
    func draw() -> NSImage? {
        let pTextField = pornTextField()
        let hTextField = hubTextField()
        let background = containerView()
        let container = NSView()
        container.addSubview(pTextField)
        container.addSubview(hTextField)
        background.addSubview(container)
        if style == .horizontal {
            hTextField.frame.origin.x = pTextField.frame.maxX
            container.frame.size = .init(width: hTextField.frame.width + pTextField.frame.width, height: pTextField.frame.height)
        } else {
            pTextField.frame.origin.y = hTextField.frame.maxY
            let maxWidth = max(pTextField.frame.width, hTextField.frame.width)
            container.frame.size = .init(width: maxWidth, height: pTextField.frame.height + hTextField.frame.height)
            pTextField.frame.origin.x = (maxWidth - pTextField.frame.width) / 2
            hTextField.frame.origin.x = (maxWidth - hTextField.frame.width) / 2
        }
        container.frame.origin.x = (background.frame.width - container.frame.width) / 2
        container.frame.origin.y = (background.frame.height - container.frame.height) / 2
        return background.toImage()
    }
}

extension NSView {
    func toImage() -> NSImage? {
        guard let bir = bitmapImageRepForCachingDisplay(in: bounds) else {
            return nil
        }
        bir.size = bounds.size
        cacheDisplay(in: bounds, to: bir)
        let image = NSImage(size: bounds.size)
        image.addRepresentation(bir)
        return image
    }
}

#endif
