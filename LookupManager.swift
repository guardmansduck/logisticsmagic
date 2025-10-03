import Foundation

class LookupManager {

    func lookupCode(_ parsed: ParsedCode, completion: @escaping (String) -> Void) {
        switch parsed.type {
        case .gtin:
            if let gtin = parsed.gtin {
                lookupGTIN(gtin, completion: completion)
            } else {
                completion("GTIN not found")
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

    // MARK: - Private Methods
    private func lookupGTIN(_ gtin: String, completion: @escaping (String) -> Void) {
        GTINLookupManager().fetchProductInfo(gtin: gtin, completion: completion)
    }

    private func fetchTrackingInfo(carrier: String, code: String, completion: @escaping (String) -> Void) {
        let urlString: String
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

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion("Error fetching tracking info: \(error.localizedDescription)")
                return
            }
            let htmlLength = data?.count ?? 0
            completion("Fetched \(carrier) tracking page (size: \(htmlLength) chars)")
        }.resume()
    }
}
