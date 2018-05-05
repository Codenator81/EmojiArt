//
//  ViewController.swift
//  EmojiArt
//
//  Created by Aleksandrs Poltarjonoks on 05/05/2018.
//  Copyright © 2018 Aleksandrs Poltarjonoks. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController {

    lazy var dropZone: UIView = {
        let v = UIView()
        v.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.9372549057, blue: 0.9568627477, alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addInteraction(UIDropInteraction(delegate: self))
        return v
    }()
    
    let emojiArtView: EmojiArtView = {
        let v = EmojiArtView()
        v.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.9372549057, blue: 0.9568627477, alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var imageFetcher: ImageFetcher!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
    }
    
    func setupViews() {
        view.addSubview(dropZone)
        dropZone.addSubview(emojiArtView)
        [
            dropZone.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            dropZone.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dropZone.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            dropZone.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emojiArtView.leftAnchor.constraint(equalTo: dropZone.leftAnchor),
            emojiArtView.topAnchor.constraint(equalTo: dropZone.topAnchor),
            emojiArtView.rightAnchor.constraint(equalTo: dropZone.rightAnchor),
            emojiArtView.bottomAnchor.constraint(equalTo: dropZone.bottomAnchor)
        ].forEach({$0.isActive = true})
    }
}

extension EmojiArtViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        imageFetcher = ImageFetcher() { (url, image) in
            DispatchQueue.main.async {
                self.emojiArtView.backgroundImage = image
            }
        }
        
        session.loadObjects(ofClass: NSURL.self) { nsurl in
            if let url = nsurl.first as? URL {
                self.imageFetcher.fetch(url)
            }
        }
        session.loadObjects(ofClass: UIImage.self) { images in
            if let image = images.first as? UIImage {
                self.imageFetcher.backup = image
            }
        }
    }
    
}

