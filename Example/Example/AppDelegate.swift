//
//  AppDelegate.swift
//  Example
//
//  Created by 姜振华 on 2020/3/12.
//  Copyright © 2020 FaceppSwift. All rights reserved.
//

import UIKit
import FaceppSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path),
            let key = dict.object(forKey: "api_key") as? String,
            let secret = dict.object(forKey: "api_secret") as? String {
            FaceppClient.initialization(key: key, secret: secret)
            FaceppClient.shared?.maxRequestConut = 1
        }
        var id: Int?
        let task = URLSession.shared.dataTask(with: URL(string: "https://www.baidu.com")!) { _, _, _ in
            print("------")
            print(id ?? "no")
        }
        id = task.taskIdentifier
        task.resume()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }

}
