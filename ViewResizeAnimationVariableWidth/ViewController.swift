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

extension CGRect {
	var center: CGPoint { return CGPoint(x: self.midX, y: self.midY)}
}

class ViewController: UIViewController {

	var displayLink: CADisplayLink!

	@IBOutlet weak var containerViewWidthSmall: NSLayoutConstraint!
	@IBOutlet weak var containerViewWidthLarge: NSLayoutConstraint!

	@IBOutlet var containerView: ContainerView!
	var containerLayer: ContainerLayer!

	@IBOutlet weak var rotateButton: UIButton!
	@IBOutlet weak var resizeButton: UIButton!

	var isLarge = false

	override func loadView() {
		super.loadView()

		displayLink = CADisplayLink(target: self, selector: #selector(animationDidUpdate))
		displayLink.preferredFramesPerSecond = 30
		displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.default)

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

		self.view.layoutIfNeeded()
		UIView.animateKeyframes(withDuration: coordinator.transitionDuration, delay: 0, options: .calculationModePaced, animations: {
			UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
				self.resize(sender: self)
			})
			self.view.layoutIfNeeded()
		})
	}

	@objc func animationDidUpdate(displayLink: CADisplayLink) {
		let presentationLayer = self.containerLayer.shape.presentation()!

		let newPosition = presentationLayer.position
		print(newPosition)
//		self.containerLayer.shape.position = newPosition
	}

	func updateConstraints() {
		containerViewWidthSmall.priority = isLarge ? .defaultHigh-1 : .defaultHigh+1
		self.containerLayer.setNeedsDisplay()
		self.view.layoutIfNeeded()
	}

	@objc func resize(sender: Any) {

		let oldLoc = self.containerLayer.shape.position

		self.view.layoutIfNeeded()
		self.isLarge.toggle()

		self.updateConstraints()
		self.view.layoutIfNeeded()

		print(oldLoc, self.containerLayer.unitLoc)

		let anim = CABasicAnimation(keyPath: "position")
		anim.fromValue = oldLoc
		anim.toValue = self.containerLayer.unitLoc

		self.containerLayer.shape.add(anim, forKey: "position")
		self.containerLayer.shape.layoutIfNeeded()
		self.containerLayer.updateShape()
//		self.containerLayer.shape.position = self.containerLayer.unitLoc
//		self.containerLayer.shape.updatePath()

		self.view.layoutIfNeeded()
	}

	@objc func rotate(sender: Any) {
		self.view.layoutIfNeeded()
		self.isLarge.toggle()
		UIView.animateKeyframes(withDuration: 1, delay: 0, options: .calculationModeLinear, animations: {
			UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
				self.containerLayer.transform = CATransform3DRotate(self.containerLayer.transform, pi/2, 0, 0, 1)
			})
			self.view.layoutIfNeeded()
		})
	}
}
