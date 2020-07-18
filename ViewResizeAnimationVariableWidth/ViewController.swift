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

		let newCenter = self.containerLayer.presentation()!.bounds.center
		let newUnitLoc = CGPoint(x: newCenter.x + cos(containerLayer.angle) * containerLayer.locRadius, y: newCenter.y + sin(containerLayer.angle) * containerLayer.locRadius)
		containerLayer.unitLoc = newUnitLoc

		containerLayer.shape.position = newUnitLoc

		let newSize = self.containerLayer.shape.presentation()!.bounds.size
		containerLayer.shapeSize = newSize
		containerLayer.setNeedsDisplay()
		print(newSize)

	}

	func updateConstraints() {
		containerViewWidthSmall.priority = isLarge ? .defaultHigh-1 : .defaultHigh+1
	}

	@objc func resize(sender: Any) {

		// MARK:- animate containerLayer bounds, shape bounds & shape position

		// capture container bounds value before changing
		let oldContainerBounds = self.containerLayer.bounds

		// capture shape position value before changing
		let oldShapePos = self.containerLayer.shape.position
		// capture shape position value before changing
		let oldShapeBoundsSize = self.containerLayer.shape.bounds.size

		// update the constraints to change the bounds
		isLarge.toggle()
		updateConstraints()
		self.view.layoutIfNeeded()

		// store updated values
		let newContainerBounds = self.containerLayer.bounds
		let newShapePos = self.containerLayer.unitLoc
		let newShapeBoundsSize = self.containerLayer.shape.bounds.size

		// set up the container bounds animation and add it to containerLayer
		let baContainerBounds = CABasicAnimation(keyPath: "bounds")
		baContainerBounds.fromValue = oldContainerBounds
		baContainerBounds.toValue = newContainerBounds
		containerLayer.add(baContainerBounds, forKey: baContainerBounds.keyPath)

		// set up the shape position animation and add it to shape layer
		let baShapePosition = CABasicAnimation(keyPath: "position")
		baShapePosition.fromValue = oldShapePos
		baShapePosition.toValue = newShapePos
		containerLayer.shape.add(baShapePosition, forKey: baShapePosition.keyPath)

		// set up the shape bounds animation and add it to shape layer
		let baShapeBounds = CABasicAnimation(keyPath: "bounds")
		baShapeBounds.fromValue = oldShapeBoundsSize
		baShapeBounds.toValue = newShapeBoundsSize
		containerLayer.shape.add(baShapeBounds, forKey: baShapeBounds.keyPath)

		containerLayer.setNeedsLayout()
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
