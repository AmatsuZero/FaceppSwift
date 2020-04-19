//
//  BaijiaHao.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/4/19.
//

import Foundation
import ArgumentParser
import Rainbow

final class FppBaijiahaoCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "rubbish",
        discussion: "水文生成器")
    
    @Option(name: .shortAndLong, help: "主语")
    var subject: String
    
    @Option(name: .shortAndLong, help: "谓词")
    var verb: String
    
    func run() throws {
        let text = """
        \(subject)\(verb)是怎么回事呢？\(subject)相信大家都很熟悉， 但是\(verb)是怎么回事呢？下面就让小编带大家一起了解吧。
        
        \(subject)\(verb)，其实就是\(verb)了。那么\(subject)为什么会\(verb)，相信大家都很好奇是怎么回事。大家可能会感到很惊讶，\(subject)怎么会\(verb)呢？但事实就是这样，小编也感到非常惊讶。那么这就是关于\(subject)\(verb)的事情了，大家有没有觉得很神奇呢？
        
        看了今天的内容，大家有什么想法呢？欢迎在评论区告诉小编一起讨论哦。
        """
        print(text.applyingCodes(Color.green, BackgroundColor.white, Style.italic))
    }
}
