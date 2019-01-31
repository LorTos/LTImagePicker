//
//  ViewController.swift
//  LTImagePicker
//
//  Created by LorTos on 01/30/2019.
//  Copyright (c) 2019 LorTos. All rights reserved.
//

import UIKit
import LTImagePicker

class ViewController: UIViewController {
    
    private var coordinator: LTImagePickerCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Notification for when you picked an image
        NotificationCenter.default.addObserver(self, selector: #selector(selectedImage(_:)), name: .didFinishPickingImage, object: nil)
        
        // Picker configuration
        let config = LTPickerConfig(navBackgroundColor: UIColor.black,
                                    navTintColor: UIColor.white,
                                    accentColor: UIColor(red: 249/255, green: 215/255, blue: 68/255, alpha: 1),
                                    shouldShowTextInput: false)
        coordinator = LTImagePickerCoordinator(configuration: config)
    }
    
    @IBAction func startImagePickerFlow(_ sender: UIButton) {
        // TIP:
        // Remember to add [weak self] to each action closure to avoid memory cycles
        // when passing the viewController to the coordinator
        
        let alert = UIAlertController(title: nil, message: "Choose photo input", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.coordinator?.startCameraFlow(from: self)
        }
        alert.addAction(cameraAction)
        let libraryAction = UIAlertAction(title: "Photo library", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.coordinator?.startLibraryPickerFlow(from: self)
        }
        alert.addAction(libraryAction)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func selectedImage(_ sender: Notification) {
        // Image should always exist
        if let image = sender.userInfo?["image"] as? UIImage {
            
        }
        
        // Message is available only if you decided to show the textInput in the LTPickerConfig
        // and you write something
        if let message = sender.userInfo?["message"] as? String, !message.isEmpty {
            
        }
    }
}

