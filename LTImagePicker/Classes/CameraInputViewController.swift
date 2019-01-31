//
//  CameraInputViewController.swift
//  LTImagePicker
//
//  Created by Lorenzo Toscani De Col on 30/01/2019.
//

import UIKit

class CameraInputViewController: UIViewController, CameraManagerDelegate {

    @IBOutlet weak var topControlsView: TopCameraControlsView!
    @IBOutlet weak var bottomControlsView: BottomCameraControlsView!
    @IBOutlet weak var previewView: CameraPreviewView!
    
    private weak var coordinator: LTImagePickerCoordinator?
    private var manager = CameraManager()
    private var currentDeviceOrientation = UIDevice.current.orientation
    private var config: LTPickerConfig?
    
    init(coordinator: LTImagePickerCoordinator, configuration: LTPickerConfig?) {
        self.coordinator = coordinator
        config = configuration
        super.init(nibName: "CameraInputViewController", bundle: Bundle(for: CameraInputViewController.self))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomControlsView.delegate = self
        previewView.delegate = self
        topControlsView.delegate = self
        manager.delegate = self
        if let config = config {
            bottomControlsView.recordView.layer.borderColor = config.accentColor.cgColor
            previewView.setFocusColor(to: config.accentColor)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        previewView.session = manager.captureSession
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var shouldAutorotate: Bool {
        handleDeviceRotation()
        return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private func handleDeviceRotation() {
        let newOrientation = UIDevice.current.orientation
        if newOrientation != currentDeviceOrientation {
            topControlsView.handleDeviceOrientationChange(for: newOrientation)
            bottomControlsView.handleDeviceOrientationChange(for: newOrientation)
            currentDeviceOrientation = newOrientation
        }
    }
    
    func didCaptureImage(_ image: UIImage) {
        coordinator?.goToEditingController(with: image)
    }
}

extension CameraInputViewController: TopCameraControlsDelegate, BottomCameraControlsDelegate, CameraPreviewViewDelegate {
    func closeCamera() {
        dismiss(animated: true, completion: nil)
    }
    
    func changeFlashMode() {
        manager.switchFlashMode()
    }
    
    func takePicture() {
        manager.capturePhoto()
    }
    
    func switchCamera() {
        manager.switchCamera()
    }
    
    func openPhotoLibrary() {
        // Open image gallery
    }
    
    func tappedToFocusOnPoint(_ point: CGPoint) {
        let absolutePoint = CGPoint(x: point.x / previewView.bounds.width, y: point.y / previewView.bounds.height)
        manager.setFocusPoint(absolutePoint)
    }
}
