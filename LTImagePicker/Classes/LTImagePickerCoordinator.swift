//
//  LTImagePickerCoordinator.swift
//  LTImagePicker
//
//  Created by Lorenzo Toscani De Col on 30/01/2019.
//

import Foundation

public class CameraCropCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private weak var navigationController: UINavigationController?
    
    public func startCameraFlow(from viewController: UIViewController) {
//        let cameraController = CameraInputController(self)
//        let cameraNavController = UINavigationController(rootViewController: cameraController)
//        navigationController = cameraNavController
//        viewController.present(cameraNavController, animated: true, completion: nil)
    }
    
    public func startLibraryPickerFlow(from viewController: UIViewController) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        viewController.present(imagePicker, animated: true, completion: nil)
    }
    
    func goToEditingController(with image: UIImage) {
//        let editController = ImageEditingViewController(image: image)
//        navigationController?.pushViewController(editController, animated: true)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        guard let image = info[.originalImage] as? UIImage else { return }
//        goToEditingController(with: image)
//        let editController = ImageEditingViewController(image: image)
//        picker.pushViewController(editController, animated: true)
    }
}
