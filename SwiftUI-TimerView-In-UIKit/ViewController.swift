
//
//  ViewController.swift
//  SwiftUI-TimerView-In-UIKit
//
//  Created by Marlon Raskin on 2024-11-19.
//

import Combine
import SwiftUI
import UIKit

class ViewController: UIViewController {
	
	private let timerManager = TimerManager()
	private var cancellable: AnyCancellable?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .backgroundPrimary
		
		view.addSubview(container)
		container.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			container.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
		
		cancellable = timerManager.$timerState.sink { [weak self] state in
			guard let self else { return }
			
			resetButton.configurationUpdateHandler = { button in
				button.isEnabled = state != .running
			}
			
			startStopButton.configurationUpdateHandler = { button in
				let title = switch state {
				case .ready: "Start"
				case .running: "Pause"
				case .paused: "Resume"
				}
				
				// Use attributedTitle with bold font
				button.configuration?.attributedTitle = AttributedString(
					title,
					attributes: .init([.font: UIFont.boldSystemFont(ofSize: 17)])
				)
				button.configuration?.baseBackgroundColor = state == .running ? .red : .trim
				button.configuration?.baseForegroundColor = state == .running ? .lightText : .buttonText
			}
		}
	}
	
	private lazy var container: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [timerView, titleLabel, buttonContainer])
		stack.axis = .vertical
		stack.spacing = 20
		stack.isLayoutMarginsRelativeArrangement = true
		stack.layoutMargins = .init(top: 0, left: 24, bottom: 0, right: 24)
		stack.setCustomSpacing(30, after: timerView)
		return stack
	}()
	
	private lazy var timerView: UIView = {
		let timerView = TimerView(manager: timerManager)
		let hostingController = UIHostingController(rootView: timerView)
		hostingController.sizingOptions = .intrinsicContentSize
		hostingController.view.backgroundColor = .clear
		addChild(hostingController)
		didMove(toParent: self)
		return hostingController.view
	}()
	
	private lazy var buttonContainer: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [resetButton, startStopButton])
		stack.spacing = 10
		return stack
	}()
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.text = "UIViewController Buttons"
		label.font = .preferredFont(forTextStyle: .headline)
		label.textAlignment = .center
		label.textColor = .label
		return label
	}()
	
	private func buttonConfiguration(
		title: String,
		titleColor: UIColor,
		bgColor: UIColor
	) -> UIButton.Configuration {
		var container = AttributeContainer()
		container.font = .system(.headline, weight: .bold)
		
		var config = UIButton.Configuration.filled()
		config.attributedTitle = AttributedString(
			title,
			attributes: .init([.font: UIFont.boldSystemFont(ofSize: 17)])
		)
		config.buttonSize = .large
		config.cornerStyle = .large
		config.baseForegroundColor = titleColor
		config.baseBackgroundColor = bgColor
		config.titleAlignment = .center
		return config
	}
	
	private lazy var resetButton: UIButton = {
		let config = buttonConfiguration(
			title: "Reset",
			titleColor: .buttonText,
			bgColor: .systemCyan
		)
		let button = UIButton(configuration: config, primaryAction: .init(handler: { [weak self] _ in
			self?.resetTimer()
		}))
		return button
	}()
	
	private lazy var startStopButton: UIButton = {
		let config = buttonConfiguration(
			title: "Start",
			titleColor: .buttonText,
			bgColor: .trim
		)
		let button = UIButton(configuration: config, primaryAction: .init(handler: { [weak self] _ in
			self?.startStopTimer()
		}))
		return button
	}()
	
	@objc private func resetTimer() {
		timerManager.stopTimer(reset: true)
	}
	
	@objc private func startStopTimer() {
		switch timerManager.timerState {
		case .ready:
			timerManager.startTimer(for: timerManager.duration)
		case .running:
			timerManager.stopTimer()
		case .paused:
			timerManager.resumeTimer()
		}
	}
}

