//
//  BottomCameraControlsView.swift
//  LTImagePicker
//
//  Created by Lorenzo Toscani De Col on 30/01/2019.
//

import UIKit

protocol BottomCameraControlsDelegate: class {
    func takePicture()
    func switchCamera()
    func openPhotoLibrary()
}

class BottomCameraControlsView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var recordView: UIView!
    @IBOutlet weak var galleryImageView: UIImageView!
    @IBOutlet weak var switchCameraButton: UIButton!
    
    weak var delegate: BottomCameraControlsDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle(for: BottomCameraControlsView.self).loadNibNamed("BottomCameraControlsView", owner: self, options: nil)
        view.frame = bounds
        addSubview(view)
        
        backgroundColor = .clear
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        recordView.backgroundColor = UIColor.black
        recordView.layer.borderWidth = 3
        recordView.layer.borderColor = UIColor.white.cgColor
        recordView.layer.masksToBounds = true
        
        switchCameraButton.setImage(UIImage(named: "switch"), for: .normal)
        switchCameraButton.tintColor = UIColor.white
        switchCameraButton.setTitle("", for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        recordView.layer.cornerRadius = recordView.bounds.height / 2
    }
    
    func setRecordButtonBorder(to color: UIColor) {
        recordView.layer.borderColor = color.cgColor
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
            [self.recordView, self.switchCameraButton, self.galleryImageView].forEach({ $0?.transform = transform })
        }, completion: nil)
    }
    
    
    @IBAction func tappedOnRecordView(_ sender: UITapGestureRecognizer) {
        UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: [.calculationModeCubicPaced], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                self.recordView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                self.recordView.transform = .identity
            })
        }, completion: nil)
        
        delegate?.takePicture()
    }
    @IBAction func tappedOnSwitchCamera(_ sender: UIButton) {
        delegate?.switchCamera()
    }
    @IBAction func tappedOnGalleryImageView(_ sender: UITapGestureRecognizer) {
        delegate?.openPhotoLibrary()
    }
}
