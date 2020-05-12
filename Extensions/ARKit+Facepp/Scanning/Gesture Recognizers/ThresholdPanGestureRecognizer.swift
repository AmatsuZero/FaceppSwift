/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A custom pan gesture reconizer that fires only when a threshold is passed.
*/

import UIKit.UIGestureRecognizerSubclass
import ARKit

protocol ThresholdPanGestureRecognizerDelegate: class {
    func thresholdPanGestureRecognizer(_ recognizer: ThresholdPanGestureRecognizer,
                                       touchBegan touches: Set<UITouch>,
                                       with event: UIEvent)
}

class ThresholdPanGestureRecognizer: UIPanGestureRecognizer {
    
    weak var threshholdDelegate: ThresholdPanGestureRecognizerDelegate?
    
    /// The threshold in screen pixels after which this gesture is detected.
    private static var threshold: CGFloat = 30
    
    /// Indicates whether the currently active gesture has exceeeded the threshold.
    private(set) var isThresholdExceeded = false
    
    /// The initial touch location when this gesture started.
    private var initialLocation: CGPoint = .zero
    
    /// The offset in screen space to the manipulated object
    private var offsetToObject: CGPoint = .zero
    
    /// Observe when the gesture's `state` changes to reset the threshold.
    override var state: UIGestureRecognizer.State {
        didSet {
            switch state {
            case .possible, .began, .changed:
                break
            default:
                // Reset variables.
                isThresholdExceeded = false
                initialLocation = .zero
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        initialLocation = location(in: view)
        self.threshholdDelegate?.thresholdPanGestureRecognizer(self, touchBegan: touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        let translationMagnitude = translation(in: view).length
        
        if !isThresholdExceeded && translationMagnitude > ThresholdPanGestureRecognizer.threshold {
            isThresholdExceeded = true
            
            // Set the overall translation to zero as the gesture should now begin.
            setTranslation(.zero, in: view)
        }
    }
        
    override func location(in view: UIView?) -> CGPoint {
        switch state {
        case .began, .changed:
            let correctedLocation = CGPoint(x: initialLocation.x + translation(in: view).x,
                                            y: initialLocation.y + translation(in: view).y)
            return correctedLocation
        default:
            return super.location(in: view)
        }
    }
    
    func offsetLocation(in view: UIView?) -> CGPoint {
        return location(in: view) + offsetToObject
    }
}

extension ThresholdPanGestureRecognizer {
    func updateOffsetToObject(_ objectPos: SCNVector3) {
        offsetToObject.x = CGFloat(objectPos.x) - initialLocation.x
        offsetToObject.y = CGFloat(objectPos.y) - initialLocation.y
    }
}
