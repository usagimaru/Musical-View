//
//  ViewController.swift
//  Musical View
//
//  Created by usagimaru on 2018.06.14.
//  Copyright © 2018年 usagimaru. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	private var isInitialAction: Bool = true

	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let frontPlayerVC = segue.destination as? FrontPlayerViewController {
			// 任意のジャケット画像を仮設定
			let jacketImage = #imageLiteral(resourceName: "sample")
			frontPlayerVC.jacketImage = jacketImage
			
			// スクロールビューの長さを仮設定
			let contentHeight: CGFloat = 1000
			frontPlayerVC.contentHeight = contentHeight
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if self.isInitialAction {
			self.performSegue(withIdentifier: "presentPlayer", sender: nil)
			self.isInitialAction = false
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

}

