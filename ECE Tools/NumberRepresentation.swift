//
//  NumberRepresentation.swift
//  ECE Tools
//
//  Created by Fiona Pao on 2025/11/19.
//

import Foundation

enum NumberRepresentation: String, CaseIterable, Identifiable {
    case decimal = "Decimal"
    case hex = "Hexadecimal"
    case binary = "Binary (Unsigned)"
    case twosComplement = "2's Complement"
    
    var id: String { rawValue }
}

struct NumberConverter {
    // Helper function to clean input by removing whitespace
    private static func cleanInput(_ value: String) -> String {
        return value.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\t", with: "")
            .replacingOccurrences(of: "\n", with: "")
    }
    
    static func convert(from value: String, representation: NumberRepresentation, bitWidth: Int = 16) -> Int? {
        let cleanedValue = cleanInput(value)
        
        switch representation {
        case .decimal:
            return Int(cleanedValue)
        case .hex:
            let cleanValue = cleanedValue
                .replacingOccurrences(of: "0x", with: "")
                .replacingOccurrences(of: "0X", with: "")
            guard let unsigned = Int(cleanValue, radix: 16) else { return nil }
            // Handle as signed value if necessary
            return signExtend(unsigned, bitWidth: bitWidth)
        case .binary:
            let cleanValue = cleanedValue.replacingOccurrences(of: "0b", with: "")
            return Int(cleanValue, radix: 2)
        case .twosComplement:
            let cleanValue = cleanedValue.replacingOccurrences(of: "0b", with: "")
            guard let unsigned = Int(cleanValue, radix: 2) else { return nil }
            return signExtend(unsigned, bitWidth: bitWidth)
        }
    }
    
    static func validateBitWidth(value: String, representation: NumberRepresentation, bitWidth: Int) -> String? {
        let cleanedValue = cleanInput(value)
        
        switch representation {
        case .decimal:
            guard let intValue = Int(cleanedValue) else { return nil }
            let maxValue = (1 << (bitWidth - 1)) - 1
            let minValue = -(1 << (bitWidth - 1))
            if intValue > maxValue || intValue < minValue {
                return "Value \(intValue) exceeds \(bitWidth)-bit range [\(minValue), \(maxValue)]"
            }
            return nil
            
        case .hex:
            let cleanValue = cleanedValue
                .replacingOccurrences(of: "0x", with: "")
                .replacingOccurrences(of: "0X", with: "")
            guard !cleanValue.isEmpty else { return nil }
            let bitsNeeded = cleanValue.count * 4
            if bitsNeeded > bitWidth {
                return "Input requires \(bitsNeeded) bits but only \(bitWidth) bits selected"
            }
            return nil
            
        case .binary, .twosComplement:
            let cleanValue = cleanedValue.replacingOccurrences(of: "0b", with: "")
            guard !cleanValue.isEmpty else { return nil }
            if cleanValue.count > bitWidth {
                return "Input has \(cleanValue.count) bits but only \(bitWidth) bits selected"
            }
            return nil
        }
    }
    
    static func format(value: Int, as representation: NumberRepresentation, bitWidth: Int = 16) -> String {
        switch representation {
        case .decimal:
            return "\(value)"
        case .hex:
            let masked = value & ((1 << bitWidth) - 1)
            return "0x" + String(format: "%0*X", bitWidth / 4, masked)
        case .binary:
            let masked = value & ((1 << bitWidth) - 1)
            let binary = String(masked, radix: 2)
            return "0b" + String(repeating: "0", count: max(0, bitWidth - binary.count)) + binary
        case .twosComplement:
            let masked = value & ((1 << bitWidth) - 1)
            let binary = String(masked, radix: 2)
            return "0b" + String(repeating: "0", count: max(0, bitWidth - binary.count)) + binary
        }
    }
    
    private static func signExtend(_ value: Int, bitWidth: Int) -> Int {
        let mask = (1 << bitWidth) - 1
        let masked = value & mask
        let signBit = 1 << (bitWidth - 1)
        
        if masked & signBit != 0 {
            // Negative number - extend sign
            return masked | ~mask
        } else {
            return masked
        }
    }
    
    static func add(_ a: Int, _ b: Int, bitWidth: Int = 16) -> (result: Int, overflow: Bool) {
        let result = a &+ b
        let masked = signExtend(result, bitWidth: bitWidth)
        
        // Check for overflow
        let aSign = (a < 0)
        let bSign = (b < 0)
        let resultSign = (masked < 0)
        let overflow = (aSign == bSign) && (aSign != resultSign)
        
        return (masked, overflow)
    }
    
    static func subtract(_ a: Int, _ b: Int, bitWidth: Int = 16) -> (result: Int, overflow: Bool) {
        return add(a, -b, bitWidth: bitWidth)
    }
    
    static func invert(_ value: Int, bitWidth: Int = 16) -> Int {
        let mask = (1 << bitWidth) - 1
        return (~value) & mask
    }
}
