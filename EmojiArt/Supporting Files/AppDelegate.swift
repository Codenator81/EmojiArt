//
//  AppDelegate.swift
//  EmojiArt
//
//  Created by Aleksandrs Poltarjonoks on 05/05/2018.
//  Copyright © 2018 Aleksandrs Poltarjonoks. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let mainVC = UINavigationController(rootViewController: EmojiArtViewController())
        
        window = UIWindow(frame: UIScreen.main.bounds)        
        window?.rootViewController = mainVC
        window?.makeKeyAndVisible()
        
        return true
    }
}

