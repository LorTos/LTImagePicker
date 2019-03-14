//
//  TopCameraControlsView.swift
//  LTImagePicker
//
//  Created by Lorenzo Toscani De Col on 30/01/2019.
//

import UIKit

protocol TopCameraControlsDelegate: class {
    func closeCamera()
    func changeFlashMode()
}

class TopCameraControlsView: UIView {
    enum FlashMode {
        case auto
        case off
        case on
    }

    @IBOutlet var view: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    
    private var currentFlashMode: FlashMode = .off
    weak var delegate: TopCameraControlsDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    private func commonInit() {
        Bundle(for: TopCameraControlsView.self).loadNibNamed("TopCameraControlsView", owner: self, options: nil)
        view.frame = bounds
        addSubview(view)
        backgroundColor = .clear
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        [closeButton, flashButton].forEach({
            $0?.tintColor = .white
            $0?.setTitle("", for: .normal)
        })
        closeButton.setImage(UIImage(named: "cancel", in: Bundle(for: TopCameraControlsView.self), compatibleWith: nil), for: .normal)
        flashButton.setImage(UIImage(named: "flash_off", in: Bundle(for: TopCameraControlsView.self), compatibleWith: nil), for: .normal)
    }
    
    func switchFlashIcon() {
        switch currentFlashMode {
        case .on:
            currentFlashMode = .auto
            flashButton.setImage(UIImage(named: "flash_auto", in: Bundle(for: TopCameraControlsView.self), compatibleWith: nil), for: .normal)
            flashButton.tintColor = UIColor(red: 1, green: 224/255, blue: 30/255, alpha: 1)
        case .off:
            currentFlashMode = .on
            flashButton.setImage(UIImage(named: "flash_on", in: Bundle(for: TopCameraControlsView.self), compatibleWith: nil), for: .normal)
            flashButton.tintColor = UIColor(red: 1, green: 224/255, blue: 30/255, alpha: 1)
        case .auto:
            currentFlashMode = .off
            flashButton.setImage(UIImage(named: "flash_off", in: Bundle(for: TopCameraControlsView.self), compatibleWith: nil), for: .normal)
            flashButton.tintColor = .white
        }
    }
    
    func handleDeviceOrientationChange(for newOrientation: UIDeviceOrientation) {
        var transform: CGAffineTransform
        switch newOrientation {
        case .landscapeLeft:
            transform = CGAffineTransform(rotationAngle: .pi / 2)
        case .landscapeRight:
            transform = CGAffineTransform(rotationAngle: -(.pi / 2))
        case .portraitUpsideDown:
            transform = CGAffineTransform(rotationAngle: .pi)
        default:
            transform = .identity
        }
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            [self.closeButton, self.flashButton].forEach({ $0?.transform = transform })
        }, completion: nil)
    }
    
    @IBAction func tappedOnClose(_ sender: UIButton) {
        delegate?.closeCamera()
    }
    @IBAction func tappedOnFlash(_ sender: UIButton) {
        switchFlashIcon()
        delegate?.changeFlashMode()
    }
}
