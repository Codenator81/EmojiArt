//
//  EmojiCollectionViewCell.swift
//  EmojiArt
//
//  Created by Aleksandrs Poltarjonoks on 06/05/2018.
//  Copyright © 2018 Aleksandrs Poltarjonoks. All rights reserved.
//

import UIKit

class EmojiPlaceholderCVC: UICollectionViewCell {
    
    let spinner: UIActivityIndicatorView = {
        let l = UIActivityIndicatorView()
        l.startAnimating()
        return l
    }()
    
    private func setupViews() {
        addSubview(spinner)
        spinner.centerAnchor(to: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
