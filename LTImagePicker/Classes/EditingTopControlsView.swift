//
//  EditingTopControlsView.swift
//  LTImagePicker
//
//  Created by Lorenzo Toscani De Col on 30/01/2019.
//

import UIKit

protocol EditingTopControlsDelegate: class {
    func goBack()
    func startEditing()
    func cancelEdits()
    func confirmEdits()
}

class EditingTopControlsView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var navigationStackView: UIStackView!
    @IBOutlet weak var editingStackView: UIStackView!
    
    weak var delegate: EditingTopControlsDelegate?
    var viewIsEditing: Bool = false {
        didSet {
            navigationStackView.isHidden = viewIsEditing
            editingStackView.isHidden = !viewIsEditing
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle(for: EditingTopControlsView.self).loadNibNamed("EditingTopControlsView", owner: self, options: nil)
        view.frame = bounds
        addSubview(view)
        
        backgroundColor = .clear
        view.backgroundColor = .clear
        [backButton, editButton, cancelButton].forEach({
            $0?.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            $0?.layer.masksToBounds = true
        })
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        [backButton, editButton, cancelButton, doneButton].forEach({ $0?.tintColor = .white })
        editingStackView.isHidden = true
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        [backButton, editButton, cancelButton].forEach({
            $0?.layer.cornerRadius = $0!.bounds.width / 2
        })
    }
    
    @IBAction func tappedBack(_ sender: UIButton) {
        delegate?.goBack()
    }
    @IBAction func tappedOnEdit(_ sender: UIButton) {
        delegate?.startEditing()
    }
    @IBAction func tappedOnCancel(_ sender: UIButton) {
        delegate?.cancelEdits()
    }
    @IBAction func tappedOnDone(_ sender: Any) {
        delegate?.confirmEdits()
    }
}
