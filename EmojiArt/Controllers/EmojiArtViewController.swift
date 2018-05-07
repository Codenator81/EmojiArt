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
    let dropPlaceholderCellId = "DropPlaceholderCell"
    let emojiInputCellId = "EmojiInputCell"
    let addEmojiButtonCellId = "AddEmojiButtonCell"
    var emojis = "😀🎁✈️🎱🍎🐶🐝☕️🎼🚲♣️👨‍🎓✏️🌈🤡🎓👻☎️".map { String($0) }
    
    lazy var emojiCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 80)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.dragDelegate = self
        cv.dropDelegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.register(EmojiCVC.self, forCellWithReuseIdentifier: emojiCellId)
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: dropPlaceholderCellId)
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: addEmojiButtonCellId)
        cv.register(TextFieldCollectionViewCell.self, forCellWithReuseIdentifier: emojiInputCellId)
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
    
    private var addingEmoji = false
    
    let addEmojiButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("+", for: .normal)
        b.titleLabel?.font = b.titleLabel?.font.withSize(50)
        b.addTarget(self, action: #selector(addEmoji), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    @objc private func addEmoji() {
        addingEmoji = true
        emojiCV.reloadSections(IndexSet(integer: 0))
    }
    
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

extension EmojiArtViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return emojis.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emojiCellId, for: indexPath)
            if let emojiCell = cell as? EmojiCVC {
                let text = NSAttributedString(string: emojis[indexPath.item], attributes: [.font: font])
                emojiCell.emojilabel.attributedText = text
            }
            return cell
        } else if addingEmoji {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emojiInputCellId, for: indexPath)
            if let inputCell = cell as? TextFieldCollectionViewCell {
                inputCell.resignationHandler = { [weak self, unowned inputCell] in
                    if let text = inputCell.textField.text {
                        self?.emojis = (text.map { String($0) } + self!.emojis).uniquified
                    }
                    self?.addingEmoji = false
                    self?.emojiCV.reloadData()
                }
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: addEmojiButtonCellId, for: indexPath)
            cell.addSubview(addEmojiButton)
            addEmojiButton.centerAnchor(to: cell)
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if addingEmoji && indexPath.section == 0 {
            return CGSize(width: 300, height: 80)
        } else {
            return CGSize(width: 80, height: 80)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let inputCell = cell as? TextFieldCollectionViewCell {
            inputCell.textField.becomeFirstResponder()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if !addingEmoji, let attributedString = (emojiCV.cellForItem(at: indexPath) as? EmojiCVC)?.emojilabel.attributedText {
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
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if let indexPath = destinationIndexPath, indexPath.section == 1 {
            let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
            return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .cancel)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                if let attributedString = item.dragItem.localObject as? NSAttributedString {
                    collectionView.performBatchUpdates({
                        emojis.remove(at: sourceIndexPath.item)
                        emojis.insert(attributedString.string, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                let placeholderContext = coordinator.drop(
                    item.dragItem,
                    to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: dropPlaceholderCellId)
                )
                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let attributedString = provider as? NSAttributedString {
                            placeholderContext.commitInsertion(dataSourceUpdates: { (insertionIndexPath) in
                                self.emojis.insert(attributedString.string, at: insertionIndexPath.item)
                            })
                        } else {
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }
    
    
}






