//
//  ContainerView.swift
//  ViewResizeAnimationVariableWidth
//
//  Created by Paul Bryan on 7/2/20.
//  Copyright © 2020 Paul Bryan. All rights reserved.
//

import UIKit

class ContainerView: UIView {
	override class var layerClass: AnyClass { return ContainerLayer.self }
	override func draw(_ rect: CGRect) { }
}

class ContainerLayer: CALayer, CALayerDelegate {

	var didSetup = false

	var figureCenter: CGPoint!
	var figureDiameter: CGFloat!
	var figureRadius: CGFloat!

	var shape = ShapeLayer()
	var shapeLineWidth: CGFloat = 1
	var shapeDiameter: CGFloat!
	var shapeRadius: CGFloat!

	var locRadius: CGFloat!
	var angle: CGFloat!
	var unitLoc: CGPoint!

	override func layoutSublayers() {
		super.layoutSublayers()
		if !self.didSetup {
			self.setup()
			self.didSetup = true
		}
		updateFigure()
		setNeedsDisplay()
	}

	func updateFigure() {
		figureCenter = self.bounds.center
		figureDiameter = min(self.bounds.width, self.bounds.height)
		figureRadius = figureDiameter/2

		shapeDiameter = round(figureDiameter / 5)
		shapeRadius = shapeDiameter/2

		locRadius = figureRadius - shapeRadius
		angle = -halfPi
		unitLoc = CGPoint(x: self.figureCenter.x + cos(angle) * locRadius, y: self.figureCenter.y + sin(angle) * locRadius)

		shape.bounds = CGRect(x: 0, y: 0, width: shapeDiameter, height: shapeDiameter)
		shape.position = unitLoc
		shape.updatePath()
	}

	func setup() {
		contentsScale = UIScreen.main.scale
		backgroundColor = UIColor.systemYellow.cgColor

		shape.contentsScale = UIScreen.main.scale
		addSublayer(shape)
		shape.strokeWidth = shapeLineWidth
		shape.fColor = UIColor(red:0.9, green:0.95, blue:0.93, alpha:0.9).cgColor
		shape.sColor = UIColor.black.cgColor

		updateFigure()
	}

	override func draw(in ctx: CGContext) {
		ctx.move(to: figureCenter)
		ctx.addLine(to: unitLoc)
		ctx.setLineWidth(1)
		ctx.strokePath()
	}
}

class ShapeLayer: CAShapeLayer {
	var didSetup = false
	var strokeWidth: CGFloat?
	var fColor: CGColor?
	var sColor: CGColor?

	override func layoutSublayers() {
		super.layoutSublayers()
		if !self.didSetup {
			self.setup()
			self.didSetup = true
		}
		updatePath()
	}

	func setup() {
		self.contentsScale = UIScreen.main.scale
		self.lineWidth = strokeWidth ?? 1
		self.backgroundColor = UIColor.clear.cgColor
		self.fillColor = fColor ?? UIColor.clear.cgColor
		self.strokeColor = sColor ?? UIColor.black.cgColor

		self.setValue(true, forKey:"suppressPositionAnimation")
	}

	func updatePath() {

		self.path = UIBezierPath(ovalIn: self.bounds.insetBy(dx: self.lineWidth/2, dy: self.lineWidth/2)).cgPath
	}

	override func action(forKey key: String) -> CAAction? {
		if key == #keyPath(position) {
			if self.value(forKey:"suppressPositionAnimation") != nil {
				//print("key: \(key) animation supressed")
				return nil
			}
		}
		return super.action(forKey:key)
	}
}
