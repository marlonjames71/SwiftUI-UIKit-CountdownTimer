//
//  StepButton.swift
//  SwiftUI-TimerView-In-UIKit
//
//  Created by Marlon Raskin on 2024-11-21.
//

import SwiftUI

struct StepButton<T: SignedNumeric & AdditiveArithmetic & Comparable>: View {
	
	init(stepBy stepValue: T, value: Binding<T>) {
		self.stepValue = stepValue
		self._value = value
	}
	
	let stepValue: T
	@Binding var value: T
	
	var body: some View {
		Button {
			adjustValue()
		} label: {
			Circle()
				.fill(.tint)
				.overlay {
					GeometryReader { geometry in
						HStack(spacing: 3) {
							Image(systemName: symbolName)
								.minimumScaleFactor(0.5)
							
							Text(String(describing: abs(stepValue)))
								.lineLimit(1)
								.font(.title3)
								
						}
						.frame(width: geometry.size.width, height: geometry.size.height)
						.minimumScaleFactor(0.7)
						.foregroundStyle(.white)
						.fontWeight(.bold)
					}
					.padding(10)
				}
				.padding(5)
				.background(.tint.secondary)
				.clipShape(Circle())
		}
		.buttonStyle(.scaleOnPress(scaleAmount: 0.9))
		.disabled(stepValue == T.zero)
	}
	
	private func adjustValue() {
		guard stepValue != T.zero else { return }
		
		if stepValue > T.zero {
			value += stepValue
		} else {
			let newValue = value - abs(stepValue)
			guard value > T.zero, newValue > T.zero else { return }
			value = newValue
		}
	}
	
	private var symbolName: String {
		// hides the symbol if value is 0
		guard stepValue != 0 else { return "" }
		
		return stepValue > 0 ? "plus" : "minus"
	}
}

#Preview {
	@Previewable @State var time: Int = 0
	@Previewable @State var readings: Double = 800

	VStack(spacing: 50) {
		HStack(alignment: .bottom, spacing: 12) {
			HStack(spacing: 20) {
				Group {
					StepButton(stepBy: -1, value: $time)
					StepButton(stepBy: 1, value: $time)
				}
				.tint(Color.indigo)
				.frame(width: 100)
			}
			
			Spacer()
			
			Text("\(time)")
				.monospaced()
				.font(.largeTitle)
				.minimumScaleFactor(0.6)
				.lineLimit(1)
				.padding(.bottom, 5)
		}
		.padding(.horizontal)
		
		HStack(alignment: .bottom, spacing: 12) {
			HStack(spacing: 20) {
				Group {
					StepButton(stepBy: -3.9, value: $readings)
					StepButton(stepBy: 3.942, value: $readings)
				}
				.tint(Color.indigo)
				.frame(width: 100)
			}
			
			Spacer()
			
			Text(readings, format: .number.precision(.fractionLength(2)))
				.monospaced()
				.font(.largeTitle)
				.minimumScaleFactor(0.6)
				.lineLimit(1)
				.padding(.bottom, 5)
		}
		.padding(.horizontal)
	}
}
