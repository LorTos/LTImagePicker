//
//  EditingBottomControlsView.swift
//  LTImagePicker
//
//  Created by Lorenzo Toscani De Col on 30/01/2019.
//

import UIKit

protocol EditingBottomControlsDelegate: class {
    func didConfirmPhotoSelection()
    func rotateCropView()
    func resetEdits()
    func changeCropAspectRatio()
}

class EditingBottomControlsView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var inputAndConfirmStackView: UIStackView!
    @IBOutlet weak var editingStackView: UIStackView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var rotateButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var aspectRatioButton: UIButton!
    
    weak var delegate: EditingBottomControlsDelegate?
    
    var viewIsEditing: Bool = false {
        didSet {
            inputAndConfirmStackView.isHidden = viewIsEditing
            editingStackView.isHidden = !viewIsEditing
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle(for: EditingBottomControlsView.self).loadNibNamed("EditingBottomControlsView", owner: self, options: nil)
        view.frame = bounds
        addSubview(view)
        
        backgroundColor = .clear
        view.backgroundColor = .clear
        [confirmButton, aspectRatioButton, rotateButton].forEach({
            $0?.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            $0?.layer.masksToBounds = true
        })
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        resetButton.titleLabel?.shadowColor = UIColor.black.withAlphaComponent(0.5)
        resetButton.titleLabel?.shadowOffset = CGSize(width: 2, height: 4)
        editingStackView.isHidden = true
        inputTextField.clearButtonMode = .whileEditing
        
        [aspectRatioButton, resetButton, confirmButton, rotateButton].forEach({
            $0?.tintColor = UIColor.white
        })
        confirmButton.setImage(UIImage(named: "send", in: Bundle(for: EditingBottomControlsView.self), compatibleWith: nil), for: .normal)
        aspectRatioButton.setImage(UIImage(named: "aspect", in: Bundle(for: EditingBottomControlsView.self), compatibleWith: nil), for: .normal)
        rotateButton.setImage(UIImage(named: "rotate", in: Bundle(for: EditingBottomControlsView.self), compatibleWith: nil), for: .normal)
        [aspectRatioButton, rotateButton, confirmButton].forEach({
            $0?.setTitle("", for: .normal)
        })
        resetButton.setTitle("Reset", for: .normal)
        
        enableTextField(false, shouldHide: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        [confirmButton, aspectRatioButton, rotateButton].forEach({
            $0?.layer.cornerRadius = $0!.bounds.width / 2
        })
    }
    
    func enableTextField(_ isEnabled: Bool, shouldHide: Bool) {
        inputTextField.isUserInteractionEnabled = isEnabled
        inputTextField.alpha = shouldHide ? 0 : 1
        // TODO: - change icon according to isEnabled
    }
    
    @IBAction func tappedOnConfirm(_ sender: UIButton) {
        delegate?.didConfirmPhotoSelection()
    }
    @IBAction func tappedOnRotate(_ sender: UIButton) {
        delegate?.rotateCropView()
    }
    @IBAction func tappedOnReset(_ sender: UIButton) {
        delegate?.resetEdits()
    }
    @IBAction func tappedOnAspectRatio(_ sender: UIButton) {
        delegate?.changeCropAspectRatio()
    }
}
