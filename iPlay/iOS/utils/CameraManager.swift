//
//  CameraManager.swift
//  iPlay
//
//  Created by Danny Byrd on 4/10/25.
//

#if os(iOS)

import Foundation
import AVFoundation
import CoreImage
import UIKit

class CameraManager: NSObject {
    // 1.
    private let captureSession = AVCaptureSession()
    // 2.
    private var deviceInput: AVCaptureDeviceInput?
    // 3.
    private var videoOutput: AVCaptureVideoDataOutput?
    // 4.
    private let systemPreferredCamera: AVCaptureDevice? = {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .front
        )
        return discoverySession.devices.first
    }()
    // 5.
    private var sessionQueue = DispatchQueue(label: "video.preview.session")
    
    private var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            // Determine if the user previously authorized camera access.
            var isAuthorized = status == .authorized
            
            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }
    
    private var addToPreviewStream: ((CGImage) -> Void)?
    
    lazy var previewStream: AsyncStream<CGImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { cgImage in
                continuation.yield(cgImage)
            }
        }
    }()
    
    // 1.
    override init() {
        super.init()
        
        Task {
            await configureSession()
            await startSession()
        }
    }
    
    // 2.
    private func configureSession() async {
        // 1.
        guard await isAuthorized,
              let systemPreferredCamera,
              let deviceInput = try? AVCaptureDeviceInput(device: systemPreferredCamera)
        else { return }
        
        // 2.
        captureSession.beginConfiguration()
        
        // 3.
        defer {
            self.captureSession.commitConfiguration()
        }
        
        // 4.
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        
        // 5.
        guard captureSession.canAddInput(deviceInput) else {
            print("Unable to add device input to capture session.")
            return
        }
        
        // 6.
        guard captureSession.canAddOutput(videoOutput) else {
            print("Unable to add video output to capture session.")
            return
        }
        
        // 7.
        captureSession.addInput(deviceInput)
        captureSession.addOutput(videoOutput)
        
    }
    
    // 3.
    private func startSession() async {
        /// Checking authorization
        guard await isAuthorized else { return }
        /// Start the capture session flow of data
        captureSession.startRunning()
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let currentFrame = sampleBuffer.cgImage else { return }
        if let rotatedImage = currentFrame.rotated(byDegrees: 90, flippedHorizontally: true) {
            addToPreviewStream?(rotatedImage)
        }
    }
    
}

extension CMSampleBuffer {
    var cgImage: CGImage? {
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(self)
        
        guard let imagePixelBuffer = pixelBuffer else {
            return nil
        }
        
        return CIImage(cvPixelBuffer: imagePixelBuffer).cgImage
    }
}

extension CIImage {
    var cgImage: CGImage? {
        let ciContext = CIContext()
        
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else {
            return nil
        }
        
        return cgImage
    }
}

extension CGImage {
    func rotated(byDegrees degrees: CGFloat, flippedHorizontally: Bool) -> CGImage? {
        let radians = degrees * (.pi / 180)
        let width = CGFloat(self.width)
        let height = CGFloat(self.height)
        
        // Calculate the size of the rotated image
        let rotatedSize = degrees.truncatingRemainder(dividingBy: 180) == 0
            ? CGSize(width: width, height: height)
            : CGSize(width: height, height: width)
        
        // Create Core Graphics context
        guard let colorSpace = self.colorSpace,
              let context = CGContext(
                data: nil,
                width: Int(rotatedSize.width),
                height: Int(rotatedSize.height),
                bitsPerComponent: self.bitsPerComponent,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: self.bitmapInfo.rawValue
              ) else {
            return nil
        }

        // Move the origin to the center and apply transform
        context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        context.rotate(by: radians)
        context.scaleBy(x: flippedHorizontally ? -1.0 : 1.0, y: 1.0)

        // Draw the original image centered
        context.draw(
            self,
            in: CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
        )

        return context.makeImage()
    }
}


#endif
