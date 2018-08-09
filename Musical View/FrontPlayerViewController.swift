//
//  FrontPlayerViewController.swift
//  Musical View
//
//  Created by usagimaru on 2018.06.14.
//  Copyright © 2018 Satori Maru. All rights reserved.
//

import UIKit
import AVFoundation

class FrontPlayerViewController: UIViewController {
	
	private struct LayoutInfo {
		/// 角R
		let cornerRadius: CGFloat = 12
		/// 前景の上マージン
		let viewMargin: CGFloat = 60
		/// 背景の上マージン
		let backdropMargin: CGFloat = 16
		/// 背景の最小縮小率
		let backdropScaleNormal: CGFloat = 0.94
		/// 背景の最大拡大率
		let backdropScaleLimit: CGFloat = 0.98
		/// 背景の拡大割合を調整します（大きくするほど拡大しにくい）
		let backdropScalingResolution: CGFloat = 3000
	}
	private let layoutInfo = LayoutInfo()

	@IBOutlet private weak var butterflyHandle: ButterflyHandleView!
	@IBOutlet private weak var contentView: UIView!
	@IBOutlet private weak var scrollView: UIScrollView!
	@IBOutlet private weak var frontJacketFrameView: UIView!
	@IBOutlet private weak var backJacketFrameView: UIView!
	@IBOutlet private weak var frontJacketView: UIImageView!
	@IBOutlet private weak var backJacketView: UIImageView!
	@IBOutlet private weak var contentViewTopConstraint: NSLayoutConstraint!
	@IBOutlet private weak var contentViewHeightConstraint: NSLayoutConstraint!
	
	var jacketImage: UIImage? {
		didSet {
			self.frontJacketView?.image = jacketImage
			self.backJacketView?.image = jacketImage
		}
	}
	
	var contentHeight: CGFloat = 0 {
		didSet {
			self.contentViewHeightConstraint?.constant = contentHeight
		}
	}
	
	
	// MARK: - ステータスバー
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return .fade
	}
	
	
	// MARK: -
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		setAppearance()
		
		// true 指定しないと、カスタムトランジションのモーダルビューで元VCの StatusBarStyle を上書きしてくれない
		self.modalPresentationCapturesStatusBarAppearance = true
		
		self.frontJacketView.image = self.jacketImage
		self.backJacketView.image = self.jacketImage
		self.contentViewHeightConstraint.constant = self.contentHeight
		self.butterflyHandle.direction = .bottom
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.view.layoutIfNeeded()
		
		fitJacketView()
		
		if let semiModalPresentationController = self.presentationController as? SemiModalPresentationController {
			semiModalPresentationController.performPresentingTransition(
				withFrontMargin: self.layoutInfo.viewMargin,
				backdropMargins: CGPoint(x: 0, y: self.layoutInfo.backdropMargin),
				backdropScale: self.layoutInfo.backdropScaleNormal,
				backdropCornerRadius: self.layoutInfo.cornerRadius,
				animated: animated,
				additionalAnimations: nil)
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.scrollView.delegate = self
		self.scrollView.flashScrollIndicators()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.scrollView.delegate = nil
		
		if let semiModalPresentationController = self.presentationController as? SemiModalPresentationController {
			semiModalPresentationController.performDismissingTransition(
				withCustomTransfrom: nil,
				backdropCornerRadius: 0,
				animated: animated,
				additionalAnimations: nil)
		}
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}
	
	
	// MARK: -
	
	private func setAppearance() {
		self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		self.view.layer.cornerRadius = self.layoutInfo.cornerRadius
		
		self.frontJacketFrameView.layer.shadowColor = UIColor.black.cgColor
		self.frontJacketFrameView.layer.shadowRadius = self.layoutInfo.cornerRadius
		self.frontJacketFrameView.layer.shadowOffset = CGSize(width: 0, height: 8)
		self.frontJacketFrameView.layer.shadowOpacity = 0.2
	}
	
	/// 内接描画の実寸を得る
	private func scaledFittingSize() -> CGSize? {
		// https://stackoverflow.com/questions/6278876/how-to-know-the-image-size-after-applying-aspect-fit-for-the-image-in-an-uiimage
		
		guard let jacketImage = self.jacketImage else {return nil}
		let insideRect = CGRect(x: 0, y: 0, width: self.frontJacketFrameView.width, height: self.frontJacketFrameView.width)
		let jacketScaledSize = AVMakeRect(aspectRatio: jacketImage.size, insideRect: insideRect).size
		return jacketScaledSize
	}
	
	private func fitJacketView() {
		if let scaledFittingSize = scaledFittingSize() {
			self.frontJacketView.size = scaledFittingSize
			self.frontJacketView.y = self.frontJacketFrameView.height / 2 - self.frontJacketView.height / 2
		}
	}
	
	private func updateViewTransforms(withScrollOffset y: CGFloat) {
		guard let semiModalPresentationController = self.presentationController as? SemiModalPresentationController else {return}
		
		// スクロール量に合わせて背景ビューのスケールを変化させる
		let scrollRate = y / self.layoutInfo.backdropScalingResolution
		semiModalPresentationController.updateBackdropTransform(withScrollRate: scrollRate,
																backdropScale: self.layoutInfo.backdropScaleNormal,
																backdropScaleLimit: self.layoutInfo.backdropScaleLimit,
																backdropMargins: CGPoint(x: 0, y: self.layoutInfo.backdropMargin))
		
		let move = min(y, 0)
		self.view.y = self.layoutInfo.viewMargin - move
		self.contentViewTopConstraint.constant = move
		self.contentViewHeightConstraint.constant = self.contentHeight - move
	}
	
	private func checkDismissingCondition(withScrollOffset y: CGFloat) {
		// 移動量が一定値を超えたらモーダルビューを閉じる（全体の1/6くらい）
		if y < -self.view.height / 6 {
			// モーダルビューを閉じた後に一瞬スクロールビューの中身がバウンスで戻る映像が見えてしまう対策
			self.scrollView.isScrollEnabled = false
			self.scrollView.setContentOffset(self.scrollView.contentOffset, animated: false) // 慣性スクロールを強制停止
			self.scrollView.contentOffset = CGPoint(x: 0, y: y)
			self.dismiss(animated: true, completion: nil)
		}
	}

}


// MARK: - UIScrollViewDelegate

extension FrontPlayerViewController: UIScrollViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let y = scrollView.contentOffset.y
		updateViewTransforms(withScrollOffset: y)
	}
	
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.butterflyHandle.spread(animated: true)
	}
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		self.butterflyHandle.flap(animated: true)
		
		let y = scrollView.contentOffset.y
		checkDismissingCondition(withScrollOffset: y)
	}
	
}
