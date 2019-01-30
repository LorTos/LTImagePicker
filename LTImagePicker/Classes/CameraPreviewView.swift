//
//  CameraPreviewView.swift
//  LTImagePicker
//
//  Created by Lorenzo Toscani De Col on 30/01/2019.
//

import UIKit
import AVFoundation

protocol CameraPreviewViewDelegate: class {
    func tappedToFocusOnPoint(_ point: CGPoint)
}

class CameraPreviewView: UIView {
    private var tapGesture: UITapGestureRecognizer?
    weak var delegate: CameraPreviewViewDelegate?
    
    var session: AVCaptureSession? {
        get {
            return (self.layer as! AVCaptureVideoPreviewLayer).session
        }
        set (session) {
            let layer = (self.layer as! AVCaptureVideoPreviewLayer)
            layer.videoGravity = .resizeAspectFill
            layer.session = session
        }
    }
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clipsToBounds = true
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedInView(_:)))
        addGestureRecognizer(tapGesture!)
    }
    
    @objc private func tappedInView(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self)
        
        dofocusAnimation(for: tapLocation)
        delegate?.tappedToFocusOnPoint(tapLocation)
    }
    private func dofocusAnimation(for point: CGPoint) {
        let focusView = UIView(frame: CGRect(x: point.x - 50, y: point.y - 50, width: 100, height: 100))
        focusView.layer.cornerRadius = 2
        focusView.layer.masksToBounds = true
        focusView.layer.borderWidth = 2
        focusView.layer.borderColor = UIColor(red: 1, green: 224/255, blue: 30/255, alpha: 1).cgColor
        focusView.backgroundColor = .clear
        
        addSubview(focusView)
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: .calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3, animations: {
                focusView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            })
        }) { _ in
            focusView.removeFromSuperview()
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
