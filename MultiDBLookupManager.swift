import Foundation

class MultiDBLookupManager {
    
    func fetchProduct(gtin: String, completion: @escaping (ProductInfo?) -> Void) {
        // 1. OpenFoodFacts
        fetchFromOpenFoodFacts(gtin: gtin) { foodInfo in
            if let info = foodInfo {
                completion(info)
                return
            }
            
            // 2. Open Library (ISBN)
            self.fetchFromOpenLibrary(gtin: gtin) { bookInfo in
                if let info = bookInfo {
                    completion(info)
                    return
                }
                
                // 3. UPCitemDB
                self.fetchFromUPCitemDB(gtin: gtin) { generalInfo in
                    completion(generalInfo)
                }
            }
        }
    }
    
    private func fetchFromOpenFoodFacts(gtin: String, completion: @escaping (ProductInfo?) -> Void) {
        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(gtin).json"
        guard let url = URL(string: urlString) else { completion(nil); return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let status = json["status"] as? Int, status == 1,
                  let product = json["product"] as? [String: Any] else {
                completion(nil)
                return
            }
            
            let info = ProductInfo(
                product_name: product["product_name"] as? String,
                brand: product["brands"] as? String,
                description: product["generic_name"] as? String,
                image_url: product["image_front_small_url"] as? String,
                source: "OpenFoodFacts"
            )
            completion(info)
        }.resume()
    }
    
    private func fetchFromOpenLibrary(gtin: String, completion: @escaping (ProductInfo?) -> Void) {
        let urlString = "https://openlibrary.org/api/books?bibkeys=ISBN:\(gtin)&format=json&jscmd=data"
        guard let url = URL(string: urlString) else { completion(nil); return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let bookData = json["ISBN:\(gtin)"] as? [String: Any] else {
                completion(nil)
                return
            }
            
            let title = bookData["title"] as? String
            let authors = (bookData["authors"] as? [[String: Any]])?.compactMap { $0["name"] as? String }.joined(separator: ", ")
            let cover = (bookData["cover"] as? [String: Any])?["medium"] as? String
            
            let info = ProductInfo(
                product_name: title,
                brand: authors,
                description: nil,
                image_url: cover,
                source: "OpenLibrary"
            )
            completion(info)
        }.resume()
    }
    
    private func fetchFromUPCitemDB(gtin: String, completion: @escaping (ProductInfo?) -> Void) {
        // Public endpoints are limited; this is a placeholder for demonstration
        let urlString = "https://api.upcitemdb.com/prod/trial/lookup?upc=\(gtin)"
        guard let url = URL(string: urlString) else { completion(nil); return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let items = json["items"] as? [[String: Any]],
                  let first = items.first else {
                completion(nil)
                return
            }
            
            let info = ProductInfo(
                product_name: first["title"] as? String,
                brand: first["brand"] as? String,
                description: first["description"] as? String,
                image_url: first["images"] as? [String] != nil ? (first["images"] as! [String]).first : nil,
                source: "UPCitemDB"
            )
            completion(info)
        }.resume()
    }
}
