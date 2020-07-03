//
//  ViewController.swift
//  ViewResizeAnimationVariableWidth
//
//  Created by Paul Bryan on 7/2/20.
//  Copyright © 2020 Paul Bryan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	var safeAreaLG = UILayoutGuide()
	var lg = UILayoutGuide()

	@IBOutlet weak var containerViewWidthSmall: NSLayoutConstraint!

	@IBOutlet var containerView: ContainerView!
	var containerLayer: ContainerLayer!

	@IBOutlet weak var toggleButton: UIButton!
	var isLarge = false

	override func loadView() {
		super.loadView()

		containerView.translatesAutoresizingMaskIntoConstraints = false
//		containerView.contentMode = .scaleToFill
		containerView.backgroundColor = .clear

		toggleButton.translatesAutoresizingMaskIntoConstraints = false
		toggleButton.addTarget(self, action: #selector(self.toggleSize), for: .touchUpInside)

		containerLayer = containerView.layer as? ContainerLayer
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		applyConstraints()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
//		print("viewDidLayoutSubviews(): \(containerView.bounds)\n")
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		isLarge.toggle()
		updateConstraints()
		
	}

	func updateConstraints() {
		if isLarge {
			containerViewWidthSmall.priority = .defaultHigh-1
		} else {
			containerViewWidthSmall.priority = .defaultHigh+1
		}

		self.view.needsUpdateConstraints()
	}

	@objc func toggleSize(sender: Any) {
		self.view.layoutIfNeeded()
		isLarge.toggle()

//		CATransaction.setAnimationDuration(2)
//		CATransaction.setDisableActions(true)
//
////		print("toggleSize() - containerView.bounds: \(containerView.bounds)")
//		updateConstraints()
//		self.view.layoutIfNeeded()
//
//		CATransaction.commit()

//		self.containerLayer.setNeedsDisplay()

//		self.view.needsUpdateConstraints()
//		self.view.setNeedsLayout()

		self.containerView.layoutIfNeeded()
		UIView.animate(withDuration: 1, animations: { self.updateConstraints() })
		self.containerView.layoutIfNeeded()
	}



	func animate() {
		let startValue = containerLayer.transform
		let endValue = CATransform3DRotate(startValue, pi/2, 0, 0, 1)
		let ba = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
		let clunk = CAMediaTimingFunction(controlPoints:0.9, 0.1, 0.7, 0.9)
		ba.timingFunction = clunk
		ba.fromValue = startValue
		ba.toValue = endValue
		self.containerLayer.add(ba, forKey: nil)

	}

	func applyConstraints() {

		//MARK:- containerView constraints

		// required
//		let containerViewAspect = containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor)
//		containerViewAspect.priority = .required
//		containerViewAspect.isActive = true

		// variable priority
//		containerViewLarge = containerView.widthAnchor.constraint(equalToConstant: 350)
//		containerViewSmall = containerView.widthAnchor.constraint(equalToConstant: 200)

//		for c in [containerViewLarge, containerViewSmall] {
//			print("apply variable constraints")
//			c?.priority = UILayoutPriority.defaultHigh
//			c?.isActive = true
//		}
	}
}

