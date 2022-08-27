//
//  CameraCapture.swift
//  pip-camera
//
//  Created by Naruki Chigira on 2022/08/27.
//

import AVKit

protocol CameraCaptureDelegate: AnyObject {
    func cameraCapture(_ cameraCapture: CameraCapture, didOutput sampleBuffer: CMSampleBuffer)
}

class CameraCapture: NSObject {
    private lazy var session = AVCaptureSession()
    private lazy var queue = DispatchQueue(label: "com.jpn.naru.camera_capture", qos: .background)
    
    weak var delegate: CameraCaptureDelegate?
    
    var isRunning: Bool {
        session.isRunning
    }
    
    func configure() {
        guard let device = AVCaptureDevice.default(for: .video) else {
            fatalError("Failed to get AVCaptureDevice.")
        }
        
        // 30FPS
        device.activeVideoMinFrameDuration = .init(value: 1, timescale: 30)
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            let output: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
            output.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA
            ] as [String : Any]
            output.setSampleBufferDelegate(self, queue: queue)
            session.sessionPreset = .medium
            if session.canAddInput(input) && session.canAddOutput(output) {
                session.addInput(input)
                session.addOutput(output)
            }
            session.connections.first?.videoOrientation = .portrait
        } catch {
            fatalError("Failed to configure input and output.")
        }
    }
    
    func start() {
        guard !isRunning else {
            return
        }
        queue.async {
            self.session.startRunning()
        }
    }
    
    func stop() {
        queue.async {
            self.session.stopRunning()
        }
    }
}

extension CameraCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        DispatchQueue.main.async {
            self.delegate?.cameraCapture(self, didOutput: sampleBuffer)
        }
    }
}
