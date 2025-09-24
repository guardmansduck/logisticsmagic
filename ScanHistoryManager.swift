import Foundation

struct ScanEntry: Codable, Identifiable {
    let id = UUID()
    let rawValue: String
    let type: String
    let date: Date
    let lookupResult: String
}

class ScanHistoryManager: ObservableObject {
    @Published var history: [ScanEntry] = []
    
    private let saveKey = "scanHistory"
    
    init() {
        loadHistory()
    }
    
    func addEntry(rawValue: String, type: String, lookupResult: String) {
        let entry = ScanEntry(rawValue: rawValue, type: type, date: Date(), lookupResult: lookupResult)
        history.insert(entry, at: 0)
        saveHistory()
    }
    
    func clearHistory() {
        history.removeAll()
        saveHistory()
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadHistory() {
        if let saved = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([ScanEntry].self, from: saved) {
            history = decoded
        }
    }
}
