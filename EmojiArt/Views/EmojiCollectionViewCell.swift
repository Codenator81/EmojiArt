//
//  EmojiCollectionViewCell.swift
//  EmojiArt
//
//  Created by Aleksandrs Poltarjonoks on 06/05/2018.
//  Copyright © 2018 Aleksandrs Poltarjonoks. All rights reserved.
//

import UIKit

class EmojiCVC: UICollectionViewCell {
    
    let emojilabel: UILabel = {
        let l = UILabel()
        l.font = l.font.withSize(64)
        return l
    }()
    
    private func setupViews() {
        addSubview(emojilabel)
        emojilabel.centerAnchor(to: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
