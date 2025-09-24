import Foundation

struct ProductInfo: Codable {
    let product_name: String?
    let brand: String?
    let description: String?
}

class GTINLookupManager {
    
    func fetchProductInfo(gtin: String, completion: @escaping (String) -> Void) {
        // Public API example (no API key)
        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(gtin).json"
        
        guard let url = URL(string: urlString) else {
            completion("Invalid GTIN URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion("Error fetching product info: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                completion("No data received")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                if let status = json?["status"] as? Int, status == 1,
                   let product = json?["product"] as? [String: Any] {
                    
                    let name = product["product_name"] as? String ?? "Unknown product"
                    let brand = product["brands"] as? String ?? ""
                    let desc = product["generic_name"] as? String ?? ""
                    
                    var result = name
                    if !brand.isEmpty { result += " (\(brand))" }
                    if !desc.isEmpty { result += " - \(desc)" }
                    
                    completion(result)
                } else {
                    completion("Product not found in public database")
                }
            } catch {
                completion("Error parsing product info: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}
