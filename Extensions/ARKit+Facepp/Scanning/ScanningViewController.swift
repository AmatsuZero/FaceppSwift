//
//  ScanningViewController.swift
//  FaceppSwift
//
//  Created by 姜振华 on 2020/5/6.
//
import UIKit
import ARKit

@available(iOS 12.0, *)
public class FaceppScanningViewController: UIViewController {
    var _referenceObjectToMerge: ARReferenceObject?
    var sceneView: ARSCNView!
    private var hasWarnedAboutLowLight = false
    var scan: Scan?
}

@available(iOS 12.0, *)
extension FaceppScanningViewController {
    func showAlert(title: String,
                   message: String,
                   buttonTitle: String? = "OK",
                   showCancel: Bool = false,
                   buttonHandler: ((UIAlertAction) -> Void)? = nil) {
        print(title + "\n" + message)
        var actions = [UIAlertAction]()
        if let buttonTitle = buttonTitle {
            actions.append(UIAlertAction(title: buttonTitle, style: .default, handler: buttonHandler))
        }
        if showCancel {
            actions.append(UIAlertAction(title: "Cancel", style: .cancel))
        }
        self.showAlert(title: title, message: message, actions: actions)
    }
    
    func showAlert(title: String, message: String, actions: [UIAlertAction]) {
        let showAlertBlock = {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            actions.forEach { alertController.addAction($0) }
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
            }
        }
        if presentedViewController != nil {
            dismiss(animated: true) {
                showAlertBlock()
            }
        } else {
            showAlertBlock()
        }
    }
}

// MARK: - ScanDelegate
@available(iOS 12.0, *)
extension FaceppScanningViewController: ScanDelegate {
    var referenceObjectToMerge: ARReferenceObject? {
        get {
            return _referenceObjectToMerge
        }
        set {
            _referenceObjectToMerge = newValue
        }
    }
    
    func scan(_ scan: Scan, willUpdateNewState state: Scan.State) {
        // Check that preconditions for the state change are met.
        switch state {
        case .ready:
            break
        case .defineBoundingBox where !scan.boundingBoxExists && !scan.ghostBoundingBoxExists:
            print("Error: Ghost bounding box not yet created.")
            return
        case .scanning where !scan.boundingBoxExists, .adjustingOrigin where !scan.boundingBoxExists:
            print("Error: Bounding box not yet created.")
            return
        case .scanning where scan.state == .defineBoundingBox && !scan.isReasonablySized,
             .adjustingOrigin where scan.state == .scanning && !scan.isReasonablySized:
            
            let title = "Scanned object too big or small"
            let message = """
               Each dimension of the bounding box should be at least 1 centimeters and not exceed 5 meters.
               In addition, the volume of the bounding box should be at least 500 cubic cm.
               Do you want to go back and adjust the bounding box of the scanned object?
               """
            let previousState = scan.state
            showAlert(title: title, message: message, buttonTitle: "Yes", showCancel: true) { _ in
                scan.state = previousState
            }
        case .scanning:
            // When entering the scanning state, take a screenshot of the object to be scanned.
            // This screenshot will later be saved in the *.arobject file
            scan.createScreenshot()
        case .adjustingOrigin where scan.state == .scanning && scan.qualityIsLow:
            let title = "Not enough detail"
            let message = """
            This scan has not enough detail (it contains \(scan.pointCloud.count) features - aim for at least \(Scan.minFeatureCount)).
            It is unlikely that a good reference object can be generated.
            Do you want to go back and continue the scan?
            """
            showAlert(title: title, message: message, buttonTitle: "Yes", showCancel: true) { _ in
                scan.state = .scanning
            }
        case .adjustingOrigin where scan.state == .scanning:
            if let boundingBox = scan.scannedObject.boundingBox, boundingBox.progressPercentage < 100 {
                let title = "Scan not complete"
                let message = """
                The object was not scanned from all sides, scanning progress is \(boundingBox.progressPercentage)%.
                It is likely that it won't detect from all angles.
                Do you want to go back and continue the scan?
                """
                showAlert(title: title, message: message, buttonTitle: "Yes", showCancel: true) { _ in
                    scan.state = .scanning
                }
            }
        default:
            break
        }
    }
    
    func scan(_ scan: Scan, createReferenceObject
        creationFinished: @escaping (ARReferenceObject?) -> Void) {
        guard let boundingBox = scan.scannedObject.boundingBox,
            let origin = scan.scannedObject.origin else {
                print("Error: No bounding box or object origin present.")
                creationFinished(nil)
                return
        }
        // Extract the reference object based on the position & orientation of the bounding box.
        sceneView.session.createReferenceObject(
            transform: boundingBox.simdWorldTransform,
            center: SIMD3<Float>(), extent: boundingBox.extent,
            completionHandler: { object, error in
                guard let referenceObject = object else {
                    print("Error: Failed to create reference object. \(error!.localizedDescription)")
                    return creationFinished(nil)
                }
                // Adjust the object's origin with the user-provided transform.
                scan.scannedReferenceObject = referenceObject.applyingTransform(origin.simdTransform)
                scan.scannedReferenceObject!.name = scan.scannedObject.scanName
                guard let referenceObjectToMerge = self.referenceObjectToMerge else {
                    return creationFinished(scan.scannedReferenceObject)
                }
                self.referenceObjectToMerge = nil
                // Show activity indicator during the merge.
                self.showAlert(title: "", message: "Merging previous scan into this scan...", buttonTitle: nil)
                // Try to merge the object which was just scanned with the existing one.
                scan.scannedReferenceObject?.mergeInBackground(with: referenceObjectToMerge, completion: { (mergedObject, error) in
                    if let mergedObject = mergedObject {
                        scan.scannedReferenceObject = mergedObject
                        self.showAlert(title: "Merge successful",
                                       message: "The previous scan has been merged into this scan.", buttonTitle: "OK")
                        creationFinished(scan.scannedReferenceObject)
                    } else {
                        print("Error: Failed to merge scans. \(error?.localizedDescription ?? "")")
                        let message = """
                                   Merging the previous scan into this scan failed. Please make sure that
                                   there is sufficient overlap between both scans and that the lighting
                                   environment hasn't changed drastically.
                                   Which scan do you want to use for testing?
                                   """
                        let thisScan = UIAlertAction(title: "Use This Scan", style: .default) { _ in
                            creationFinished(scan.scannedReferenceObject)
                        }
                        let previousScan = UIAlertAction(title: "Use Previous Scan", style: .default) { _ in
                            scan.scannedReferenceObject = referenceObjectToMerge
                            creationFinished(scan.scannedReferenceObject)
                        }
                        self.showAlert(title: "Merge failed", message: message, actions: [thisScan, previousScan])
                    }
                })
        })
    }
    
    func scan(_ scan: Scan, lowLightWarning: ARFrame) {
        guard !hasWarnedAboutLowLight else {
            return
        }
        hasWarnedAboutLowLight = true
        let title = "Too dark for scanning"
        let message = "Consider moving to an environment with more light."
        showAlert(title: title, message: message)
    }
}

@available(iOS 12.0, *)
extension FaceppScanningViewController: DetectedObjectDelegate, ObjectOriginDelegate {
    func detectedObject(_ object: DetectedObject, prepare model: SCNNode) {
        sceneView.prepare([model]) { _ in
            object.addChildNode(model)
        }
    }
    
    func objectOrigin(_ objectOrigin: ObjectOrigin, prepare model: SCNNode) {
        sceneView.prepare([model]) { _ in
            objectOrigin.addChildNode(model)
        }
    }
}
