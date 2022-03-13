//
//  SceneDelegate.swift
//  StockMarketApp
//
//  Created by Nirav virpara on 24/07/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    /// Our main app window
    var window: UIWindow?
 
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let watchListvc = WatchListViewController()
        let watchListnavVc = UINavigationController(rootViewController: watchListvc)
        
        window.rootViewController = watchListnavVc
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }
    
}
