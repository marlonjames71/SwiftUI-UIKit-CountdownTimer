//
//  TimerView.swift
//  SwiftUI-TimerView-In-UIKit
//
//  Created by Marlon Raskin on 2024-11-19.
//

import SwiftUI

struct TimerView: View {
	@StateObject private var manager: TimerManager
	@State private var timerValue: Double = 10
	
	@Environment(\.colorScheme) var colorScheme
	
	init(manager: TimerManager) {
		self._manager = StateObject(wrappedValue: manager)
	}
		
	var body: some View {
		VStack(spacing: 20) {
			ZStack {
				Circle()
					.stroke(.secondaryTrim, style: .init(lineWidth: 10))
				
				Circle()
					.trim(from: 0, to: manager.trimValue)
					.stroke(.trim, style: .init(lineWidth: 10, lineCap: .round))
					.rotationEffect(.degrees(-90))
					.animation(manager.isSettingTrim ? nil : .linear(duration: 1), value: manager.time)
					.overlay {
						Text("\(Int(manager.time))")
							.font(.largeTitle)
							.fontWeight(.bold)
							.monospaced()
							.contentTransition(.numericText(countsDown: true))
							.animation(.easeInOut, value: manager.time)
					}
			}
			.frame(width: 150, height: 150)
			
			HStack(spacing: 20) {
				StepButton(stepBy: -1, time: $timerValue).tint(.indigo)
				StepButton(stepBy: 1, time: $timerValue).tint(.indigo)
				StepButton(stepBy: -5, time: $timerValue).tint(.orange)
				StepButton(stepBy: 5, time: $timerValue).tint(.orange)
			}
			.disabled(manager.timerState == .running || manager.timerState == .paused)
			.padding(.vertical, 50)
			.onChange(of: timerValue) { _, newValue in
				manager.duration = newValue
				manager.time = newValue
			}
			
			HStack {
				Button {
					manager.stopTimer(reset: true)
				} label: {
					Text("Reset")
						.animation(nil)
						.foregroundStyle(.buttonText)
						.frame(maxWidth: .infinity)
						.frame(height: 50)
						.background(.cyan)
						.clipShape(RoundedRectangle(cornerRadius: 16))
				}
				.buttonStyle(.scaleOnPress)
				.disabled(manager.timerState == .running)
				.opacity(manager.timerState == .running ? 0.5 : 1)
				
				Button {
					if manager.timerState == .running {
						manager.stopTimer()
					} else {
						manager.timerState == .ready
						? manager.startTimer(for: timerValue)
						: manager.resumeTimer()
					}
				} label: {
					Text(startStopButtonText)
						.animation(nil)
						.foregroundStyle(startStopButtonTextColor)
						.frame(maxWidth: .infinity)
						.frame(height: 50)
						.background(manager.timerState == .running ? .red : .trim)
						.clipShape(RoundedRectangle(cornerRadius: 16))
				}
				.buttonStyle(.scaleOnPress)
			}
			.fontWeight(.bold)
		}
		.padding(.horizontal, 24)
	}
	
	private var startStopButtonText: String {
		if manager.timerState == .running {
			"Pause"
		} else {
			(manager.isSettingTrim || manager.time == 0) ? "Start" : "Resume"
		}
	}
	
	private var startStopButtonTextColor: Color {
		manager.timerState == .running ? .lightText : .buttonText
	}
}

struct ScaleOnPressButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed ? 0.96 : 1)
			.animation(.linear(duration: 0.2), value: configuration.isPressed)
	}
}

extension ButtonStyle where Self == ScaleOnPressButtonStyle {
	static var scaleOnPress: ScaleOnPressButtonStyle { .init() }
}

#Preview {
	ZStack {
		Color.backgroundPrimary.ignoresSafeArea()
		
		TimerView(manager: .init())
			.padding()
	}
}
