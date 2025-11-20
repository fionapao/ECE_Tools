//
//  CalculatorView.swift
//  ECE Tools
//
//  Created by Fiona Pao on 2025/11/19.
//

import SwiftUI

enum Operation: String, CaseIterable, Identifiable {
    case add = "Add (+)"
    case subtract = "Subtract (−)"
    case invert = "Invert (~)"
    
    var id: String { rawValue }
}

@Observable
class CalculatorViewModel {
    var operand1Text: String = ""
    var operand2Text: String = ""
    var operand1Rep: NumberRepresentation = .twosComplement
    var operand2Rep: NumberRepresentation = .twosComplement
    var outputRep: NumberRepresentation = .twosComplement
    var operation: Operation = .add
    var bitWidth: Int = 16
    
    var operand1Warning: String? {
        guard !operand1Text.isEmpty else { return nil }
        return NumberConverter.validateBitWidth(value: operand1Text, representation: operand1Rep, bitWidth: bitWidth)
    }
    
    var operand2Warning: String? {
        guard !operand2Text.isEmpty else { return nil }
        return NumberConverter.validateBitWidth(value: operand2Text, representation: operand2Rep, bitWidth: bitWidth)
    }
    
    var result: String {
        guard let value1 = NumberConverter.convert(from: operand1Text, representation: operand1Rep, bitWidth: bitWidth) else {
            return "Invalid Input 1"
        }
        
        switch operation {
        case .add:
            guard let value2 = NumberConverter.convert(from: operand2Text, representation: operand2Rep, bitWidth: bitWidth) else {
                return "Invalid Input 2"
            }
            let (result, overflow) = NumberConverter.add(value1, value2, bitWidth: bitWidth)
            let formatted = NumberConverter.format(value: result, as: outputRep, bitWidth: bitWidth)
            return overflow ? "\(formatted) (Overflow)" : formatted
            
        case .subtract:
            guard let value2 = NumberConverter.convert(from: operand2Text, representation: operand2Rep, bitWidth: bitWidth) else {
                return "Invalid Input 2"
            }
            let (result, overflow) = NumberConverter.subtract(value1, value2, bitWidth: bitWidth)
            let formatted = NumberConverter.format(value: result, as: outputRep, bitWidth: bitWidth)
            return overflow ? "\(formatted) (Overflow)" : formatted
            
        case .invert:
            let result = NumberConverter.invert(value1, bitWidth: bitWidth)
            return NumberConverter.format(value: result, as: outputRep, bitWidth: bitWidth)
        }
    }
    
    var allResultRepresentations: [(NumberRepresentation, String)] {
        guard let value1 = NumberConverter.convert(from: operand1Text, representation: operand1Rep, bitWidth: bitWidth) else {
            return NumberRepresentation.allCases.map { ($0, "Invalid Input") }
        }
        
        let finalResult: Int
        switch operation {
        case .add:
            guard let value2 = NumberConverter.convert(from: operand2Text, representation: operand2Rep, bitWidth: bitWidth) else {
                return NumberRepresentation.allCases.map { ($0, "Invalid Input") }
            }
            finalResult = NumberConverter.add(value1, value2, bitWidth: bitWidth).result
            
        case .subtract:
            guard let value2 = NumberConverter.convert(from: operand2Text, representation: operand2Rep, bitWidth: bitWidth) else {
                return NumberRepresentation.allCases.map { ($0, "Invalid Input") }
            }
            finalResult = NumberConverter.subtract(value1, value2, bitWidth: bitWidth).result
            
        case .invert:
            finalResult = NumberConverter.invert(value1, bitWidth: bitWidth)
        }
        
        return NumberRepresentation.allCases.map { rep in
            (rep, NumberConverter.format(value: finalResult, as: rep, bitWidth: bitWidth))
        }
    }
}

struct CalculatorView: View {
    @State private var viewModel = CalculatorViewModel()
    @FocusState private var focusedField: Field?
    
    enum Field {
        case operand1
        case operand2
    }
    
    var body: some View {
        Form {
            Section("Operation") {
                Picker("Operation", selection: $viewModel.operation) {
                    ForEach(Operation.allCases) { op in
                        Text(op.rawValue).tag(op)
                    }
                }
                .pickerStyle(.segmented)
                
                Picker("Bit Width", selection: $viewModel.bitWidth) {
                    Text("8-bit").tag(8)
                    Text("16-bit").tag(16)
                    Text("32-bit").tag(32)
                }
                .pickerStyle(.segmented)
            }
            
            Section("Operand 1") {
                Picker("Format", selection: $viewModel.operand1Rep) {
                    ForEach(NumberRepresentation.allCases) { rep in
                        Text(rep.rawValue).tag(rep)
                    }
                }
                
                TextField("Enter first operand", text: $viewModel.operand1Text)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                    .focused($focusedField, equals: .operand1)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
                
                if let warning = viewModel.operand1Warning {
                    Label(warning, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            
            if viewModel.operation != .invert {
                Section("Operand 2") {
                    Picker("Format", selection: $viewModel.operand2Rep) {
                        ForEach(NumberRepresentation.allCases) { rep in
                            Text(rep.rawValue).tag(rep)
                        }
                    }
                    
                    TextField("Enter second operand", text: $viewModel.operand2Text)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                        .focused($focusedField, equals: .operand2)
                        .submitLabel(.done)
                        .onSubmit {
                            focusedField = nil
                        }
                    
                    if let warning = viewModel.operand2Warning {
                        Label(warning, systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
            
            Section("Result") {
                Picker("Output Format", selection: $viewModel.outputRep) {
                    ForEach(NumberRepresentation.allCases) { rep in
                        Text(rep.rawValue).tag(rep)
                    }
                }
                
                Text(viewModel.result)
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.bold)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            Section("All Result Representations") {
                ForEach(viewModel.allResultRepresentations, id: \.0.id) { rep, value in
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
        .navigationTitle("Calculator")
    }
}

#Preview {
    NavigationStack {
        CalculatorView()
    }
}
