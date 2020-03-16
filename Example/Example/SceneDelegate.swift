//
//  SceneDelegate.swift
//  Example
//
//  Created by 姜振华 on 2020/3/12.
//  Copyright © 2020 FaceppSwift. All rights reserved.
//

import UIKit
import FaceppSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path),
            let key = dict.object(forKey: "api_key") as? String,
            let secret = dict.object(forKey: "api_secret") as? String {
            FaceppClient.initialization(key: key, secret: secret)
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }
}
