//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Aleksandrs Poltarjonoks on 08/05/2018.
//  Copyright © 2018 Aleksandrs Poltarjonoks. All rights reserved.
//

import UIKit

struct EmojiArt: Codable{
    var url: URL
    var emojis = [EmojiInfo]()
    
    struct EmojiInfo: Codable {
        let x: Int
        let y: Int
        let text: String
        let size: Int
    }
    
    var json: Data?
    {
        return try? JSONEncoder().encode(self)
    }
    
    
    
    init(url: URL, emojis: [EmojiInfo]) {
        self.url = url
        self.emojis = emojis
    }
}
