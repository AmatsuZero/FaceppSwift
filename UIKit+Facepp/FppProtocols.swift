//
//  FppProtocols.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/3/13.
//

import UIKit

public protocol FppImageDelegate:class {
    func image(_ image: UIImage, option: FaceppRequestConfigProtocol, taskDidBeigin: URLSessionTask?)
    func image(_ image: UIImage, taskDidEndWithEror: Error?, response: FaceppResponseBaseProtocol?)
}

public extension FppImageDelegate {
    func image(_ image: UIImage, option: FaceppRequestConfigProtocol, taskWillBeigin: URLSessionTask?) {}
    func image<R: FaceppResponseProtocol>(_ image: UIImage, taskDidEnd:(Error?, R?) -> Void) {}
}

private var fppImageassociateKey: Void?
private var fppMetricsReporterKey: Void?

public extension UIImage {
    weak var fppDelegate: FppImageDelegate? {
        set {
            objc_setAssociatedObject(self, &fppImageassociateKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            objc_getAssociatedObject(self, &fppImageassociateKey) as? FppImageDelegate
        }
    }
    
    weak var fppMetricsReport: FaceppMetricsReporter? {
        set {
            objc_setAssociatedObject(self, &fppMetricsReporterKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            objc_getAssociatedObject(self, &fppMetricsReporterKey) as? FaceppMetricsReporter
        }
    }
}
