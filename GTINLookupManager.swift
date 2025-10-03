import Foundation

class GTINLookupManager {
    func fetchProductInfo(gtin: String, completion: @escaping (String) -> Void) {
        let urlString = "https://api.publicgtin.com/products/\(gtin)"
        guard let url = URL(string: urlString) else {
            completion("Invalid GTIN URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion("Error: \(error.localizedDescription)")
                return
            }
            guard let data = data, let result = String(data: data, encoding: .utf8) else {
                completion("Failed to decode GTIN data")
                return
            }
            completion(result)
        }.resume()
    }
}
