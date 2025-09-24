import Foundation

class LookupManager {
    
    func lookupCode(_ parsed: ParsedCode, completion: @escaping (String) -> Void) {
        switch parsed.type {
        case .gtin:
            let multiDB = MultiDBLookupManager()
            multiDB.fetchProduct(gtin: parsed.gtin ?? "") { info in
                if let info = info {
                    let result = "\(info.product_name ?? "Unknown") \(info.brand ?? "")\n\(info.description ?? "")"
                    completion(result)
                } else {
                    completion("Product not found in any public database")
                }
            }
            
        case .sscc:
            let info = """
            SSCC Detected:
            GTIN: \(parsed.gtin ?? "N/A")
            Serial: \(parsed.serial ?? "N/A")
            """
            completion(info)
            
        case .tracking:
            if let carrier = parsed.carrier {
                fetchTrackingInfo(carrier: carrier, code: parsed.rawValue, completion: completion)
            } else {
                completion("Unknown carrier for tracking number: \(parsed.rawValue)")
            }
            
        case .unknown:
            completion("Unrecognized code: \(parsed.rawValue)")
        }
    }
    
    // Tracking fetch (simplified)
    private func fetchTrackingInfo(carrier: String, code: String, completion: @escaping (String) -> Void) {
        var urlString: String
        
        switch carrier {
        case "UPS":
            urlString = "https://www.ups.com/track?loc=en_US&tracknum=\(code)"
        case "FedEx":
            urlString = "https://www.fedex.com/fedextrack/?trknbr=\(code)"
        case "USPS":
            urlString = "https://tools.usps.com/go/TrackConfirmAction?qtc_tLabels1=\(code)"
        default:
            completion("Carrier \(carrier) not supported yet")
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion("Invalid tracking URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion("Error fetching tracking info: \(error.localizedDescription)")
                return
            }
            
            guard let html = data.flatMap({ String(data: $0, encoding: .utf8) }) else {
                completion("Failed to decode tracking page")
                return
            }
            
            completion("Fetched \(carrier) tracking page (size: \(html.count) chars)")
        }
        task.resume()
    }
}
