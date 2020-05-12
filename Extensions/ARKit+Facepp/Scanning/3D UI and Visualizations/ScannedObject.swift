/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A representation of the object being scanned.
*/

import Foundation
import SceneKit
import ARKit

@available(iOS 12.0, *)
protocol ScannedObjectDelegate: class {
    func screenCenter(_ scannedObejct: ScannedObject) -> CGPoint
    func modelURL(_ scannedObejct: ScannedObject) -> URL?
}

@available(iOS 12.0, *)
class ScannedObject: SCNNode {

    static let positionChangedNotification = Notification.Name("ScannedObjectPositionChanged")
    static let boundingBoxCreatedNotification = Notification.Name("BoundingBoxWasCreated")
    static let ghostBoundingBoxCreatedNotification = Notification.Name("GhostBoundingBoxWasCreated")
    static let ghostBoundingBoxRemovedNotification = Notification.Name("GhostBoundingBoxWasRemoved")

    private(set) var origin: ObjectOrigin?
    private(set) var boundingBox: BoundingBox?
    private(set) var ghostBoundingBox: BoundingBox?

    private var sceneView: ARSCNView
    
    weak var delegate: ScannedObjectDelegate?

    override var simdPosition: SIMD3<Float> {
        didSet {
            NotificationCenter.default.post(name: ScannedObject.positionChangedNotification,
                                            object: self)
        }
    }

    var eitherBoundingBox: BoundingBox? {
        return boundingBox != nil ? boundingBox : ghostBoundingBox
    }

    var scanName: String

    init(_ sceneView: ARSCNView) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH-mm-ss"
        scanName = "Scan_\(dateFormatter.string(from: Date()))"

        self.sceneView = sceneView
        super.init()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.scanningStateChanged(_:)),
                                               name: Scan.stateChangedNotification,
                                               object: nil)
    }

    func rotateOnYAxis(by angle: Float) {
        self.simdLocalRotate(by: simd_quatf(angle: angle, axis: .y))
        self.boundingBox?.hasBeenAdjustedByUser = true
    }

    func set3DModel(_ url: URL?) {
        self.origin?.set3DModel(url, extentForScaling: boundingBox?.extent)
    }

    func createOrMoveBoundingBox(screenPos: CGPoint) {
        if let boundingBox = self.boundingBox {
            if !boundingBox.isHit(screenPos: screenPos) {
                // Perform a hit test against the feature point cloud.
                guard let result = sceneView.smartHitTest(screenPos) else {
                    print("Warning: Failed to find a position for the bounding box.")
                    return
                }
                self.simdWorldPosition = result.worldTransform.position
            }
        } else {
            createBoundingBox(screenPos: screenPos)
        }
    }

    func createBoundingBoxFromGhost(modelURL: URL?) {
        if let boundingBox = self.ghostBoundingBox {
            self.boundingBox = boundingBox
            boundingBox.opacity = 1.0
            self.constraints = nil
            self.ghostBoundingBox = nil

            let origin = ObjectOrigin(extent: boundingBox.extent, sceneView, modelURL: modelURL)
            boundingBox.addChildNode(origin)
            self.origin = origin

            NotificationCenter.default.post(name: ScannedObject.boundingBoxCreatedNotification, object: nil)
        }
    }

    func fitOverPointCloud(_ pointCloud: ARPointCloud) {
        // Do the automatic adjustment of the bounding box only if the user
        // hasn't adjusted it yet.
        guard let boundingBox = self.boundingBox,
            !boundingBox.hasBeenAdjustedByUser,
            let screenScenter = delegate?.screenCenter(self) else { return }
        
        let hitTestResults = sceneView.hitTest(screenScenter, types: .featurePoint)
        guard !hitTestResults.isEmpty else { return }

        let userFocusPoint = hitTestResults[0].worldTransform.position
        boundingBox.fitOverPointCloud(pointCloud, focusPoint: userFocusPoint)
    }

    func tryToAlignWithPlanes(_ anchors: [ARAnchor]) {
        if let boundingBox = self.boundingBox {
            boundingBox.tryToAlignWithPlanes(anchors)
        }
    }

    func createBoundingBox(screenPos: CGPoint) {
        // Perform a hit test against the feature point cloud.
        guard let result = sceneView.smartHitTest(screenPos) else {
            print("Warning: Failed to find a position for the bounding box.")
            return
        }

        let boundingBox = BoundingBox(sceneView)
        self.boundingBox = boundingBox
        self.addChildNode(boundingBox)

        // Set the initial extent of the bounding box based on the distance to the camera.
        let newExtent = Float(result.distance / 3)
        boundingBox.extent = SIMD3<Float>(repeating: newExtent)

        // Set the position of scanned object to a point on the ray which is offset
        // from the hit test result by half of the bounding boxes' extent.
        let cameraToHit = result.worldTransform.position - sceneView.pointOfView!.simdWorldPosition
        let normalizedDirection = normalize(cameraToHit)
        let boundingBoxOffset = normalizedDirection * newExtent / 2
        self.simdWorldPosition = result.worldTransform.position + boundingBoxOffset
        if let url = delegate?.modelURL(self) {
            let origin = ObjectOrigin(extent: boundingBox.extent, sceneView, modelURL: url)
            boundingBox.addChildNode(origin)
            self.origin = origin
        }
        NotificationCenter.default.post(name: ScannedObject.boundingBoxCreatedNotification, object: nil)
    }

    private func updateOrCreateGhostBoundingBox() {
        // Perform a hit test against the feature point cloud.
        guard let screenCenter = self.delegate?.screenCenter(self),
            let result = sceneView.smartHitTest(screenCenter) else {
            if let ghostBoundingBox = ghostBoundingBox {
                ghostBoundingBox.removeFromParentNode()
                self.ghostBoundingBox = nil
                NotificationCenter.default.post(name: ScannedObject.ghostBoundingBoxRemovedNotification, object: nil)
            }
            return
        }

        let newExtent = Float(result.distance / 3)

        // Set the position of scanned object to a point on the ray which is offset
        // from the hit test result by half of the bounding boxes' extent.
        let cameraToHit = result.worldTransform.position - sceneView.pointOfView!.simdWorldPosition
        let normalizedDirection = normalize(cameraToHit)
        let boundingBoxOffset = normalizedDirection * newExtent / 2
        self.simdWorldPosition = result.worldTransform.position + boundingBoxOffset

        if let boundingBox = ghostBoundingBox {
            boundingBox.extent = SIMD3<Float>(repeating: newExtent)
            // Change the orientation of the bounding box to always face the user.
            if let currentFrame = sceneView.session.currentFrame {
                eulerAngles.y = currentFrame.camera.eulerAngles.y
            }
        } else {
            let boundingBox = BoundingBox(sceneView)
            boundingBox.opacity = 0.25
            self.addChildNode(boundingBox)
            boundingBox.extent = SIMD3<Float>(repeating: newExtent)
            ghostBoundingBox = boundingBox

            NotificationCenter.default.post(name: ScannedObject.ghostBoundingBoxCreatedNotification, object: nil)
        }
    }

    func moveOriginToBottomOfBoundingBox() {
        // Only move the origin to the bottom of the bounding box if it hasn't been
        // repositioned by the user yet.
        guard let boundingBox = boundingBox, let origin = self.origin, !origin.positionHasBeenAdjustedByUser else { return }
        origin.simdPosition.y = -boundingBox.extent.y / 2
    }

    func updatePosition(_ worldPos: SIMD3<Float>) {
        let offset = worldPos - self.simdWorldPosition
        self.simdWorldPosition = worldPos

        if let boundingBox = boundingBox {
            // Adjust the position of the bounding box to compensate for the
            // move, so that the bounding box stays where it was.
            boundingBox.simdWorldPosition -= offset
        }
    }

    func updateOnEveryFrame() {
        if let boundingBox = boundingBox {
            boundingBox.updateOnEveryFrame()

            if boundingBox.simdPosition != SIMD3<Float>(repeating: 0) {
                // Make sure the position of the ScannedObject and its nested
                // BoundingBox is always identical.
                updatePosition(boundingBox.simdWorldPosition)
            }
        } else {
            updateOrCreateGhostBoundingBox()
        }
    }

    func scaleBoundingBox(scale: CGFloat) {
        guard let boundingBox = boundingBox else { return }

        let oldYExtent = boundingBox.extent.y

        boundingBox.extent *= SIMD3<Float>(repeating: Float(scale))
        boundingBox.hasBeenAdjustedByUser = true

        // Correct y position so that the floor of the box remains at the same position.
        let diffOnY = oldYExtent - boundingBox.extent.y
        boundingBox.simdWorldPosition.y -= diffOnY / 2
    }

    @objc
    private func scanningStateChanged(_ notification: Notification) {
        guard let state = notification.userInfo?[Scan.stateUserInfoKey] as? Scan.State else { return }
        switch state {
        case .ready:
            boundingBox?.removeFromParentNode()
            boundingBox = nil
        case .defineBoundingBox:
            if boundingBox == nil,
                let url = delegate?.modelURL(self) {
                createBoundingBoxFromGhost(modelURL: url)
            }
            ghostBoundingBox?.removeFromParentNode()
            ghostBoundingBox = nil
        case .scanning:
            break
        case .adjustingOrigin:
            moveOriginToBottomOfBoundingBox()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
