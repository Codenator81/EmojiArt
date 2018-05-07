//
//  TextFieldCollectionViewCell.swift
//  EmojiArt
//
//  Created by Aleksandrs Poltarjonoks on 07/05/2018.
//  Copyright © 2018 Aleksandrs Poltarjonoks. All rights reserved.
//

import UIKit

class TextFieldCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    lazy var textField: UITextField = {
        let t = UITextField()
        t.clearsOnBeginEditing = true
        t.font = t.font?.withSize(50)
        t.delegate = self
        t.borderStyle = .roundedRect
        t.minimumFontSize = 9
        t.adjustsFontSizeToFitWidth = true
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    var resignationHandler: (() -> Void)?
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignationHandler?()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func setupViews() {
        addSubview(textField)
        [
            textField.centerYAnchor.constraint(equalTo: centerYAnchor),
            textField.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            textField.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
        ].forEach { $0.isActive = true }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
