//
//  FppAwareViewController.swift
//  Example
//
//  Created by 姜振华 on 2020/4/21.
//  Copyright © 2020 FaceppSwift. All rights reserved.
//

import UIKit
import SnapKit

class FppAwareViewContrller: UIViewController {

    let avatarImageView = UIImageView()

    var isOpen = false

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        preferredContentSize = CGSize(width: 160, height: 160)
        modalPresentationStyle = .custom
        transitioningDelegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
        avatarImageView.image = UIImage(named: "AwareTest")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        avatarImageView.layer.masksToBounds = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        avatarImageView.layer.cornerRadius = view.frame.width / 2
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImageView.didFocusOn = {
            print("Did Focus on")
        }
        avatarImageView.debugFppAware = true
    }

    @objc func onTap(_ sender: UITapGestureRecognizer) {
        isOpen.toggle()
        avatarImageView.focusType = isOpen ? .face(needFallback: true) : .none
    }
}

extension FppAwareViewContrller: UIViewControllerTransitioningDelegate {
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
