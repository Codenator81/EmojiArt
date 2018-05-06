//
//  ViewController.swift
//  EmojiArt
//
//  Created by Aleksandrs Poltarjonoks on 05/05/2018.
//  Copyright © 2018 Aleksandrs Poltarjonoks. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController {

    private var font: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(64.0))
    }
    var scrollViewSize: AnchorSize!
    let emojiCellId = "emojiCellId"
    var emojis = "😀🎁✈️🎱🍎🐶🐝☕️🎼🚲♣️👨‍🎓✏️🌈🤡🎓👻☎️".map { String($0) }
    
    lazy var emojiCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 80)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.dragDelegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.register(EmojiCVC.self, forCellWithReuseIdentifier: emojiCellId)
        return cv
    }()
    
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
            scrollViewSize.height.constant = size.height
            scrollViewSize.width.constant = size.width
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
    
    private func setupViews() {
        view.addSubview(emojiCV)
        view.addSubview(dropZone)
        dropZone.addSubview(scrollView)
        scrollView.addSubview(emojiArtView)
        [
            emojiCV.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emojiCV.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            emojiCV.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            emojiCV.heightAnchor.constraint(equalToConstant: 80),
            
            dropZone.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            dropZone.topAnchor.constraint(equalTo: emojiCV.bottomAnchor, constant: 8),
            dropZone.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            dropZone.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            scrollView.leftAnchor.constraint(greaterThanOrEqualTo: dropZone.leftAnchor),
            scrollView.topAnchor.constraint(greaterThanOrEqualTo: dropZone.topAnchor),
            scrollView.rightAnchor.constraint(greaterThanOrEqualTo: dropZone.rightAnchor),
            scrollView.bottomAnchor.constraint(greaterThanOrEqualTo: dropZone.bottomAnchor),
        ].forEach({$0.isActive = true})        
        
        scrollView.centerAnchor(to: dropZone)
        scrollViewSize = scrollView.sizeAnchor(equalTo: dropZone, priority: 250)
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
        scrollViewSize.height.constant = scrollView.contentSize.height
        scrollViewSize.width.constant = scrollView.contentSize.width
    }
    
}

extension EmojiArtViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emojiCellId, for: indexPath) as! EmojiCVC
        let text = NSAttributedString(string: emojis[indexPath.item], attributes: [.font: font])
        cell.emojilabel.attributedText = text
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let attributedString = (emojiCV.cellForItem(at: indexPath) as? EmojiCVC)?.emojilabel.attributedText {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attributedString))
            dragItem.localObject = attributedString
            return [dragItem]
        } else {
            return []
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
}






