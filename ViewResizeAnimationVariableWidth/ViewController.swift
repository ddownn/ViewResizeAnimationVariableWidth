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
//		containerView.contentMode = .redraw
		containerView.backgroundColor = .clear

		toggleButton.translatesAutoresizingMaskIntoConstraints = false
		toggleButton.addTarget(self, action: #selector(self.toggleSize), for: .touchUpInside)

		containerLayer = containerView.layer as? ContainerLayer
	}

	override func viewDidLoad() {
		super.viewDidLoad()

	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
//		print("viewDidLayoutSubviews(): \(containerView.bounds)\n")
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		self.isLarge.toggle()
		self.updateConstraints()

	}

	func updateConstraints() {
		containerViewWidthSmall.priority = isLarge ? .defaultHigh-1 : .defaultHigh+1
	}

	@objc func toggleSize(sender: Any) {
		self.view.layoutIfNeeded()

		isLarge.toggle()
		self.updateConstraints()

		animate(self.containerLayer)
		self.containerLayer.transform = CATransform3DRotate(self.containerLayer.transform, pi/2, 0, 0, 1)

		self.view.layoutIfNeeded()

	}

	func animate(_ layer: CALayer) {
		let startValue = layer.transform
		let endValue = CATransform3DRotate(startValue, pi/2, 0, 0, 1)
		let ba = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
		ba.duration = 1
		let clunk = CAMediaTimingFunction(controlPoints:0.9, 0.1, 0.7, 0.9)
		ba.timingFunction = clunk
		ba.fromValue = startValue
		ba.toValue = endValue
		layer.add(ba, forKey: nil)
		layer.add(ba, forKey: nil)
	}
}
