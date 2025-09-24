import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var scanner = CameraScanner()
    @State private var parsedCode: ParsedCode?
    @State private var lookupResult: String = "Scan a label to see info"
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Background
            
            VStack(spacing: 20) {
                
                // Camera Preview Placeholder
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
                
                // Display Scanned Code
                if let code = parsedCode {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Scanned Code:")
                            .font(.headline)
                            .foregroundColor(.yellow)
                        Text(code.rawValue)
                            .foregroundColor(.white)
                        
                        Text("Type: \(String(describing: code.type))")
                            .foregroundColor(.white)
                        
                        // Lookup Result
                        Text(lookupResult)
                            .foregroundColor(.white)
                            .padding(.top, 10)
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
            lookup.lookupCode(parsed) { result in
                DispatchQueue.main.async {
                    lookupResult = result
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
