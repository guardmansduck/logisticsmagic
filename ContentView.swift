import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var scanner = CameraScanner()
    @StateObject private var historyManager = ScanHistoryManager()
    
    @State private var parsedCode: ParsedCode?
    @State private var lookupResult: String = "Scan a label to see info"
    @State private var productImageUrl: String?
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                
                // Camera Preview
                CameraPreview(session: scanner.session)
                    .frame(height: 300)
                    .cornerRadius(15)
                    .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.yellow, lineWidth: 3))
                
                // Scan Button
                Button(action: { scanner.startScanning() }) {
                    Text("Start Scan")
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
                
                // Display Scanned Code & Product
                if let code = parsedCode {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Scanned Code:")
                            .font(.headline)
                            .foregroundColor(.yellow)
                        Text(code.rawValue)
                            .foregroundColor(.white)
                        Text("Type: \(String(describing: code.type))")
                            .foregroundColor(.white)
                        
                        if let urlString = productImageUrl, let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.yellow, lineWidth: 2))
                            } placeholder: {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                                    .frame(height: 150)
                            }
                        }
                        
                        Text(lookupResult)
                            .foregroundColor(.white)
                            .padding(.top, 5)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                } else {
                    Text(lookupResult)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                
                // Scan History
                Text("Scan History")
                    .font(.headline)
                    .foregroundColor(.yellow)
                    .padding(.top, 10)
                
                List(historyManager.history) { entry in
                    VStack(alignment: .leading) {
                        Text(entry.rawValue).foregroundColor(.white)
                        Text(entry.lookupResult).foregroundColor(.yellow)
                        Text(entry.date, style: .date).foregroundColor(.gray)
                    }
                    .padding(5)
                    .listRowBackground(Color.black)
                }
                .listStyle(PlainListStyle())
                
                // Clear History
                Button(action: { historyManager.clearHistory() }) {
                    Text("Clear History")
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
        }
        .onReceive(scanner.$scannedCode) { code in
            guard !code.isEmpty else { return }
            
            let parser = CodeParser()
            let parsed = parser.parseCode(code)
            parsedCode = parsed
            
            let lookup = LookupManager()
            
            switch parsed.type {
            case .gtin:
                let multiDB = MultiDBLookupManager()
                multiDB.fetchProduct(gtin: parsed.gtin ?? "") { info in
                    DispatchQueue.main.async {
                        if let info = info {
                            lookupResult = "\(info.product_name ?? "Unknown") \(info.brand ?? "")\n\(info.description ?? "")"
                            productImageUrl = info.image_url
                        } else {
                            lookupResult = "Product not found in any public database"
                            productImageUrl = nil
                        }
                        historyManager.addEntry(rawValue: parsed.rawValue,
                                                type: String(describing: parsed.type),
                                                lookupResult: lookupResult)
                    }
                }
            default:
                lookup.lookupCode(parsed) { result in
                    DispatchQueue.main.async {
                        lookupResult = result
                        productImageUrl = nil
                        historyManager.addEntry(rawValue: parsed.rawValue,
                                                type: String(describing: parsed.type),
                                                lookupResult: lookupResult)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
