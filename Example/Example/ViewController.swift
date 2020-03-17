//
//  ViewController.swift
//  Example
//
//  Created by 姜振华 on 2020/3/12.
//  Copyright © 2020 FaceppSwift. All rights reserved.
//

import UIKit
import WebKit
import SnapKit
import FaceppSwift

class ViewController: UIViewController {
    let handler = FaceppBeautifySchemeHandler()
    let markHandler = FaceppMarkFacesSchemeHandler()
    lazy var webView: WKWebView = {
        let configureation = WKWebViewConfiguration()
        configureation.setURLSchemeHandler(handler, forURLScheme: FaceppBeautifySchemeHandler.scheme)
        configureation.setURLSchemeHandler(markHandler, forURLScheme: FaceppMarkFacesSchemeHandler.scheme)
        return WKWebView(frame: .zero, configuration: configureation)
    }()
    override func loadView() {
        super.loadView()
        view.addSubview(webView)
        webView.snp.makeConstraints { $0.edges.equalTo(0) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = Bundle.main.url(forResource: "Beautify", withExtension: "html", subdirectory: "WebPages") {
            handler.resourceDirURL = url.deletingLastPathComponent()
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
}
