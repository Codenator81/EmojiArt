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
        
        let mainVC = UINavigationController(rootViewController: EmojiArtDocumentVC())
        let detailVC = EmojiArtViewController()
        
        let splitVC = UISplitViewController()
        // [0] - master [1] - detail
        splitVC.viewControllers = [mainVC, detailVC]
        
        window = UIWindow(frame: UIScreen.main.bounds)        
        window?.rootViewController = splitVC
        window?.makeKeyAndVisible()
        
        return true
    }
}

