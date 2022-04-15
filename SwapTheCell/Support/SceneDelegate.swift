//
//  SceneDelegate.swift
//  SwapTheCell
//
//  Created by Владимир Олейников on 15/4/2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let cellsVC = CellsViewController()
        let navigationVC = UINavigationController(rootViewController: cellsVC)
        
        guard let mainScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: mainScene)
        
        window?.rootViewController = navigationVC
        window?.makeKeyAndVisible()
    }
}

