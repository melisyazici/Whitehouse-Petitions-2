//
//  AppDelegate.swift
//  Whitehouse Petitions
//
//  Created by Melis Yazıcı on 22.10.22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if let tabBarController = window?.rootViewController as? UITabBarController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil) // finds main.storyboard bundle, it loads it into a type UIStoryBoard
            let vc = storyboard.instantiateViewController(withIdentifier: "NavController") // then uses that to instantiate the nav controller using the NavController identifier
            vc.tabBarItem = UITabBarItem(tabBarSystemItem: .topRated, tag: 1) // attach tabBarItem to nav controller using the topRated tabBarSystemItem with a tag 1
            tabBarController.viewControllers?.append(vc) // append it to the view controllers array of tab bar controller
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

