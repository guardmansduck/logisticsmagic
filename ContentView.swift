import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var scanner = CameraScanner()
    @StateObject private var historyManager = ScanHistoryManager()
    
    @State private var parsedCode: ParsedCode?
    @State private var lookupResult: String = "Scan a label to see info"
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Background
            
            VStack(spacing: 20) {
                
                // Camera Preview
                CameraPreview(session: scanner.session)
                    .frame(height: 300)
                    .cornerRadius(15)
                    .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.yellow, lineWidth: 3))
                
                // Scan Button
                Button(action: {
                    scanner.startScanning()
                }) {
                    Text("Start Scan")
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
                
                // Display Scanned Code and Lookup
                if let code = parsedCode {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Scanned Code:")
                            .font(.headline)
                            .foregroundColor(.yellow)
                        Text(code.rawValue)
                            .foregroundColor(.white)
                        
                        Text("Type: \(String(describing: code.type))")
                            .foregroundColor(.white)
                        
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
                
                // Scan History List
                Text("Scan History")
                    .font(.headline)
                    .foregroundColor(.yellow)
                    .padding(.top, 10)
                
                List(historyManager.history) { entry in
                    VStack(alignment: .leading) {
                        Text(entry.rawValue)
                            .foregroundColor(.white)
                        Text(entry.lookupResult)
                            .foregroundColor(.yellow)
                        Text(entry.date, style: .date)
                            .foregroundColor(.gray)
                    }
                    .padding(5)
                    .listRowBackground(Color.black)
                }
                .listStyle(PlainListStyle())
                
                Spacer()
                
                // Clear History Button
                Button(action: {
                    historyManager.clearHistory()
                }) {
                    Text("Clear History")
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                
            }
            .padding()
        }
        .onReceive(scanner.$scannedCode) { code in
            guard !code.isEmpty else { return }
            
            let parser = CodeParser()
            let parsed = parser.parseCode(code)
            parsedCode = parsed
            
            let lookup = LookupManager()
            lookup.lookupCode(parsed) { result in
                DispatchQueue.main.async {
                    lookupResult = result
                    
                    // Add to history
                    historyManager.addEntry(rawValue: parsed.rawValue,
                                            type: String(describing: parsed.type),
                                            lookupResult: result)
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
