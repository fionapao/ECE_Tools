//
//  LC3ConverterView.swift
//  ECE Tools
//
//  Created by Fiona Pao on 2025/11/19.
//

import SwiftUI

enum LC3Direction {
    case binaryToAssembly
    case assemblyToBinary
}

@Observable
class LC3ConverterViewModel {
    var inputText: String = ""
    var direction: LC3Direction = .binaryToAssembly
    
    var result: String {
        switch direction {
        case .binaryToAssembly:
            guard let assembly = LC3Converter.binaryToAssembly(inputText) else {
                return "Invalid binary instruction"
            }
            return assembly
            
        case .assemblyToBinary:
            guard let binary = LC3Converter.assemblyToBinary(inputText) else {
                return "Invalid assembly instruction"
            }
            return "0b" + binary
        }
    }
}

struct LC3ConverterView: View {
    @State private var viewModel = LC3ConverterViewModel()
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        Form {
            Section("Conversion Direction") {
                Picker("Direction", selection: $viewModel.direction) {
                    Text("Binary → Assembly").tag(LC3Direction.binaryToAssembly)
                    Text("Assembly → Binary").tag(LC3Direction.assemblyToBinary)
                }
                .pickerStyle(.segmented)
            }
            
            Section("Input") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.direction == .binaryToAssembly ? "Binary Instruction (16-bit)" : "Assembly Instruction")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    TextField(
                        viewModel.direction == .binaryToAssembly ? "e.g., 0001001010000011" : "e.g., ADD R1, R2, R3",
                        text: $viewModel.inputText,
                        axis: .vertical
                    )
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(1...3)
                    .focused($isInputFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        isInputFocused = false
                    }
                }
            }
            
            Section("Result") {
                Text(viewModel.result)
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.bold)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            Section("LC-3 Instruction Reference") {
                DisclosureGroup("Arithmetic & Logical") {
                    VStack(alignment: .leading, spacing: 4) {
                        InstructionReference(mnemonic: "ADD", format: "ADD DR, SR1, SR2/imm5")
                        InstructionReference(mnemonic: "AND", format: "AND DR, SR1, SR2/imm5")
                        InstructionReference(mnemonic: "NOT", format: "NOT DR, SR")
                    }
                }
                
                DisclosureGroup("Memory Access") {
                    VStack(alignment: .leading, spacing: 4) {
                        InstructionReference(mnemonic: "LD", format: "LD DR, offset9")
                        InstructionReference(mnemonic: "LDI", format: "LDI DR, offset9")
                        InstructionReference(mnemonic: "LDR", format: "LDR DR, BaseR, offset6")
                        InstructionReference(mnemonic: "LEA", format: "LEA DR, offset9")
                        InstructionReference(mnemonic: "ST", format: "ST SR, offset9")
                        InstructionReference(mnemonic: "STI", format: "STI SR, offset9")
                        InstructionReference(mnemonic: "STR", format: "STR SR, BaseR, offset6")
                    }
                }
                
                DisclosureGroup("Control") {
                    VStack(alignment: .leading, spacing: 4) {
                        InstructionReference(mnemonic: "BR", format: "BR[nzp] offset9")
                        InstructionReference(mnemonic: "JMP", format: "JMP BaseR")
                        InstructionReference(mnemonic: "JSR", format: "JSR offset11")
                        InstructionReference(mnemonic: "JSRR", format: "JSRR BaseR")
                        InstructionReference(mnemonic: "RET", format: "RET")
                        InstructionReference(mnemonic: "RTI", format: "RTI")
                        InstructionReference(mnemonic: "TRAP", format: "TRAP vector8")
                    }
                }
            }
        }
        .navigationTitle("LC-3 Converter")
    }
}

struct InstructionReference: View {
    let mnemonic: String
    let format: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(mnemonic)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.semibold)
            Text(format)
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        LC3ConverterView()
    }
}
