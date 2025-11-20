//
//  LC3Converter.swift
//  ECE Tools
//
//  Created by Fiona Pao on 2025/11/19.
//

import Foundation

struct LC3Converter {
    
    // MARK: - Binary to Assembly
    
    static func binaryToAssembly(_ binary: String) -> String? {
        let cleaned = binary.replacingOccurrences(of: "0b", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\t", with: "")
            .replacingOccurrences(of: "\n", with: "")
        
        guard cleaned.count == 16, let instruction = Int(cleaned, radix: 2) else {
            return nil
        }
        
        let opcode = (instruction >> 12) & 0xF
        
        switch opcode {
        case 0b0001: return decodeADD(instruction)
        case 0b0101: return decodeAND(instruction)
        case 0b0000: return decodeBR(instruction)
        case 0b1100: return decodeJMP(instruction)
        case 0b0100: return decodeJSR(instruction)
        case 0b0010: return decodeLD(instruction)
        case 0b1010: return decodeLDI(instruction)
        case 0b0110: return decodeLDR(instruction)
        case 0b1110: return decodeLEA(instruction)
        case 0b1001: return decodeNOT(instruction)
        case 0b1000: return "RTI"
        case 0b0011: return decodeST(instruction)
        case 0b1011: return decodeSTI(instruction)
        case 0b0111: return decodeSTR(instruction)
        case 0b1111: return decodeTRAP(instruction)
        default: return nil
        }
    }
    
    // MARK: - Assembly to Binary
    
    static func assemblyToBinary(_ assembly: String) -> String? {
        let parts = assembly.uppercased()
            .replacingOccurrences(of: ",", with: " ")
            .split(separator: " ")
            .map { String($0) }
        
        guard let instruction = parts.first else { return nil }
        
        switch instruction {
        case "ADD": return encodeADD(parts)
        case "AND": return encodeAND(parts)
        case let br where br.hasPrefix("BR"): return encodeBR(parts)
        case "JMP", "RET": return encodeJMP(parts)
        case "JSR", "JSRR": return encodeJSR(parts)
        case "LD": return encodeLD(parts)
        case "LDI": return encodeLDI(parts)
        case "LDR": return encodeLDR(parts)
        case "LEA": return encodeLEA(parts)
        case "NOT": return encodeNOT(parts)
        case "RTI": return "1000000000000000"
        case "ST": return encodeST(parts)
        case "STI": return encodeSTI(parts)
        case "STR": return encodeSTR(parts)
        case "TRAP": return encodeTRAP(parts)
        default: return nil
        }
    }
    
    // MARK: - Decode Functions
    
    private static func decodeADD(_ inst: Int) -> String {
        let dr = (inst >> 9) & 0x7
        let sr1 = (inst >> 6) & 0x7
        let mode = (inst >> 5) & 0x1
        
        if mode == 1 {
            let imm5 = signExtend(inst & 0x1F, bits: 5)
            return "ADD R\(dr), R\(sr1), #\(imm5)"
        } else {
            let sr2 = inst & 0x7
            return "ADD R\(dr), R\(sr1), R\(sr2)"
        }
    }
    
    private static func decodeAND(_ inst: Int) -> String {
        let dr = (inst >> 9) & 0x7
        let sr1 = (inst >> 6) & 0x7
        let mode = (inst >> 5) & 0x1
        
        if mode == 1 {
            let imm5 = signExtend(inst & 0x1F, bits: 5)
            return "AND R\(dr), R\(sr1), #\(imm5)"
        } else {
            let sr2 = inst & 0x7
            return "AND R\(dr), R\(sr1), R\(sr2)"
        }
    }
    
    private static func decodeBR(_ inst: Int) -> String {
        let n = (inst >> 11) & 0x1
        let z = (inst >> 10) & 0x1
        let p = (inst >> 9) & 0x1
        let offset = signExtend(inst & 0x1FF, bits: 9)
        
        var cond = ""
        if n == 1 { cond += "n" }
        if z == 1 { cond += "z" }
        if p == 1 { cond += "p" }
        if cond.isEmpty { cond = "nzp" }
        
        return "BR\(cond) #\(offset)"
    }
    
    private static func decodeJMP(_ inst: Int) -> String {
        let baseR = (inst >> 6) & 0x7
        if baseR == 7 {
            return "RET"
        }
        return "JMP R\(baseR)"
    }
    
    private static func decodeJSR(_ inst: Int) -> String {
        let mode = (inst >> 11) & 0x1
        if mode == 1 {
            let offset = signExtend(inst & 0x7FF, bits: 11)
            return "JSR #\(offset)"
        } else {
            let baseR = (inst >> 6) & 0x7
            return "JSRR R\(baseR)"
        }
    }
    
    private static func decodeLD(_ inst: Int) -> String {
        let dr = (inst >> 9) & 0x7
        let offset = signExtend(inst & 0x1FF, bits: 9)
        return "LD R\(dr), #\(offset)"
    }
    
    private static func decodeLDI(_ inst: Int) -> String {
        let dr = (inst >> 9) & 0x7
        let offset = signExtend(inst & 0x1FF, bits: 9)
        return "LDI R\(dr), #\(offset)"
    }
    
    private static func decodeLDR(_ inst: Int) -> String {
        let dr = (inst >> 9) & 0x7
        let baseR = (inst >> 6) & 0x7
        let offset = signExtend(inst & 0x3F, bits: 6)
        return "LDR R\(dr), R\(baseR), #\(offset)"
    }
    
    private static func decodeLEA(_ inst: Int) -> String {
        let dr = (inst >> 9) & 0x7
        let offset = signExtend(inst & 0x1FF, bits: 9)
        return "LEA R\(dr), #\(offset)"
    }
    
    private static func decodeNOT(_ inst: Int) -> String {
        let dr = (inst >> 9) & 0x7
        let sr = (inst >> 6) & 0x7
        return "NOT R\(dr), R\(sr)"
    }
    
    private static func decodeST(_ inst: Int) -> String {
        let sr = (inst >> 9) & 0x7
        let offset = signExtend(inst & 0x1FF, bits: 9)
        return "ST R\(sr), #\(offset)"
    }
    
    private static func decodeSTI(_ inst: Int) -> String {
        let sr = (inst >> 9) & 0x7
        let offset = signExtend(inst & 0x1FF, bits: 9)
        return "STI R\(sr), #\(offset)"
    }
    
    private static func decodeSTR(_ inst: Int) -> String {
        let sr = (inst >> 9) & 0x7
        let baseR = (inst >> 6) & 0x7
        let offset = signExtend(inst & 0x3F, bits: 6)
        return "STR R\(sr), R\(baseR), #\(offset)"
    }
    
    private static func decodeTRAP(_ inst: Int) -> String {
        let vector = inst & 0xFF
        return "TRAP x\(String(format: "%02X", vector))"
    }
    
    // MARK: - Encode Functions
    
    private static func encodeADD(_ parts: [String]) -> String? {
        guard parts.count >= 4 else { return nil }
        guard let dr = parseRegister(parts[1]),
              let sr1 = parseRegister(parts[2]) else { return nil }
        
        var instruction = 0b0001 << 12
        instruction |= (dr << 9)
        instruction |= (sr1 << 6)
        
        if parts[3].hasPrefix("R") {
            guard let sr2 = parseRegister(parts[3]) else { return nil }
            instruction |= sr2
        } else {
            guard let imm5 = parseImmediate(parts[3], bits: 5) else { return nil }
            instruction |= (1 << 5)
            instruction |= (imm5 & 0x1F)
        }
        
        return formatBinary(instruction, bits: 16)
    }
    
    private static func encodeAND(_ parts: [String]) -> String? {
        guard parts.count >= 4 else { return nil }
        guard let dr = parseRegister(parts[1]),
              let sr1 = parseRegister(parts[2]) else { return nil }
        
        var instruction = 0b0101 << 12
        instruction |= (dr << 9)
        instruction |= (sr1 << 6)
        
        if parts[3].hasPrefix("R") {
            guard let sr2 = parseRegister(parts[3]) else { return nil }
            instruction |= sr2
        } else {
            guard let imm5 = parseImmediate(parts[3], bits: 5) else { return nil }
            instruction |= (1 << 5)
            instruction |= (imm5 & 0x1F)
        }
        
        return formatBinary(instruction, bits: 16)
    }
    
    private static func encodeBR(_ parts: [String]) -> String? {
        guard parts.count >= 2 else { return nil }
        let brInstruction = parts[0]
        let cond = brInstruction.dropFirst(2).lowercased()
        
        var instruction = 0b0000 << 12
        
        if cond.contains("n") || cond.isEmpty { instruction |= (1 << 11) }
        if cond.contains("z") || cond.isEmpty { instruction |= (1 << 10) }
        if cond.contains("p") || cond.isEmpty { instruction |= (1 << 9) }
        
        guard let offset = parseImmediate(parts[1], bits: 9) else { return nil }
        instruction |= (offset & 0x1FF)
        
        return formatBinary(instruction, bits: 16)
    }
    
    private static func encodeJMP(_ parts: [String]) -> String? {
        var instruction = 0b1100 << 12
        
        if parts[0] == "RET" {
            instruction |= (7 << 6)
        } else {
            guard parts.count >= 2, let baseR = parseRegister(parts[1]) else { return nil }
            instruction |= (baseR << 6)
        }
        
        return formatBinary(instruction, bits: 16)
    }
    
    private static func encodeJSR(_ parts: [String]) -> String? {
        var instruction = 0b0100 << 12
        
        if parts[0] == "JSR" {
            guard parts.count >= 2 else { return nil }
            instruction |= (1 << 11)
            guard let offset = parseImmediate(parts[1], bits: 11) else { return nil }
            instruction |= (offset & 0x7FF)
        } else {
            guard parts.count >= 2, let baseR = parseRegister(parts[1]) else { return nil }
            instruction |= (baseR << 6)
        }
        
        return formatBinary(instruction, bits: 16)
    }
    
    private static func encodeLD(_ parts: [String]) -> String? {
        guard parts.count >= 3 else { return nil }
        guard let dr = parseRegister(parts[1]),
              let offset = parseImmediate(parts[2], bits: 9) else { return nil }
        
        var instruction = 0b0010 << 12
        instruction |= (dr << 9)
        instruction |= (offset & 0x1FF)
        
        return formatBinary(instruction, bits: 16)
    }
    
    private static func encodeLDI(_ parts: [String]) -> String? {
        guard parts.count >= 3 else { return nil }
        guard let dr = parseRegister(parts[1]),
              let offset = parseImmediate(parts[2], bits: 9) else { return nil }
        
        var instruction = 0b1010 << 12
        instruction |= (dr << 9)
        instruction |= (offset & 0x1FF)
        
        return formatBinary(instruction, bits: 16)
    }
    
    private static func encodeLDR(_ parts: [String]) -> String? {
        guard parts.count >= 4 else { return nil }
        guard let dr = parseRegister(parts[1]),
              let baseR = parseRegister(parts[2]),
              let offset = parseImmediate(parts[3], bits: 6) else { return nil }
        
        var instruction = 0b0110 << 12
        instruction |= (dr << 9)
        instruction |= (baseR << 6)
        instruction |= (offset & 0x3F)
        
        return formatBinary(instruction, bits: 16)
    }
    
    private static func encodeLEA(_ parts: [String]) -> String? {
        guard parts.count >= 3 else { return nil }
        guard let dr = parseRegister(parts[1]),
              let offset = parseImmediate(parts[2], bits: 9) else { return nil }
        
        var instruction = 0b1110 << 12
        instruction |= (dr << 9)
        instruction |= (offset & 0x1FF)
        
        return formatBinary(instruction, bits: 16)
    }
    
    private static func encodeNOT(_ parts: [String]) -> String? {
        guard parts.count >= 3 else { return nil }
        guard let dr = parseRegister(parts[1]),
              let sr = parseRegister(parts[2]) else { return nil }
        
        var instruction = 0b1001 << 12
        instruction |= (dr << 9)
        instruction |= (sr << 6)
        instruction |= 0x3F
        
        return formatBinary(instruction, bits: 16)
    }
    
    private static func encodeST(_ parts: [String]) -> String? {
        guard parts.count >= 3 else { return nil }
        guard let sr = parseRegister(parts[1]),
              let offset = parseImmediate(parts[2], bits: 9) else { return nil }
        
        var instruction = 0b0011 << 12
        instruction |= (sr << 9)
        instruction |= (offset & 0x1FF)
        
        return formatBinary(instruction, bits: 16)
    }
    
    private static func encodeSTI(_ parts: [String]) -> String? {
        guard parts.count >= 3 else { return nil }
        guard let sr = parseRegister(parts[1]),
              let offset = parseImmediate(parts[2], bits: 9) else { return nil }
        
        var instruction = 0b1011 << 12
        instruction |= (sr << 9)
        instruction |= (offset & 0x1FF)
        
        return formatBinary(instruction, bits: 16)
    }
    
    private static func encodeSTR(_ parts: [String]) -> String? {
        guard parts.count >= 4 else { return nil }
        guard let sr = parseRegister(parts[1]),
              let baseR = parseRegister(parts[2]),
              let offset = parseImmediate(parts[3], bits: 6) else { return nil }
        
        var instruction = 0b0111 << 12
        instruction |= (sr << 9)
        instruction |= (baseR << 6)
        instruction |= (offset & 0x3F)
        
        return formatBinary(instruction, bits: 16)
    }
    
    private static func encodeTRAP(_ parts: [String]) -> String? {
        guard parts.count >= 2 else { return nil }
        let vectorStr = parts[1].replacingOccurrences(of: "x", with: "")
            .replacingOccurrences(of: "X", with: "")
        guard let vector = Int(vectorStr, radix: 16) else { return nil }
        
        var instruction = 0b1111 << 12
        instruction |= (vector & 0xFF)
        
        return formatBinary(instruction, bits: 16)
    }
    
    // MARK: - Helper Functions
    
    private static func signExtend(_ value: Int, bits: Int) -> Int {
        let signBit = 1 << (bits - 1)
        if (value & signBit) != 0 {
            let mask = ~((1 << bits) - 1)
            return value | mask
        }
        return value
    }
    
    private static func parseRegister(_ str: String) -> Int? {
        let cleaned = str.replacingOccurrences(of: "R", with: "")
        return Int(cleaned)
    }
    
    private static func parseImmediate(_ str: String, bits: Int) -> Int? {
        let cleaned = str.replacingOccurrences(of: "#", with: "")
        
        if cleaned.hasPrefix("x") || cleaned.hasPrefix("X") {
            let hexStr = cleaned.dropFirst()
            guard let value = Int(hexStr, radix: 16) else { return nil }
            return value & ((1 << bits) - 1)
        }
        
        guard let value = Int(cleaned) else { return nil }
        
        if value < 0 {
            let mask = (1 << bits) - 1
            return value & mask
        }
        
        return value
    }
    
    private static func formatBinary(_ value: Int, bits: Int) -> String {
        let binary = String(value & ((1 << bits) - 1), radix: 2)
        return String(repeating: "0", count: max(0, bits - binary.count)) + binary
    }
}
