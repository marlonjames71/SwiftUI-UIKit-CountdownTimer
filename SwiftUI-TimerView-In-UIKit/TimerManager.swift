//
//  TimerManager.swift
//  SwiftUI-TimerView-In-UIKit
//
//  Created by Marlon Raskin on 2024-11-19.
//

import Combine
import Foundation

final class TimerManager: ObservableObject {
	@Published var time: TimeInterval = 10
	@Published var duration: TimeInterval = 10
	@Published var timerState: TimerState = .ready
	
	private let timerFinishedSubject = PassthroughSubject<Void, Never>()
	var timerFinished: AnyPublisher<Void, Never> {
		timerFinishedSubject.eraseToAnyPublisher()
	}
	
	private var timerConnector: Cancellable?
	
	private var endDate: Date?
	
	enum TimerState {
		case ready
		case running
		case paused
		case finished
	}

	private func connectTimer() {
		timerConnector = Timer.publish(every: 0.1, on: .main, in: .common)
			.autoconnect()
			.sink(receiveValue: { [weak self] currentDate in
				guard let self, let endDate, timerState == .running else { return }
				
				let remainingTime = endDate.timeIntervalSince(currentDate)
				
				if remainingTime > 0 {
					time = remainingTime
					print("timer fired, remaining time: \(remainingTime)")
				} else {
					stopTimer(reset: true)
					timerFinishedSubject.send()
				}
			})
	}
	
	private func disconnectTimer() {
		timerConnector?.cancel()
		timerConnector = nil
	}
	
	func startTimer(for duration: TimeInterval) {
		guard timerState == .ready else { return }
		self.duration = duration
		time = duration
		endDate = Date().addingTimeInterval(duration)
		connectTimer()
		timerState = .running
	}
	
	func stopTimer(reset: Bool = false) {
		disconnectTimer()
		
		print("timer stopped")
		
		if reset {
			time = duration
			endDate = nil
			timerState = .ready
			print("timer reset")
		} else {
			timerState = .paused
		}
	}
	
	func resumeTimer() {
		guard timerState == .paused else { return }
		endDate = Date().addingTimeInterval(time)
		connectTimer()
		timerState = .running
	}
	
	var trimValue: Double {
		time > 0 ? time / duration : 0
	}
	
	var isSettingTrim: Bool {
		time == duration
	}
}
