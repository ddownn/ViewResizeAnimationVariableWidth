//
//  ViewController.swift
//  ViewResizeAnimationVariableWidth
//
//  Created by Paul Bryan on 7/2/20.
//  Copyright © 2020 Paul Bryan. All rights reserved.
//

import UIKit

let pi = CGFloat.pi
let halfPi = CGFloat.pi / 2
let twoPi: CGFloat = .pi * 2

class ViewController: UIViewController {

	@IBOutlet weak var containerViewWidthSmall: NSLayoutConstraint!
	@IBOutlet weak var containerViewWidthLarge: NSLayoutConstraint!

	@IBOutlet var containerView: ContainerView!
	var containerLayer: ContainerLayer!

	@IBOutlet weak var rotateButton: UIButton!
	@IBOutlet weak var resizeButton: UIButton!
	var isLarge = false

	override func loadView() {
		super.loadView()
		containerView.translatesAutoresizingMaskIntoConstraints = false
		containerView.contentMode = .redraw
		containerView.backgroundColor = .clear
		resizeButton.translatesAutoresizingMaskIntoConstraints = false
		resizeButton.addTarget(self, action: #selector(self.resize(sender:)), for: .touchUpInside)
		rotateButton.translatesAutoresizingMaskIntoConstraints = false
		rotateButton.addTarget(self, action: #selector(self.rotate(sender:)), for: .touchUpInside)
		containerLayer = containerView.layer as? ContainerLayer
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		self.isLarge.toggle()
		self.updateConstraints()
		self.view.layoutIfNeeded()
		UIView.animateKeyframes(withDuration: coordinator.transitionDuration, delay: 0, animations: {
			UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
				self.resize(sender: self)
			})
			self.view.layoutIfNeeded()
		})
	}

	func updateConstraints() {
		containerViewWidthSmall.priority = isLarge ? .defaultHigh-1 : .defaultHigh+1
		self.containerLayer.setNeedsDisplay()
		self.view.layoutIfNeeded()
	}

	@objc func resize(sender: Any) {
		self.view.layoutIfNeeded()
		self.isLarge.toggle()
		UIView.animateKeyframes(withDuration: 0.3, delay: 0, animations: {
			UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
				self.updateConstraints()
			})
			self.view.layoutIfNeeded()
		})
	}

	@objc func rotate(sender: Any) {
		self.view.layoutIfNeeded()
		self.isLarge.toggle()
		UIView.animateKeyframes(withDuration: 0.3, delay: 0, animations: {
			UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
				self.containerLayer.transform = CATransform3DRotate(self.containerLayer.transform, pi/2, 0, 0, 1)
			})
			self.view.layoutIfNeeded()
		})
	}
}
