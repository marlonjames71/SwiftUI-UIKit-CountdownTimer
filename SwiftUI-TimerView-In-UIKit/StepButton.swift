//
//  StepButton.swift
//  SwiftUI-TimerView-In-UIKit
//
//  Created by Marlon Raskin on 2024-11-21.
//

import SwiftUI

struct StepButton: View {
	
	init(stepBy step: Int, time: Binding<TimeInterval>) {
		self.stepValue = step
		self._time = time
	}
	
	let stepValue: Int
	@Binding var time: TimeInterval
	
	var body: some View {
		Button {
			adjustTime()
		} label: {
			ZStack {
				Circle()
				Label("\(abs(stepValue))", systemImage: imageName)
					.tint(.white)
					.fontWeight(.bold)
			}
		}
		.frame(minWidth: 30, minHeight: 30)
		.disabled(stepValue == 0)
		.padding(5)
		.background(.tint.secondary)
		.clipShape(Circle())
	}
	
	private func adjustTime() {
		guard stepValue != 0 else { return }
		
		if stepValue > 0 {
			time += TimeInterval(abs(stepValue))
		} else {
			guard time > 0 else { return }
			time -= TimeInterval(abs(stepValue))
		}
	}
	
	private var imageName: String {
		guard stepValue != 0 else { return "" }
		return stepValue > 0 ? "plus" : "minus"
	}
}

extension StepButton {
	enum Step {
		case increment(by: Int)
		case decrement(by: Int)
		
		var value: Int {
			switch self {
			case .increment(by: let value),
					.decrement(by: let value):
				value
			}
		}
	}
}

#Preview {
	@Previewable @State var time: TimeInterval = 0
	
	VStack(spacing: 100) {
		Text("\(Int(max(0, time.rounded(.up))))")
			.monospaced()
			.font(.largeTitle)
		
		HStack(spacing: 40) {
			Group {
				StepButton(stepBy: -1, time: $time)
					.tint(Color.indigo)
				StepButton(stepBy: 1, time: $time)
					.tint(Color.indigo)
				StepButton(stepBy: -5, time: $time)
					.tint(Color.orange)
				StepButton(stepBy: 5, time: $time)
					.tint(Color.orange)
			}
		}
		.padding(.horizontal)
	}
}
