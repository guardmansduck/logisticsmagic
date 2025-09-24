import SwiftUI
import AVFoundation

class CameraScanner: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var scannedCode: String = ""
    
    private let session = AVCaptureSession()
    
    func startScanning() {
        guard let videoDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [
                .ean8, .ean13, .upce, .code128, .code39, .qr
            ] // Add more types as needed
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        // You will attach this layer to a SwiftUI UIViewRepresentable or a UIView in UIKit
        
        session.startRunning()
    }
    
    func stopScanning() {
        session.stopRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, 
                        didOutput metadataObjects: [AVMetadataObject], 
                        from connection: AVCaptureConnection) {
        if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let value = object.stringValue {
            scannedCode = value
            print("Scanned barcode:", value)
            // Optionally, stop scanning once you get a result:
            session.stopRunning()
        }
    }
}
