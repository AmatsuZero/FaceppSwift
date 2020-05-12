/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Manages the major steps in scanning an object.
 */

import Foundation
import UIKit
import ARKit

@available(iOS 12.0, *)
protocol ScanDelegate: class {
    var referenceObjectToMerge: ARReferenceObject? { get set }
    func scan(_ scan: Scan, willUpdateNewState: Scan.State)
    /// - Tag: ExtractReferenceObject
    func scan(_ scan: Scan, createReferenceObject creationFinished: @escaping (ARReferenceObject?) -> Void)
    func scan(_ scan: Scan, lowLightWarning: ARFrame)
}

@available(iOS 12.0, *)
class Scan {
    static let stateChangedNotification = Notification.Name("ScanningStateChanged")
    static let stateUserInfoKey = "ScanState"
    static let objectCreationInterval: CFTimeInterval = 1.0
    
    enum State {
        case ready
        case defineBoundingBox
        case scanning
        case adjustingOrigin
    }
    
    // The current state the scan is in
    private var stateValue: State = .ready
    var state: State {
        get {
            return stateValue
        }
        set {
            // Check that preconditions for the state change are met.
            delegate?.scan(self, willUpdateNewState: newValue)
            // Apply the new state
            stateValue = newValue
            NotificationCenter.default.post(name: Scan.stateChangedNotification,
                                            object: self,
                                            userInfo: [Scan.stateUserInfoKey: newValue])
        }
    }
    
    var objectToManipulate: SCNNode? {
        if state == .adjustingOrigin {
            return scannedObject.origin
        } else {
            return scannedObject.eitherBoundingBox
        }
    }
    
    weak var delegate: ScanDelegate?
    
    // The object which we want to scan
    private(set) var scannedObject: ScannedObject
    
    // The result of this scan, an ARReferenceObject
    var scannedReferenceObject: ARReferenceObject?
    
    // The node for visualizing the point cloud.
    private(set) var pointCloud: ScannedPointCloud
    
    private var sceneView: ARSCNView
    
    private var isBusyCreatingReferenceObject = false
    
    private(set) var screenshot = UIImage()
    
    private var isFirstScan: Bool {
        return delegate?.referenceObjectToMerge == nil
    }
    
    static let minFeatureCount = 100
    
    init(_ sceneView: ARSCNView) {
        self.sceneView = sceneView
        
        scannedObject = ScannedObject(sceneView)
        pointCloud = ScannedPointCloud()
        self.sceneView.scene.rootNode.addChildNode(self.scannedObject)
        self.sceneView.scene.rootNode.addChildNode(self.pointCloud)
    }
    
    deinit {
        self.scannedObject.removeFromParentNode()
        self.pointCloud.removeFromParentNode()
    }

    func updateOnEveryFrame(_ frame: ARFrame) {
        if state == .ready || state == .defineBoundingBox {
            if let points = frame.rawFeaturePoints {
                // Automatically adjust the size of the bounding box.
                self.scannedObject.fitOverPointCloud(points)
            }
        }
        
        if state == .ready || state == .defineBoundingBox || state == .scanning {
            if let lightEstimate = frame.lightEstimate, lightEstimate.ambientIntensity < 500, isFirstScan {
                delegate?.scan(self, lowLightWarning: frame)
            }
            
            // Try a preliminary creation of the reference object based off the current
            // bounding box & update the point cloud visualization based on that.
            if let boundingBox = scannedObject.eitherBoundingBox {
                // Note: Create a new preliminary reference object in regular intervals.
                //       Creating the reference object is asynchronous and likely
                //       takes some time to complete. Avoid calling it again before
                //       enough time has passed and while we still wait for the
                //       previous call to complete.
                let now = CACurrentMediaTime()
                if now - timeOfLastReferenceObjectCreation > Scan.objectCreationInterval,
                    !isBusyCreatingReferenceObject {
                    timeOfLastReferenceObjectCreation = now
                    isBusyCreatingReferenceObject = true
                    sceneView.session.createReferenceObject(transform: boundingBox.simdWorldTransform,
                                                            center: SIMD3<Float>(),
                                                            extent: boundingBox.extent) { object, _ in
                                                                if let referenceObject = object {
                                                                    // Pass the feature points to the point cloud visualization.
                                                                    self.pointCloud.update(with: referenceObject.rawFeaturePoints, localFor: boundingBox)
                                                                }
                                                                self.isBusyCreatingReferenceObject = false
                    }
                }
                
                // Update the point cloud with the current frame's points as well
                if let currentPoints = frame.rawFeaturePoints {
                    pointCloud.update(with: currentPoints)
                }
            }
        }
        
        // Update bounding box side coloring to visualize scanning coverage
        if state == .scanning {
            scannedObject.boundingBox?.highlightCurrentTile()
            scannedObject.boundingBox?.updateCapturingProgress()
        }
        
        scannedObject.updateOnEveryFrame()
        pointCloud.updateOnEveryFrame()
    }
    
    var timeOfLastReferenceObjectCreation = CACurrentMediaTime()
    
    var qualityIsLow: Bool {
        return pointCloud.count < Scan.minFeatureCount
    }
    
    var boundingBoxExists: Bool {
        return scannedObject.boundingBox != nil
    }
    
    var ghostBoundingBoxExists: Bool {
        return scannedObject.ghostBoundingBox != nil
    }
    
    var isReasonablySized: Bool {
        guard let boundingBox = scannedObject.boundingBox else {
            return false
        }
        
        // The bounding box should not be too small and not too large.
        // Note: 3D object detection is optimized for tabletop scenarios.
        let validSizeRange: ClosedRange<Float> = 0.01...5.0
        if validSizeRange.contains(boundingBox.extent.x) && validSizeRange.contains(boundingBox.extent.y) &&
            validSizeRange.contains(boundingBox.extent.z) {
            // Check that the volume of the bounding box is at least 500 cubic centimeters.
            let volume = boundingBox.extent.x * boundingBox.extent.y * boundingBox.extent.z
            return volume >= 0.0005
        }
        
        return false
    }
    
    func createScreenshot() {
        guard let frame = self.sceneView.session.currentFrame else {
            print("Error: Failed to create a screenshot - no current ARFrame exists.")
            return
        }
        
        var orientation: UIImage.Orientation = .right
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = .right
        case .portraitUpsideDown:
            orientation = .left
        case .landscapeLeft:
            orientation = .up
        case .landscapeRight:
            orientation = .down
        default:
            break
        }
        
        let ciImage = CIImage(cvPixelBuffer: frame.capturedImage)
        let context = CIContext()
        if let cgimage = context.createCGImage(ciImage, from: ciImage.extent) {
            screenshot = UIImage(cgImage: cgimage, scale: 1.0, orientation: orientation)
        }
    }
}

@available(iOS 12.0, *)
extension Scan: ThresholdPanGestureRecognizerDelegate {
    func thresholdPanGestureRecognizer(_ recognizer: ThresholdPanGestureRecognizer,
                                       touchBegan touches: Set<UITouch>,
                                       with event: UIEvent) {
        guard let object = objectToManipulate else {
            return
        }
        let objectPos = sceneView.projectPoint(object.worldPosition)
        recognizer.updateOffsetToObject(objectPos)
    }
    
    func handleDidTwoFingerPan(_ gesture: ThresholdPanGestureRecognizer) {
        if state == .ready {
            state = .defineBoundingBox
        }
        if state == .defineBoundingBox || state == .scanning {
            switch gesture.state {
            case .possible:
                break
            case .began where gesture.numberOfTouches == 2:
                scannedObject.boundingBox?
                    .startGroundPlaneDrag(screenPos: gesture.offsetLocation(in: sceneView))
            case .changed where gesture.isThresholdExceeded && gesture.numberOfTouches == 2:
                scannedObject.boundingBox?
                    .updateGroundPlaneDrag(screenPos: gesture.offsetLocation(in: sceneView))
            case .failed, .cancelled, .ended:
                scannedObject.boundingBox?.endGroundPlaneDrag()
            default:
                break
            }
        } else if state == .adjustingOrigin {
            switch gesture.state {
            case .possible:
                break
            case .began where gesture.numberOfTouches == 2:
                scannedObject.origin?
                    .startPlaneDrag(screenPos: gesture.offsetLocation(in: sceneView))
            case .changed where gesture.isThresholdExceeded && gesture.numberOfTouches == 2:
                scannedObject.origin?
                    .updatePlaneDrag(screenPos: gesture.offsetLocation(in: sceneView))
            case .changed:
                break
            case .failed, .cancelled, .ended:
                scannedObject.origin?.endPlaneDrag()
            default:
                break
            }
        }
    }
}

@available(iOS 12.0, *)
extension Scan {
    func handleDidPinch(_ gesture: ThresholdPinchGestureRecognizer) {
        if state == .ready {
            state = .defineBoundingBox
        }
        
        if state == .defineBoundingBox || state == .scanning {
            switch gesture.state {
            case .possible, .began:
                break
            case .changed where gesture.isThresholdExceeded:
                scannedObject.scaleBoundingBox(scale: gesture.scale)
                gesture.scale = 1
            case .changed:
                break
            default:
                break
            }
        } else if state == .adjustingOrigin {
            switch gesture.state {
            case .possible, .began:
                break
            case .changed where gesture.isThresholdExceeded:
                scannedObject.origin?.updateScale(Float(gesture.scale))
                gesture.scale = 1
            default:
                break
            }
        }
    }
    
    func handleDidOneFingerPan(_ gesture: UIPanGestureRecognizer) {
        if state == .ready {
            state = .defineBoundingBox
        }
        if state == .defineBoundingBox || state == .scanning {
            switch gesture.state {
            case .began:
                scannedObject.boundingBox?.startSidePlaneDrag(screenPos: gesture.location(in: sceneView))
            case .changed:
                scannedObject.boundingBox?.updateSidePlaneDrag(screenPos: gesture.location(in: sceneView))
            case .failed, .cancelled, .ended:
                scannedObject.boundingBox?.endSidePlaneDrag()
            default:
                break
            }
        } else if state == .adjustingOrigin {
            switch gesture.state {
            case .began:
                scannedObject.origin?.startAxisDrag(screenPos: gesture.location(in: sceneView))
            case .changed:
                scannedObject.origin?.updateAxisDrag(screenPos: gesture.location(in: sceneView))
            case .failed, .cancelled, .ended:
                scannedObject.origin?.endAxisDrag()
            default:
                break
            }
        }
    }
    
    func handleDidRotate(_ gesture: ThresholdRotationGestureRecognizer) {
        if state == .ready {
            state = .defineBoundingBox
        }
        if state == .defineBoundingBox || state == .scanning {
            if gesture.state == .changed {
                scannedObject.rotateOnYAxis(by: -Float(gesture.rotationDelta))
            }
        } else if state == .adjustingOrigin {
            if gesture.state == .changed {
                scannedObject.origin?
                    .rotateWithSnappingOnYAxis(by: -Float(gesture.rotationDelta))
            }
        }
    }
    
    func handleDidLongPress(_ gesture: UILongPressGestureRecognizer) {
        if state == .ready {
            state = .defineBoundingBox
        }
        
        if state == .defineBoundingBox || state == .scanning {
            switch gesture.state {
            case .began:
                scannedObject.boundingBox?.startSideDrag(screenPos: gesture.location(in: sceneView))
            case .changed:
                scannedObject.boundingBox?.updateSideDrag(screenPos: gesture.location(in: sceneView))
            case .failed, .cancelled, .ended:
                scannedObject.boundingBox?.endSideDrag()
            default:
                break
            }
        } else if state == .adjustingOrigin {
            switch gesture.state {
            case .began:
                scannedObject.origin?.startAxisDrag(screenPos: gesture.location(in: sceneView))
            case .changed:
                scannedObject.origin?.updateAxisDrag(screenPos: gesture.location(in: sceneView))
            case .failed, .cancelled, .ended:
                scannedObject.origin?.endAxisDrag()
           default:
                break
            }
        }
    }
    
    func handleDidTap(_ gesture: UITapGestureRecognizer) {
        if state == .ready {
            state = .defineBoundingBox
        }
        if state == .defineBoundingBox || state == .scanning {
            if gesture.state == .ended {
                scannedObject.createOrMoveBoundingBox(screenPos: gesture.location(in: sceneView))
            }
        } else if state == .adjustingOrigin {
            if gesture.state == .ended {
                scannedObject.origin?.flashOrReposition(screenPos: gesture.location(in: sceneView))
            }
        }
    }
}

@available(iOS 12.0, *)
extension FaceppScanningViewController: BoundingBoxDelegate {
    func currentFrame(_ boundingBox: BoundingBox) -> ARFrame? {
        return sceneView.session.currentFrame
    }
    
    func boundingBox(_ boundingBox: BoundingBox, tryToAlignWithPlanes anchors: [ARAnchor]) {
        guard !boundingBox.hasBeenAdjustedByUser, scan?.state == .defineBoundingBox else { return }
        
        let bottomCenter = SIMD3<Float>(boundingBox.simdPosition.x,
                                        boundingBox.simdPosition.y - boundingBox.extent.y / 2,
                                        boundingBox.simdPosition.z)

        var distanceToNearestPlane = Float.greatestFiniteMagnitude
        var offsetToNearestPlaneOnY: Float = 0
        var planeFound = false
        
        // Check which plane is nearest to the bounding box.
        for anchor in anchors {
            guard let plane = anchor as? ARPlaneAnchor else {
                continue
            }
            guard let planeNode = sceneView.node(for: plane) else {
                continue
            }
            
            // Get the position of the bottom center of this bounding box in the plane's coordinate system.
            let bottomCenterInPlaneCoords = planeNode.simdConvertPosition(bottomCenter, from: boundingBox.parent)
            
            // Add 10% tolerance to the corners of the plane.
            let tolerance: Float = 0.1
            let minX = plane.center.x - plane.extent.x / 2 - plane.extent.x * tolerance
            let maxX = plane.center.x + plane.extent.x / 2 + plane.extent.x * tolerance
            let minZ = plane.center.z - plane.extent.z / 2 - plane.extent.z * tolerance
            let maxZ = plane.center.z + plane.extent.z / 2 + plane.extent.z * tolerance
            
            guard (minX...maxX).contains(bottomCenterInPlaneCoords.x) && (minZ...maxZ).contains(bottomCenterInPlaneCoords.z) else {
                continue
            }
            
            let offsetToPlaneOnY = bottomCenterInPlaneCoords.y
            let distanceToPlane = abs(offsetToPlaneOnY)
            
            if distanceToPlane < distanceToNearestPlane {
                distanceToNearestPlane = distanceToPlane
                offsetToNearestPlaneOnY = offsetToPlaneOnY
                planeFound = true
            }
        }
        
        guard planeFound else { return }
        
        // Check that the object is not already on the nearest plane (closer than 1 mm).
        let epsilon: Float = 0.001
        guard distanceToNearestPlane > epsilon else { return }
        
        // Check if the nearest plane is close enough to the bounding box to "snap" to that
        // plane. The threshold is half of the bounding box extent on the y axis.
        let maxDistance = boundingBox.extent.y / 2
        if distanceToNearestPlane < maxDistance && offsetToNearestPlaneOnY > 0 {
            // Adjust the bounding box position & extent such that the bottom of the box
            // aligns with the plane.
            boundingBox.simdPosition.y -= offsetToNearestPlaneOnY / 2
            boundingBox.extent.y += offsetToNearestPlaneOnY
        }
    }
}
