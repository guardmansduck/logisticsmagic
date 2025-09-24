import Foundation

struct ProductInfo: Codable {
    let product_name: String?
    let brand: String?
    let description: String?
    let image_url: String?
    let source: String? // e.g., "OpenFoodFacts", "OpenLibrary", "UPCitemDB"
}
