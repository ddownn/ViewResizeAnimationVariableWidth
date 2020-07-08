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

	var pCenterX: CGFloat!
	var pPosX: CGFloat!

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
		let newCentX = round(newCenter.x)
		let newCentY = round(newCenter.y)

		let newPosition = self.containerLayer.shape.presentation()!.position
		let newPosX = round(newPosition.x)
		let newPosY = round(newPosition.y)

		let new = CGPoint(x: newCenter.x + cos(containerLayer.angle) * containerLayer.locRadius, y: newCenter.y + sin(containerLayer.angle) * containerLayer.locRadius)
		containerLayer.shape.position = new

		if pCenterX != newCentX {
//			print("container cent:(\(newCentX), \(newCentY)) :: shape position:(\(newPosX), \(newPosY))")
//			containerLayer.updateShapePos(newPos: new)
			pCenterX = newCentX
		}
	}

	func updateConstraints() {
		containerViewWidthSmall.priority = isLarge ? .defaultHigh-1 : .defaultHigh+1
	}

	@objc func resize(sender: Any) {

		// MARK:- animate containerLayer bounds & shape position
		// capture bounds value before changing
		let oldBounds = self.containerLayer.bounds
		// capture shape position value before changing
		let oldPos = self.containerLayer.shape.position

		// update the constraints to change the bounds
		isLarge.toggle()
		updateConstraints()
		self.view.layoutIfNeeded()
		let newBounds = self.containerLayer.bounds
		let newPos = self.containerLayer.unitLoc

		// set up the bounds animation and add it to containerLayer
		let baContainerBounds = CABasicAnimation(keyPath: "bounds")
		baContainerBounds.fromValue = oldBounds
		baContainerBounds.toValue = newBounds
		containerLayer.add(baContainerBounds, forKey: "bounds")

		// set up the position animation and add it to shape layer
		let baShapePosition = CABasicAnimation(keyPath: "position")
		baShapePosition.fromValue = oldPos
		baShapePosition.toValue = newPos
		containerLayer.shape.add(baShapePosition, forKey: "position")

		containerLayer.setNeedsLayout()
		self.view.layoutIfNeeded()

		//		if let newCenter = self.containerLayer.presentation()?.bounds.center {
		//
		//			let newFigureDiameter = min(self.containerLayer.bounds.width, self.containerLayer.bounds.height)
		//			let newFigureRadius = newFigureDiameter/2
		//
		//			let newShapeDiameter = round(newFigureDiameter / 5)
		//			let newShapeRadius = newShapeDiameter/2
		//
		//			let newLocRadius = newFigureRadius - newShapeRadius
		//
		//			let newLoc = CGPoint(x: newCenter.x + cos(self.containerLayer.angle) * newLocRadius, y: newCenter.y + sin(self.containerLayer.angle) * newLocRadius)
		//
		//			containerLayer.updateShapePos(newPos: newLoc)
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
