//
//  DraggableString.swift
//  EmojiArt
//
//  Created by Aleksandrs Poltarjonoks on 10/05/2018.
//  Copyright © 2018 Aleksandrs Poltarjonoks. All rights reserved.
//

import UIKit
import MobileCoreServices

final class DraggableString: NSObject, Codable, NSItemProviderReading, NSItemProviderWriting {
    
    var text: String?
    var fontSize: CGFloat?
    
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [(kUTTypeData as String)]
    }
    
    static var writableTypeIdentifiersForItemProvider: [String] {
        return [(kUTTypeData as String)]
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> DraggableString {
        
        let decoder = JSONDecoder()
        do {
            let attString = try decoder.decode(DraggableString.self, from: data)
            return attString
        } catch {
            fatalError(error as! String)
        }
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        
        let progress = Progress(totalUnitCount: 100)
        
        do {
            
            let data = try JSONEncoder().encode(self)
            progress.completedUnitCount = 100
            completionHandler(data, nil)
            
        } catch {
            completionHandler(nil, error)
        }
        
        return progress
    }
    
}
