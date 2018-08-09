//
//  ButterflyHandleView.swift
//
//  Created by usagimaru on 2018.06.14.
//  Copyright © 2018 Satori Maru. All rights reserved.
//  https://github.com/usagimaru/ButterflyHandle

import UIKit

class ButterflyHandleView: UIView {
	
	enum direction {
		case top
		case bottom
	}

	/// 定数定義
	struct Constant {
		/// 翼の色
		static let defaultWingColor = UIColor(displayP3Red: 0.82, green: 0.82, blue: 0.84, alpha: 1.0)
		/// 片翼の傾き
		static let wingFoldingAngle: CGFloat = (22.5 * CGFloat.pi / 180)
		/// 片翼の大きさ
		static let wingSize = CGSize(width: 20, height: 5)
	}

	var direction: direction = .top {
		didSet {
			self.isSpreading = self._isSpreading
		}
	}
	
	private var _isSpreading: Bool = true
	var isSpreading: Bool = true {
		didSet {
			if isSpreading {
				spread(animated: false)
			}
			else {
				flap(animated: false)
			}
		}
	}
	
	private var leftWing = UIView()
	private var rightWing = UIView()

	var wingColor: UIColor = ButterflyHandleView.Constant.defaultWingColor


	// MARK: -
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		_init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		_init()
	}
	
	private func _init() {
		self.leftWing = wingBuilder()
		self.rightWing = wingBuilder()
		
		let adjustJoint: CGFloat = 2
		let adjustYAxis: CGFloat = 2
		
		self.leftWing.x = self.width / 2 - self.leftWing.width + adjustJoint
		self.leftWing.y = self.height / 2 - adjustYAxis
		self.rightWing.x = self.width / 2 - adjustJoint
		self.rightWing.y = self.height / 2 - adjustYAxis
		
		self.addSubview(self.leftWing)
		self.addSubview(self.rightWing)
	}
	
	private func wingBuilder() -> UIView {
		let wing = UIView.initWithSize(ButterflyHandleView.Constant.wingSize)
		wing.clipsToBounds = true
		wing.backgroundColor = self.wingColor
		wing.cornerRadius = ButterflyHandleView.Constant.wingSize.height / 2
		return wing
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.isSpreading = false
	}
	
	func spread(animated: Bool) {
		self._isSpreading = true
		
		if animated {
			UIView.animateWithSystemMotion({
				self.leftWing.transform = CGAffineTransform(rotationAngle: 0)
				self.rightWing.transform = CGAffineTransform(rotationAngle: 0)
			}, completion: nil)
		}
		else {
			self.leftWing.transform = CGAffineTransform(rotationAngle: 0)
			self.rightWing.transform = CGAffineTransform(rotationAngle: 0)
		}
	}
	
	func flap(animated: Bool) {
		self._isSpreading = false

		let wingFoldingAngle = ButterflyHandleView.Constant.wingFoldingAngle
		let angle = self.direction == .top ? -wingFoldingAngle : wingFoldingAngle
		
		if animated {
			UIView.animateWithSystemMotion({
				self.leftWing.transform = CGAffineTransform(rotationAngle: angle)
				self.rightWing.transform = CGAffineTransform(rotationAngle: -angle)
			}, completion: nil)
		}
		else {
			self.leftWing.transform = CGAffineTransform(rotationAngle: angle)
			self.rightWing.transform = CGAffineTransform(rotationAngle: -angle)
		}
		
	}
	
}
