//
//  TimerView.swift
//  SwiftUI-TimerView-In-UIKit
//
//  Created by Marlon Raskin on 2024-11-19.
//

import SwiftUI

struct TimerView: View {
	@StateObject private var manager: TimerManager
	@State private var timerValue: Int = 10
	
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
			
			HStack(spacing: 5) {
				StepButton(stepBy: -1, value: $timerValue).tint(.stepButtonColor1)
				StepButton(stepBy: 1, value: $timerValue).tint(.stepButtonColor1)
				Spacer(minLength: 8)
				StepButton(stepBy: -5, value: $timerValue).tint(.stepButtonColor2)
				StepButton(stepBy: 5, value: $timerValue).tint(.stepButtonColor2)
			}
			.disabled(manager.timerState == .running || manager.timerState == .paused)
			.padding(.top, 50)
			.padding(.bottom, 20)
			.onChange(of: timerValue) { _, newValue in
				manager.duration = TimeInterval(newValue)
				manager.time = TimeInterval(newValue)
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
				.buttonStyle(.scaleOnPress())
				.disabled(manager.timerState == .running)
				
				Button {
					if manager.timerState == .running {
						manager.stopTimer()
					} else {
						manager.timerState == .ready
						? manager.startTimer(for: TimeInterval(timerValue))
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
				.buttonStyle(.scaleOnPress())
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
	let scaleAmount: Double
	@Environment(\.isEnabled) var enabled
	
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed ? 0.96 : 1)
			.opacity(enabled ? 1 : 0.6)
			.animation(.linear(duration: 0.1), value: configuration.isPressed)
	}
}

extension ButtonStyle where Self == ScaleOnPressButtonStyle {
	static func scaleOnPress(scaleAmount: Double = 0.96) -> ScaleOnPressButtonStyle {
		.init(scaleAmount: scaleAmount)
	}
}

#Preview {
	ZStack {
		Color.backgroundPrimary.ignoresSafeArea()
		
		TimerView(manager: .init())
			.padding()
	}
}
