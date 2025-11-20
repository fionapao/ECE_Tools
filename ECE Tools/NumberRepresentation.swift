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
    static func convert(from value: String, representation: NumberRepresentation, bitWidth: Int = 16) -> Int? {
        switch representation {
        case .decimal:
            return Int(value)
        case .hex:
            let cleanValue = value.replacingOccurrences(of: "0x", with: "").replacingOccurrences(of: "0X", with: "")
            guard let unsigned = Int(cleanValue, radix: 16) else { return nil }
            // Handle as signed value if necessary
            return signExtend(unsigned, bitWidth: bitWidth)
        case .binary:
            let cleanValue = value.replacingOccurrences(of: "0b", with: "")
            return Int(cleanValue, radix: 2)
        case .twosComplement:
            let cleanValue = value.replacingOccurrences(of: "0b", with: "")
            guard let unsigned = Int(cleanValue, radix: 2) else { return nil }
            return signExtend(unsigned, bitWidth: bitWidth)
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
