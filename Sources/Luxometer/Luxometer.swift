import Foundation
import AVKit


@available(iOS 11.1, *)
public class Luxometer : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate{
    public var capturedIlluminance : (Int) -> ()
    private var permissionGranted = false
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    
    init(capturedIlluminance : @escaping (Int) -> ()){
        self.capturedIlluminance = capturedIlluminance
    }
    
    
    public func startMeasurement(){
        checkPermission()
        sessionQueue.async { [unowned self] in
            self.setupCaptureSession()
            self.captureSession.startRunning()
        }
        
    }
    
    public func stopMeasurement(){
        sessionQueue.async { [unowned self] in
            self.captureSession.stopRunning()
        }
        
    }
    
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
            
        case .notDetermined:
            requestPermission()
            
        default:
            permissionGranted = false
        }
    }
    
    
    private func setupCaptureSession() {
        let videoOutput = AVCaptureVideoDataOutput()
        guard permissionGranted else {
            print("Luxometer does not have camera permission")
            return
            
        }
        let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        print(discovery.devices)
        guard let videoDevice = AVCaptureDevice.default(.builtInTrueDepthCamera,for: .video, position: .front) else {
            print("Luxometer cannot get access to the built in True Depth front camera")
            return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession.addOutput(videoOutput)
        videoOutput.connection(with: .video)?.videoOrientation = .portrait
    }
    
    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
        }
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let rawMetadata = CMCopyDictionaryOfAttachments(allocator: nil, target: sampleBuffer, attachmentMode: CMAttachmentMode(kCMAttachmentMode_ShouldPropagate))
        let metadata = CFDictionaryCreateMutableCopy(nil, 0, rawMetadata) as NSMutableDictionary
        let exifData = metadata.value(forKey: "{Exif}") as? NSMutableDictionary
        let brightness : Double = exifData?["BrightnessValue"] as! Double
        capturedIlluminance(Int(70*pow(2, brightness)))
    }
}
