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
        NotificationCenter.default.addObserver(self, selector: #selector(selectedImage(_:)), name: .didFinishPickingImage, object: nil)
        let config = LTPickerConfig(navBackgroundColor: UIColor.black, navTintColor: UIColor.white, accentColor: UIColor(red: 249/255, green: 215/255, blue: 68/255, alpha: 1))
        coordinator = LTImagePickerCoordinator(configuration: config)
    }
    
    @IBAction func startImagePickerFlow(_ sender: UIButton) {
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
        guard let image = sender.userInfo?["image"] as? UIImage else { return }
    }
}

