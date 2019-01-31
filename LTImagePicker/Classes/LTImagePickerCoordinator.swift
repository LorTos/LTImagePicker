//
//  LTImagePickerCoordinator.swift
//  LTImagePicker
//
//  Created by Lorenzo Toscani De Col on 30/01/2019.
//

import Foundation

public class LTImagePickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private weak var navigationController: UINavigationController?
    private var configuration: LTPickerConfig?
    
    public init(configuration: LTPickerConfig? = nil) {
        self.configuration = configuration
        super.init()
    }
    
    public func startCameraFlow(from viewController: UIViewController) {
        let cameraController = CameraInputViewController(coordinator: self, configuration: configuration)
        let cameraNavController = UINavigationController(rootViewController: cameraController)
        navigationController = cameraNavController
        viewController.present(cameraNavController, animated: true, completion: nil)
    }
    
    public func startLibraryPickerFlow(from viewController: UIViewController) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        decorateNavigationBar(imagePicker.navigationBar, with: configuration)
        viewController.present(imagePicker, animated: true, completion: nil)
    }
    
    func goToEditingController(with image: UIImage) {
        let editController = EditingViewController(image: image)
        navigationController?.pushViewController(editController, animated: true)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        let editController = EditingViewController(image: image)
        picker.pushViewController(editController, animated: true)
    }
    
    
    private func decorateNavigationBar(_ navbar: UINavigationBar, with config: LTPickerConfig?) {
        guard let config = config else { return }
        navbar.barTintColor = config.navigationBackgroundColor
        navbar.tintColor = config.navigationTintColor
        navbar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: config.navigationTintColor
        ]
    }
}
