
//
//  ViewController.swift
//  SwiftUI-TimerView-In-UIKit
//
//  Created by Marlon Raskin on 2024-11-19.
//

import SwiftUI
import UIKit

class ViewController: UIViewController {
	
	private let timerManager = TimerManager()
	
	private lazy var timerView: UIView = {
		let timerView = TimerView(manager: timerManager)
		let hostingController = UIHostingController(rootView: timerView)
		hostingController.sizingOptions = .intrinsicContentSize
		hostingController.view.backgroundColor = .clear
		addChild(hostingController)
		didMove(toParent: self)
		return hostingController.view
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .backgroundPrimary
		
		view.addSubview(timerView)
		timerView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			timerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			timerView.topAnchor.constraint(equalTo: view.topAnchor),
			timerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			timerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])
	}
}

