//
//  ContentView.swift
//  ECE Tools
//
//  Created by Fiona Pao on 2025/11/19.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Converter", systemImage: "arrow.left.arrow.right") {
                NavigationStack {
                    NumberConverterView()
                }
            }
            
            Tab("Calculator", systemImage: "plus.forwardslash.minus") {
                NavigationStack {
                    CalculatorView()
                }
            }
            
            Tab("LC-3", systemImage: "cpu") {
                NavigationStack {
                    LC3ConverterView()
                }
            }
            
            Tab("About", systemImage: "info.circle") {
                NavigationStack {
                    AboutView()
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section("ECE Tools") {
                Text("A comprehensive toolkit for Electrical and Computer Engineering students.")
                    .font(.body)
            }
            
            Section("Features") {
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(
                        icon: "arrow.left.arrow.right",
                        title: "Number Converter",
                        description: "Convert between decimal, hex, binary, and 2's complement"
                    )
                    
                    FeatureRow(
                        icon: "plus.forwardslash.minus",
                        title: "Calculator",
                        description: "Perform arithmetic operations in any representation"
                    )
                    
                    FeatureRow(
                        icon: "cpu",
                        title: "LC-3 Converter",
                        description: "Convert between LC-3 binary and assembly"
                    )
                }
            }
            
            Section("Usage Tips") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Number Formats")
                        .font(.headline)
                    Text("• Decimal: 42, -10")
                    Text("• Hexadecimal: 0xFF, 0x2A")
                    Text("• Binary: 0b1010, 0b11111111")
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    Text("LC-3 Assembly")
                        .font(.headline)
                    Text("• Use R0-R7 for registers")
                    Text("• Use #n for immediate values")
                    Text("• Use xNN for hex trap vectors")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("About")
    }
}

#Preview {
    ContentView()
}
