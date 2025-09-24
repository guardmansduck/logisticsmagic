import Foundation

enum CodeType {
    case gtin
    case sscc
    case tracking
    case unknown
}

struct ParsedCode {
    var type: CodeType
    var rawValue: String
    var gtin: String?
    var batch: String?
    var serial: String?
    var carrier: String?
}

class CodeParser {
    
    func parseCode(_ code: String) -> ParsedCode {
        // Remove spaces just in case
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Example logic to detect code type
        if isGTIN(trimmed) {
            return ParsedCode(type: .gtin, rawValue: trimmed, gtin: trimmed)
        } else if isSSCC(trimmed) {
            let (gtin, serial) = parseSSCC(trimmed)
            return ParsedCode(type: .sscc, rawValue: trimmed, gtin: gtin, serial: serial)
        } else if isTrackingNumber(trimmed) {
            let carrier = detectCarrier(trimmed)
            return ParsedCode(type: .tracking, rawValue: trimmed, carrier: carrier)
        } else {
            return ParsedCode(type: .unknown, rawValue: trimmed)
        }
    }
    
    private func isGTIN(_ code: String) -> Bool {
        return code.count == 8 || code.count == 12 || code.count == 13 || code.count == 14
    }
    
    private func isSSCC(_ code: String) -> Bool {
        // SSCCs are 18 digits, start with packaging indicator
        return code.count == 18 && code.allSatisfy({ $0.isNumber })
    }
    
    private func parseSSCC(_ code: String) -> (String, String) {
        // GTIN (positions 2-14) and serial (positions 15-18)
        let gtin = String(code[code.index(code.startIndex, offsetBy: 1)...code.index(code.startIndex, offsetBy: 13)])
        let serial = String(code[code.index(code.startIndex, offsetBy: 14)...code.index(code.startIndex, offsetBy: 17)])
        return (gtin, serial)
    }
    
    private func isTrackingNumber(_ code: String) -> Bool {
        // Simple heuristic: mix of letters and numbers, common lengths 10-22
        return code.count >= 10 && code.count <= 22
    }
    
    private func detectCarrier(_ code: String) -> String? {
        // Simple rules for major carriers (UPS/FedEx/USPS/DHL)
        if code.starts(with: "1Z") { return "UPS" }
        if code.count == 12 && code.allSatisfy({ $0.isNumber }) { return "FedEx" }
        if code.count == 22 && code.allSatisfy({ $0.isNumber }) { return "USPS" }
        return nil
    }
}
