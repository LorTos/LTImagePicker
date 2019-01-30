//
//  CameraManager.swift
//  LTImagePicker
//
//  Created by Lorenzo Toscani De Col on 30/01/2019.
//

import UIKit
import AVFoundation

protocol CameraManagerDelegate: class {
    func didCaptureImage(_ image: UIImage)
}

class CameraManager: NSObject {
    private(set) var captureSession: AVCaptureSession
    private(set) var availableDevices: [Configuration: AVCaptureDevice] = [:]
    private var currentConfiguration: Configuration = Configuration(camera: .back)
    
    var currentCamera: Camera {
        return currentConfiguration.camera
    }
    private(set) var flashMode: AVCaptureDevice.FlashMode = .off
    
    weak var delegate: CameraManagerDelegate?
    
    override init() {
        captureSession = AVCaptureSession()
        super.init()
        commonInit()
    }
    private func commonInit() {
        getAvailableDevices()
        setupSession(with: currentConfiguration)
        captureSession.startRunning()
    }
    deinit {
        captureSession.stopRunning()
    }
    
    private func getAvailableDevices() {
        // Discovery session setup
        var discoverSession: AVCaptureDevice.DiscoverySession
        if #available(iOS 11.1, *) {
            discoverSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera,
                                                                             .builtInTelephotoCamera,
                                                                             .builtInTrueDepthCamera,
                                                                             .builtInWideAngleCamera],
                                                               mediaType: .video,
                                                               position: .unspecified)
        } else {
            discoverSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera,
                                                                             .builtInTelephotoCamera,
                                                                             .builtInWideAngleCamera],
                                                               mediaType: .video,
                                                               position: .unspecified)
        }
        // Adding devices to availables array
        discoverSession.devices.forEach({ device in
            if #available(iOS 11.1, *) {
                switch (device.position, device.deviceType) {
                case (.back, .builtInDualCamera): availableDevices[Configuration(camera: .back, type: .dualCamera)] = device
                case (.back, .builtInTelephotoCamera): availableDevices[Configuration(camera: .back, type: .telephoto)] = device
                case (.back, .builtInWideAngleCamera): availableDevices[Configuration(camera: .back, type: .wideAngle)] = device
                case (.front, .builtInTrueDepthCamera): availableDevices[Configuration(camera: .front, type: .trueDepth)] = device
                case (.front, .builtInWideAngleCamera): availableDevices[Configuration(camera: .front, type: .wideAngle)] = device
                default: break
                }
            } else {
                switch (device.position, device.deviceType) {
                case (.back, .builtInDualCamera): availableDevices[Configuration(camera: .back, type: .dualCamera)] = device
                case (.back, .builtInTelephotoCamera): availableDevices[Configuration(camera: .back, type: .telephoto)] = device
                case (.back, .builtInWideAngleCamera): availableDevices[Configuration(camera: .back, type: .wideAngle)] = device
                case (.front, .builtInWideAngleCamera): availableDevices[Configuration(camera: .front, type: .wideAngle)] = device
                default: break
                }
            }
        })
    }
    
    func switchCamera() {
        if currentCamera == .front {
            setupSession(with: CameraManager.Configuration(camera: .back, type: currentConfiguration.specificType))
        } else if currentCamera == .back {
            setupSession(with: CameraManager.Configuration(camera: .front, type: currentConfiguration.specificType))
        }
    }
    
    func setupSession(with config: Configuration) {
        captureSession.beginConfiguration()
        captureSession.inputs.forEach({ captureSession.removeInput($0) })
        captureSession.outputs.forEach({ captureSession.removeOutput($0) })
        
        // Input
        if  let inputDevice = availableDevices[config],
            let input = try? AVCaptureDeviceInput(device: inputDevice),
            captureSession.canAddInput(input)
        {
            captureSession.addInput(input)
        } else if config.specificType == nil {
            var device: AVCaptureDevice?
            switch config.camera {
            case .back:
                if let dualCamera = availableDevices[Configuration(camera: .back, type: .dualCamera)] {
                    device = dualCamera
                } else if let wideAngle = availableDevices[Configuration(camera: .back, type: .wideAngle)] {
                    device = wideAngle
                } else if let telephoto = availableDevices[Configuration(camera: .back, type: .telephoto)] {
                    device = telephoto
                }
            case .front:
                if let trueDepth = availableDevices[Configuration(camera: .front, type: .trueDepth)] {
                    device = trueDepth
                } else if let wideAngle = availableDevices[Configuration(camera: .front, type: .wideAngle)] {
                    device = wideAngle
                }
            }
            if  let device = device,
                let input = try? AVCaptureDeviceInput(device: device),
                captureSession.canAddInput(input)
            {
                captureSession.addInput(input)
            }
        }
        let photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.isLivePhotoCaptureEnabled = false
            captureSession.addOutput(photoOutput)
        }
        
        captureSession.commitConfiguration()
        currentConfiguration = config
    }
    
    func capturePhoto() {
        guard let photoOutput = captureSession.outputs.first(where: { $0 is AVCapturePhotoOutput }) as? AVCapturePhotoOutput else { return }
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        if #available(iOS 12.0, *) {
            settings.isAutoRedEyeReductionEnabled = true
        }
        if !settings.availablePreviewPhotoPixelFormatTypes.isEmpty {
            settings.previewPhotoFormat = [
                kCVPixelBufferPixelFormatTypeKey: settings.availablePreviewPhotoPixelFormatTypes.first!,
                kCVPixelBufferWidthKey: 100,
                kCVPixelBufferHeightKey: 100
                ] as [String: Any]
        }
        settings.isAutoStillImageStabilizationEnabled = photoOutput.isStillImageStabilizationSupported
        settings.isHighResolutionPhotoEnabled = true
        settings.flashMode = flashMode
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func setFocusPoint(_ point: CGPoint) {
        let configuration = Configuration(camera: currentCamera, type: .wideAngle)
        guard let device = availableDevices[configuration] else { return }
        do {
            try device.lockForConfiguration()
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = point
                device.focusMode = .autoFocus
            }
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
                device.exposureMode = .continuousAutoExposure
            }
            device.unlockForConfiguration()
        } catch { }
    }
    
    func switchFlashMode() {
        switch flashMode {
        case .off:
            flashMode = .on
        case .on:
            flashMode = .auto
        case .auto:
            flashMode = .off
        }
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let image = photo.cgImageRepresentation()?.takeUnretainedValue() {
            delegate?.didCaptureImage(fixOrientation(of: image))
        }
    }
    private func fixOrientation(of image: CGImage) -> UIImage {
        switch (currentCamera, UIDevice.current.orientation) {
        case (.back, .portrait),
             (.back, .portraitUpsideDown),
             (.back, .faceUp),
             (.back, .faceDown):
            return UIImage(cgImage: image, scale: 1, orientation: .right)
        case (.back, .landscapeRight):
            return UIImage(cgImage: image, scale: 1, orientation: .down)
        case (.front, .portrait),
             (.front, .portraitUpsideDown),
             (.front, .faceUp),
             (.front, .faceDown):
            return UIImage(cgImage: image, scale: 1, orientation: .leftMirrored)
        case (.front, .landscapeLeft):
            return UIImage(cgImage: image, scale: 1, orientation: .downMirrored)
        case (.front, .landscapeRight):
            return UIImage(cgImage: image, scale: 1, orientation: .upMirrored)
        default:
            return UIImage(cgImage: image)
        }
    }
}

extension CameraManager {
    enum Camera {
        case front
        case back
    }
    enum Device {
        case wideAngle
        case trueDepth
        case telephoto
        case dualCamera
    }
    struct Configuration: Hashable {
        var camera: Camera
        var specificType: Device?
        
        init(camera: Camera, type: Device? = nil) {
            self.camera = camera
            specificType = type
        }
    }
}

