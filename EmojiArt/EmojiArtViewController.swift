//
//  ViewController.swift
//  EmojiArt
//
//  Created by Aleksandrs Poltarjonoks on 05/05/2018.
//  Copyright © 2018 Aleksandrs Poltarjonoks. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController {

    var scrollViewHeight: NSLayoutConstraint!
    var scrollViewWidth: NSLayoutConstraint!
    
    lazy var dropZone: UIView = {
        let v = UIView()
        v.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.9372549057, blue: 0.9568627477, alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addInteraction(UIDropInteraction(delegate: self))
        return v
    }()
    
    lazy var scrollView: UIScrollView = {
        let s = UIScrollView()
        s.minimumZoomScale = 0.1
        s.maximumZoomScale = 5.0
        s.delegate = self
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    let emojiArtView = EmojiArtView()
    
    var imageFetcher: ImageFetcher!
    
    var emojiArtBackgroundImage: UIImage? {
        get {
            return emojiArtView.backgroundImage
        }
        set {
            scrollView.zoomScale = 1.0
            emojiArtView.backgroundImage = newValue
            let size = newValue?.size ?? CGSize.zero
            emojiArtView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView.contentSize = size
            scrollViewHeight.constant = size.height
            scrollViewWidth.constant = size.width
            if size.width > 0 && size.height > 0 {
                scrollView.zoomScale = max(dropZone.bounds.size.width / size.width, dropZone.bounds.size.height / size.height)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
    }
    
    func setupViews() {
        view.addSubview(dropZone)
        dropZone.addSubview(scrollView)
        scrollView.addSubview(emojiArtView)
        [
            dropZone.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            dropZone.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dropZone.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            dropZone.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            scrollView.leftAnchor.constraint(greaterThanOrEqualTo: dropZone.leftAnchor),
            scrollView.topAnchor.constraint(greaterThanOrEqualTo: dropZone.topAnchor),
            scrollView.rightAnchor.constraint(greaterThanOrEqualTo: dropZone.rightAnchor),
            scrollView.bottomAnchor.constraint(greaterThanOrEqualTo: dropZone.bottomAnchor),
            scrollView.centerYAnchor.constraint(greaterThanOrEqualTo: dropZone.centerYAnchor),
            scrollView.centerXAnchor.constraint(greaterThanOrEqualTo: dropZone.centerXAnchor),
        ].forEach({$0.isActive = true})
        
        scrollViewHeight = scrollView.heightAnchor.constraint(equalTo: dropZone.heightAnchor)
        scrollViewWidth = scrollView.widthAnchor.constraint(equalTo: dropZone.widthAnchor)
        scrollViewWidth.priority = UILayoutPriority(rawValue: 250)
        scrollViewHeight.priority = UILayoutPriority(rawValue: 250)
        scrollViewHeight.isActive = true
        scrollViewWidth.isActive = true
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
                self.emojiArtBackgroundImage = image
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

extension EmojiArtViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return emojiArtView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewHeight.constant = scrollView.contentSize.height
        scrollViewWidth.constant = scrollView.contentSize.width
    }
    
}

