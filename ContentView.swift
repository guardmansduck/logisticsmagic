import SwiftUI

struct ContentView: View {
    @State private var codeInput: String = ""
    @State private var outputText: String = ""

    private let lookupManager = LookupManager()

    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter GTIN/SSCC/Tracking", text: $codeInput)
                .padding()
                .background(Color.white)
                .cornerRadius(8)

            Button(action: lookupAction) {
                Text("Lookup Code")
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(8)
            }

            ScrollView {
                Text(outputText)
                    .padding()
                    .foregroundColor(.white)
            }
            .background(Color.black)
            .cornerRadius(8)
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private func lookupAction() {
        let parsed = ParsedCode.parse(codeInput)
        lookupManager.lookupCode(parsed) { result in
            DispatchQueue.main.async {
                self.outputText = result
            }
        }
    }
}
