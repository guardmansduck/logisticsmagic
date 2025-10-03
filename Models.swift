import Foundation

// MARK: - Code Type

enum CodeType {
    case gtin
    case sscc
    case tracking
    case unknown
}

// MARK: - Parsed Code

struct ParsedCode {
    let rawValue: String
    let type: CodeType
    let gtin: String?
    let serial: String?
    let carrier: String?

    /// Parses a raw code string and returns a ParsedCode instance
    static func parse(_ input: String) -> ParsedCode {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)

        // GTIN check (12-14 digits)
        if trimmed.count == 12 || trimmed.count == 13 || trimmed.count == 14,
           trimmed.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil {
            return ParsedCode(rawValue: trimmed, type: .gtin, gtin: trimmed, serial: nil, carrier: nil)
        }

        // SSCC check (18 digits)
        if trimmed.count == 18, trimmed.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil {
            let gtinPart = String(trimmed.prefix(14))
            let serialPart = String(trimmed.suffix(4))
            return ParsedCode(rawValue: trimmed, type: .sscc, gtin: gtinPart, serial: serialPart, carrier: nil)
        }

        // Tracking number guess (numeric string longer than 10 digits)
        if trimmed.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil && trimmed.count > 10 {
            // For simplicity, default carrier is UPS; real app can auto-detect via patterns
            return ParsedCode(rawValue: trimmed, type: .tracking, gtin: nil, serial: nil, carrier: "UPS")
        }

        // Fallback
        return ParsedCode(rawValue: trimmed, type: .unknown, gtin: nil, serial: nil, carrier: nil)
    }
}
