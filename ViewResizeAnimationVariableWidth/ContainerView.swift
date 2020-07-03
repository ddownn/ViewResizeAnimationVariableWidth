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

	var circle: ShapeLayer!

	var didSetup = false

	var figureCenter: CGPoint { return CGPoint(x: self.bounds.midX, y: self.bounds.midY) }
	var figureDiameter: CGFloat { return min(self.bounds.width, self.bounds.height) }
	var figureRadius: CGFloat { return figureDiameter / 2 }

	var strokeWidth: CGFloat { return max(round(figureDiameter / 10), 1) }
	//	var strokeWidth: CGFloat = 10

	var circleDiameter: CGFloat { return max(round(figureDiameter / 25), 5) }
	var circleRadius: CGFloat { return circleDiameter/2 }
	var locRadius: CGFloat { return figureRadius - circleRadius - strokeWidth }

    var circleLineWidth: CGFloat = 1

	var unitLoc: CGPoint { return CGPoint(x: figureCenter.x + cos(-halfPi) * locRadius, y: figureCenter.y + sin(-halfPi) * locRadius) }

	override func layoutSublayers() {
		super.layoutSublayers()
		if !self.didSetup {
			self.setup()
			self.didSetup = true
		}
	}

	func setup() {
		self.contentsScale = UIScreen.main.scale
		self.backgroundColor = UIColor.systemYellow.cgColor
		self.needsDisplayOnBoundsChange = true

		self.circle = ShapeLayer()
		self.circle.contentsScale = UIScreen.main.scale
		self.addSublayer(circle)

		self.circle.strokeWidth = circleLineWidth
		self.circle.fColor = UIColor(red:0.9, green:0.95, blue:0.93, alpha:0.9).cgColor
		self.circle.sColor = UIColor.black.cgColor

        updateCircleBounds()

	}

    func updateCircleBounds() {
        self.circle.bounds = CGRect(x: 0, y: 0, width: circleDiameter, height: circleDiameter)
        self.circle.position = unitLoc
        self.circle.update()
		self.circle.setNeedsLayout()
		self.circle.setNeedsDisplay()
        self.setNeedsDisplay()
    }

	override func draw(in ctx: CGContext) {

		// MARK: - Draw the bezel path
		var roundBorderPath: UIBezierPath { return UIBezierPath(ovalIn: self.bounds.insetBy(dx: strokeWidth/2, dy: strokeWidth/2)) }
		var rectBorderPath: UIBezierPath { return UIBezierPath(rect: self.bounds.insetBy(dx: strokeWidth/2, dy: strokeWidth/2))}

		ctx.addPath(roundBorderPath.cgPath)
		ctx.setFillColor(UIColor(red:0.9, green:0.95, blue:0.93, alpha:0.5).cgColor)
		ctx.fillPath()

		ctx.addPath(rectBorderPath.cgPath)
		ctx.setStrokeColor(UIColor.black.cgColor)
		ctx.setLineWidth(strokeWidth)
		ctx.strokePath()

		ctx.addPath(roundBorderPath.cgPath)
		ctx.setStrokeColor(UIColor(white: 0.3, alpha: 1).cgColor)
		ctx.setLineWidth(strokeWidth)
		ctx.strokePath()

		ctx.move(to: figureCenter)
		ctx.addLine(to: CGPoint(x: figureCenter.x + cos(-halfPi) * (figureRadius - strokeWidth - circleRadius), y: figureCenter.y + sin(-halfPi) * (figureRadius - strokeWidth - circleRadius)))
		ctx.setLineWidth(1)
		ctx.strokePath()
	}
}

class ShapeLayer: CAShapeLayer {

	var didSetup = false

	var diameter: CGFloat { return self.bounds.width }
	var pathOrigin: CGPoint { return CGPoint(x: self.bounds.minX, y: self.bounds.minY) }
	var pathSize: CGSize {return CGSize(width: self.diameter, height: self.diameter) }

	var strokeWidth: CGFloat?
	var fColor: CGColor?
	var sColor: CGColor?

	override func layoutSublayers() {
		super.layoutSublayers()
		if !self.didSetup {
			self.setup()
			self.didSetup = true
		}
	}

	func setup() {
		self.contentsScale = UIScreen.main.scale
		self.lineWidth = strokeWidth ?? 1
		self.backgroundColor = UIColor.clear.cgColor
		self.fillColor = fColor ?? UIColor.clear.cgColor
		self.strokeColor = sColor ?? UIColor.black.cgColor
		self.update()
	}

	func update() {
		self.path = UIBezierPath(ovalIn: CGRect(origin: pathOrigin, size: pathSize).insetBy(dx: self.lineWidth/2, dy: self.lineWidth/2)).cgPath
		self.setNeedsLayout()
	}
}
