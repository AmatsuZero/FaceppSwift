//
//  ThreeDimensionViewController.swift
//  Example
//
//  Created by 姜振华 on 2020/3/28.
//  Copyright © 2020 FaceppSwift. All rights reserved.
//

import UIKit
import FaceppSwift
import SnapKit
import SceneKit
import WebKit

class AlphaAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let isPresentation: Bool

    init(isPresentation: Bool) {
        self.isPresentation = isPresentation
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(UINavigationController.hideShowBarDuration)
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let controller = self.isPresentation
            ? transitionContext.viewController(forKey: .to)
            : transitionContext.viewController(forKey: .from) else {
                return
        }
        if isPresentation {
            transitionContext.containerView.addSubview(controller.view)
        }
        let initialAlpha: CGFloat = isPresentation ? 0 : 1
        let finalAlpha: CGFloat = isPresentation ? 1 : 0
        let duration = transitionDuration(using: transitionContext)
        controller.view.frame = transitionContext.finalFrame(for: controller)
        controller.view.alpha = initialAlpha
        UIView.animate(withDuration: duration, animations: {
            controller.view.alpha = finalAlpha
        }, completion: { finised in
            transitionContext.completeTransition(finised)
        })
    }
}

class CentralModalPresentaionController: UIPresentationController {

    var mask = UIView()
    let targetSize: CGSize

    init(presentedViewController: UIViewController,
         presentingViewController: UIViewController?,
         size: CGSize) {
        targetSize = size
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        mask.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        mask.alpha = 0

        let tap = UITapGestureRecognizer(target: self, action: #selector(Self.dismiss))
        mask.addGestureRecognizer(tap)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        let screenSize = UIScreen.main.bounds.size
        var targetFrame = CGRect(origin: .zero, size: targetSize)
        targetFrame.origin.x = (screenSize.width - targetSize.width) / 2
        targetFrame.origin.y = (screenSize.height - targetSize.height) / 2
        return targetFrame
    }

    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(mask, at: 0)
        mask.snp.makeConstraints { $0.edges.equalTo(0) }
        if let coordinator = presentingViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { [weak self] _ in
                self?.mask.alpha = 1
                }, completion: nil)
        } else {
            mask.alpha = 1
        }
    }

    override func dismissalTransitionWillBegin() {
        if let coordinator = presentingViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { [weak self] _ in
                self?.mask.alpha = 0
                }, completion: nil)
        } else {
            mask.alpha = 0
        }
    }

    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        return targetSize
    }

    @objc func dismiss() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}

class ThreeDimensionViewController: UIViewController {

    let sceneView = SCNView()
    let indicator = UIActivityIndicatorView(style: .large)

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
        preferredContentSize = CGSize(width: 284, height: 300)
    }

    var task: URLSessionTask?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view.backgroundColor = .clear

        let closeBtn = UIButton(type: .custom)
        closeBtn.backgroundColor = .clear
        closeBtn.setImage(.init(imageLiteralResourceName: "closeBtn"), for: .normal)
        closeBtn.addTarget(self, action: #selector(hide), for: .touchUpInside)
        view.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.bottom.centerX.equalToSuperview()
            make.width.height.equalTo(29)
        }

        sceneView.backgroundColor = .clear
        view.addSubview(sceneView)
        sceneView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(closeBtn.snp.top).offset(-20)
        }
        indicator.color = .white
        sceneView.addSubview(indicator)
        indicator.snp.makeConstraints { $0.edges.equalTo(0) }
    }

    @objc func hide() {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let face = (UIImage(imageLiteralResourceName: "front"),
                    UIImage(imageLiteralResourceName: "left"),
                    UIImage(imageLiteralResourceName: "right"))
        indicator.startAnimating()
        task = UIImage.faceModel(faces: face, needTexture: true, needMTL: true) { [weak self] _, resp in
            guard let self = self,
                let resp = resp,
                let scene = try? resp.getScene() else {
                    return
            }
            DispatchQueue.main.async {
                self.loadScene(scene: scene)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        task?.cancel()
    }

    func loadScene(scene: SCNScene) {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 35)
        scene.rootNode.addChildNode(lightNode)

        // 6: Creating and adding ambien light to scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)

        // Allow user to manipulate camera
        sceneView.allowsCameraControl = true

        // Show FPS logs and timming
        sceneView.showsStatistics = true

        // Set background color
        sceneView.backgroundColor = UIColor.white

        // Allow user translate image
        if #available(iOS 11.0, *) {
            sceneView.cameraControlConfiguration.allowsTranslation = false
        }

        // Set scene settings
        sceneView.scene = scene

        indicator.stopAnimating()
        indicator.removeFromSuperview()
    }
}

extension ThreeDimensionViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let modal = CentralModalPresentaionController(presentedViewController: presented,
                                                      presentingViewController: presenting,
                                                      size: preferredContentSize)
        return modal
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlphaAnimator(isPresentation: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlphaAnimator(isPresentation: false)
    }
}
