//
//  EditingViewController.swift
//  LTImagePicker
//
//  Created by Lorenzo Toscani De Col on 30/01/2019.
//

import UIKit
import CoreImage

class EditingViewController: UIViewController {

    @IBOutlet weak var topControlsView: EditingTopControlsView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var bottomControlsView: EditingBottomControlsView!
    
    //MARK: - Variables
    private var selectedImage: UIImage
    private var cropOverlay = CropGridView()
    private var overlayMaskLayer: CAShapeLayer?
    private var config: LTPickerConfig?
    
    //MARK: - Init and Lifecycle
    init(image: UIImage, config: LTPickerConfig?) {
        selectedImage = image
        self.config = config
        super.init(nibName: "EditingViewController", bundle: Bundle(for: EditingViewController.self))
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        view.backgroundColor = UIColor(red: 13/255, green: 13/255, blue: 13/255, alpha: 1)
        topControlsView.delegate = self
        bottomControlsView.delegate = self
        cropOverlay.delegate = self
        bottomControlsView.inputTextField.delegate = self
        previewImageView.image = selectedImage
        
        if let config = config {
            let showTextField = config.shouldShowTextInput
            bottomControlsView.enableTextField(showTextField, shouldHide: !showTextField)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var shouldAutorotate: Bool {
        return !cropOverlay.isCropping
    }
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.bottom, .top]
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard   let userInfo = notification.userInfo,
            let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let keyboardEndFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let rawAnimationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            else { return }
        
        let animationCurve = UIView.AnimationOptions(rawValue: rawAnimationCurve.uintValue)
        let amountToMove = keyboardEndFrame.height
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.beginFromCurrentState, animationCurve], animations: {
            self.bottomControlsView.transform = CGAffineTransform(translationX: 0, y: -amountToMove)
        }, completion: nil)
    }
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard   let userInfo = notification.userInfo,
            let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let rawAnimationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else { return }
        
        let animationCurve = UIView.AnimationOptions(rawValue: rawAnimationCurve.uintValue)
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.beginFromCurrentState, animationCurve], animations: {
            self.bottomControlsView.transform = .identity
        }, completion: nil)
    }
}

extension EditingViewController: CropGridViewDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
        guard cropOverlay.isCropping else { return }
        if let touchPoint = touches.compactMap({ cropOverlay.touchPoint(for: $0) }).first {
            cropOverlay.activeTouchPoint = touchPoint
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard cropOverlay.isCropping else { return }
        if let activeTouch = touches.first {
            cropOverlay.handleTouchMovement(for: activeTouch)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        cropOverlay.activeTouchPoint = nil
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        cropOverlay.activeTouchPoint = nil
    }
    
    private func contentClippingRect(for imageView: UIImageView) -> CGRect {
        guard   let image = imageView.image,
            imageView.contentMode == .scaleAspectFit,
            image.size.width > 0 && image.size.height > 0 else
        {
            return imageView.bounds
        }
        let scale = imageView.bounds.width / image.size.width
        let size = CGSize(width: image.size.width * scale,
                          height: image.size.height * scale)
        let x = (imageView.bounds.width - size.width) / 2
        let y = (imageView.bounds.height - size.height) / 2
        
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
    
    private func cropImage(_ inputImage: UIImage, cropFrame: CGRect) {
        guard let cgImage = inputImage.cgImage else { return }
        
        let imageDisplayedRect = contentClippingRect(for: previewImageView)
        let adjustedCropFrame: CGRect
        switch inputImage.imageOrientation {
        //Front camera
        case .downMirrored:
            let scaleFactor = max(CGFloat(cgImage.width) / imageDisplayedRect.width, CGFloat(cgImage.height) / imageDisplayedRect.height)
            adjustedCropFrame = CGRect(x: cropFrame.minX * scaleFactor,
                                       y: (imageDisplayedRect.height - (cropFrame.maxY - imageDisplayedRect.minY)) * scaleFactor,
                                       width: cropFrame.width * scaleFactor,
                                       height: cropFrame.height * scaleFactor)
        case .upMirrored:
            let scaleFactor = max(CGFloat(cgImage.width) / imageDisplayedRect.width, CGFloat(cgImage.height) / imageDisplayedRect.height)
            adjustedCropFrame = CGRect(x: (imageDisplayedRect.width - cropFrame.maxX) * scaleFactor,
                                       y: (cropFrame.minY - imageDisplayedRect.minY) * scaleFactor,
                                       width: cropFrame.height * scaleFactor,
                                       height: cropFrame.width * scaleFactor)
        case .leftMirrored:
            let scaleFactor = max(CGFloat(cgImage.width) / imageDisplayedRect.height, CGFloat(cgImage.height) / imageDisplayedRect.width)
            adjustedCropFrame = CGRect(x: (cropFrame.minY - imageDisplayedRect.minY) * scaleFactor,
                                       y: cropFrame.minX * scaleFactor,
                                       width: cropFrame.height * scaleFactor,
                                       height: cropFrame.width * scaleFactor)
        // Back camera
        case .right:
            let scaleFactor = max(CGFloat(cgImage.width) / imageDisplayedRect.height, CGFloat(cgImage.height) / imageDisplayedRect.width)
            adjustedCropFrame = CGRect(x: (cropFrame.minY - imageDisplayedRect.minY) * scaleFactor,
                                       y: (imageDisplayedRect.width - cropFrame.maxX) * scaleFactor,
                                       width: cropFrame.height * scaleFactor,
                                       height: cropFrame.width * scaleFactor)
        case .down:
            let scaleFactor = max(CGFloat(cgImage.width) / imageDisplayedRect.width, CGFloat(cgImage.height) / imageDisplayedRect.height)
            adjustedCropFrame = CGRect(x: (imageDisplayedRect.width - cropFrame.maxX) * scaleFactor,
                                       y: (imageDisplayedRect.height - abs(cropFrame.maxY - imageDisplayedRect.origin.y)) * scaleFactor,
                                       width: cropFrame.width * scaleFactor,
                                       height: cropFrame.height * scaleFactor)
        default:
            let scaleFactor = max(CGFloat(cgImage.width) / imageDisplayedRect.width, CGFloat(cgImage.height) / imageDisplayedRect.height)
            adjustedCropFrame = CGRect(x: cropFrame.minX * scaleFactor,
                                       y: abs(cropFrame.minY - imageDisplayedRect.origin.y) * scaleFactor,
                                       width: cropFrame.width * scaleFactor,
                                       height: cropFrame.height * scaleFactor)
        }
        if let croppedImage = cgImage.cropping(to: adjustedCropFrame) {
            let orientation = selectedImage.imageOrientation
            selectedImage = UIImage(cgImage: croppedImage, scale: 1, orientation: orientation)
            previewImageView.image = selectedImage
        }
    }
    private func createMaskLayer() {
        overlayMaskLayer = CAShapeLayer()
        overlayMaskLayer?.frame = UIScreen.main.bounds
        let path = UIBezierPath(rect: UIScreen.main.bounds)
        path.append(UIBezierPath(rect: cropOverlay.frame))
        overlayMaskLayer?.path = path.cgPath
        overlayMaskLayer?.fillColor = UIColor.black.withAlphaComponent(0.7).cgColor
        overlayMaskLayer?.fillRule = .evenOdd
        previewImageView.layer.addSublayer(overlayMaskLayer!)
    }
    
    func gridDidLayoutSubviews(animated: Bool, finalAspectFrame: CGRect?) {
        if let mask = overlayMaskLayer {
            let path = UIBezierPath(rect: UIScreen.main.bounds)
            path.append(UIBezierPath(rect: finalAspectFrame ?? cropOverlay.frame))
            if animated {
                let animation = CABasicAnimation(keyPath: "path")
                animation.duration = 0.2
                animation.fromValue = mask.path
                animation.toValue = path.cgPath
                mask.add(animation, forKey: nil)
            }
            mask.path = path.cgPath
        }
    }
}

extension EditingViewController: EditingTopControlsDelegate, EditingBottomControlsDelegate {
    func goBack() {
        overlayMaskLayer?.removeFromSuperlayer()
        navigationController?.popViewController(animated: true)
    }
    func startEditing() {
        topControlsView.viewIsEditing = true
        bottomControlsView.viewIsEditing = true
        cropOverlay.setAspectRatio(to: cropOverlay.aspectRatio, inset: 20, animated: false)
        previewImageView.addSubview(cropOverlay)
        createMaskLayer()
    }
    func cancelEdits() {
        topControlsView.viewIsEditing = false
        bottomControlsView.viewIsEditing = false
        cropOverlay.removeFromSuperview()
        overlayMaskLayer?.removeFromSuperlayer()
    }
    func confirmEdits() {
        topControlsView.viewIsEditing = false
        bottomControlsView.viewIsEditing = false
        cropImage(selectedImage, cropFrame: cropOverlay.frame)
        cropOverlay.removeFromSuperview()
        overlayMaskLayer?.removeFromSuperlayer()
    }
    
    func didConfirmPhotoSelection() {
        view.endEditing(true)
        let message = bottomControlsView.inputTextField.text ?? ""
        NotificationCenter.default.post(name: .didFinishPickingImage, object: nil, userInfo: [
            "image": selectedImage,
            "message": message
            ])
        dismiss(animated: true, completion: nil)
    }
    
    func rotateCropView() {
        cropOverlay.rotateIfPossible { didSucceed in
            if !didSucceed {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
        }
    }
    
    func resetEdits() {
        cropOverlay.setAspectRatio(to: cropOverlay.aspectRatio, inset: cropOverlay.aspectRatio.defaultInset, animated: true)
    }
    
    func changeCropAspectRatio() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        CropGridView.AspectRatio.allCases.forEach({ aspect in
            let action = UIAlertAction(title: aspect.title, style: .default, handler: { _ in
                switch aspect {
                case .freeform:
                    self.cropOverlay.setAspectToFreeform()
                default:
                    self.cropOverlay.setAspectRatio(to: aspect, inset: aspect.defaultInset, animated: true)
                }
            })
            alert.addAction(action)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension EditingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
