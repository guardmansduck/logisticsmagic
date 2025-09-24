import Foundation

struct ProductInfo: Codable {
    let product_name: String?
    let brand: String?
    let description: String?
    let image_url: String?
}

class GTINLookupManager {
    
    func fetchProductInfo(gtin: String, completion: @escaping (ProductInfo?) -> Void) {
        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(gtin).json"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error {
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let status = json?["status"] as? Int, status == 1,
                   let product = json?["product"] as? [String: Any] {
                    
                    let name = product["product_name"] as? String
                    let brand = product["brands"] as? String
                    let desc = product["generic_name"] as? String
                    let image = product["image_front_small_url"] as? String
                    
                    let info = ProductInfo(product_name: name,
                                           brand: brand,
                                           description: desc,
                                           image_url: image)
                    completion(info)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
}
