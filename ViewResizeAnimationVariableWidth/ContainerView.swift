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
	var shape = ShapeLayer()
	var shapeLineWidth: CGFloat = 1

	var figureCenter: CGPoint { return CGPoint(x: self.bounds.midX, y: self.bounds.midY) }
	var figureDiameter: CGFloat { return min(self.bounds.width, self.bounds.height) }
	var figureRadius: CGFloat { return figureDiameter / 2 }

	var shapeDiameter: CGFloat { return round(figureDiameter / 5) }
	var shapeRadius: CGFloat { return shapeDiameter/2 }
	var locRadius: CGFloat { return figureRadius - shapeRadius }
	var angle: CGFloat { return -halfPi }

	var unitLoc: CGPoint { return CGPoint(x: figureCenter.x + cos(angle) * locRadius, y: figureCenter.y + sin(angle) * locRadius) }

	override func layoutSublayers() {
		super.layoutSublayers()
		if !self.didSetup {
			self.setup()
			self.didSetup = true
		}
		updateShape()
	}

	func setup() {
		self.contentsScale = UIScreen.main.scale
		self.backgroundColor = UIColor.systemYellow.cgColor
		self.needsDisplayOnBoundsChange = true
		self.shape.contentsScale = UIScreen.main.scale
		self.addSublayer(shape)
		self.shape.strokeWidth = shapeLineWidth
		self.shape.fColor = UIColor(red:0.9, green:0.95, blue:0.93, alpha:0.9).cgColor
		self.shape.sColor = UIColor.black.cgColor
		self.shape.position = unitLoc
	}

	func updateShape() {
		self.shape.bounds = CGRect(x: 0, y: 0, width: shapeDiameter, height: shapeDiameter)
		self.shape.position = unitLoc
		self.shape.updatePath()
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
				print("key: \(key) animation supressed")
				return nil
			}
		}
		return super.action(forKey:key)
	}
}
