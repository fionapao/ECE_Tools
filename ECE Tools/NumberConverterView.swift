//
//  NumberConverterView.swift
//  ECE Tools
//
//  Created by Fiona Pao on 2025/11/19.
//

import SwiftUI

@Observable
class NumberConverterViewModel {
    var inputText: String = ""
    var inputRepresentation: NumberRepresentation = .decimal
    var outputRepresentation: NumberRepresentation = .hex
    var bitWidth: Int = 16
    
    var bitWidthWarning: String? {
        guard !inputText.isEmpty else { return nil }
        return NumberConverter.validateBitWidth(value: inputText, representation: inputRepresentation, bitWidth: bitWidth)
    }
    
    var convertedValue: String {
        guard let value = NumberConverter.convert(from: inputText, representation: inputRepresentation, bitWidth: bitWidth) else {
            return "Invalid Input"
        }
        return NumberConverter.format(value: value, as: outputRepresentation, bitWidth: bitWidth)
    }
    
    var allRepresentations: [(NumberRepresentation, String)] {
        guard let value = NumberConverter.convert(from: inputText, representation: inputRepresentation, bitWidth: bitWidth) else {
            return NumberRepresentation.allCases.map { ($0, "Invalid Input") }
        }
        return NumberRepresentation.allCases.map { rep in
            (rep, NumberConverter.format(value: value, as: rep, bitWidth: bitWidth))
        }
    }
}

struct NumberConverterView: View {
    @State private var viewModel = NumberConverterViewModel()
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        Form {
            Section("Input") {
                Picker("Input Format", selection: $viewModel.inputRepresentation) {
                    ForEach(NumberRepresentation.allCases) { rep in
                        Text(rep.rawValue).tag(rep)
                    }
                }
                
                TextField("Enter value", text: $viewModel.inputText)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                    .focused($isInputFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        isInputFocused = false
                    }
                
                Picker("Bit Width", selection: $viewModel.bitWidth) {
                    Text("8-bit").tag(8)
                    Text("16-bit").tag(16)
                    Text("32-bit").tag(32)
                }
                .pickerStyle(.segmented)
                
                if let warning = viewModel.bitWidthWarning {
                    Label(warning, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            
            Section("All Representations") {
                ForEach(viewModel.allRepresentations, id: \.0.id) { rep, value in
                    HStack {
                        Text(rep.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(value)
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)
                    }
                }
            }
        }
        .navigationTitle("Number Converter")
    }
}

#Preview {
    NavigationStack {
        NumberConverterView()
    }
}
