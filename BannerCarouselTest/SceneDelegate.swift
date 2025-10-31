//
//  SceneDelegate.swift
//  BannerCarouselTest
//
//  Created by howard_lee on 2025/10/30.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // 確保場景是 UIWindowScene
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // 建立主視窗
        window = UIWindow(windowScene: windowScene)
        
        // 建立主視圖控制器
        let mainViewController = ViewController()
        
        // 建立導航控制器
        let navigationController = UINavigationController(rootViewController: mainViewController)
        
        // 設定根視圖控制器
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // 當場景被系統釋放時調用
        // 這會在場景進入背景後不久發生，或當其 session 被丟棄時發生
        // 釋放任何與此場景相關的資源，這些資源可以在下次場景連接時重新建立
        // 場景可能會稍後重新連接，因為其 session 不一定被丟棄
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // 當場景從非活躍狀態變為活躍狀態時調用
        // 使用此方法重新啟動場景非活躍時暫停（或尚未開始）的任務
        
        // 通知 Banner 輪播視圖恢復自動滾動
        NotificationCenter.default.post(name: NSNotification.Name("SceneDidBecomeActive"), object: nil)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // 當場景即將從活躍狀態變為非活躍狀態時調用
        // 這可能由於暫時中斷（例如來電）而發生
        
        // 通知 Banner 輪播視圖暫停自動滾動
        NotificationCenter.default.post(name: NSNotification.Name("SceneWillResignActive"), object: nil)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // 當場景從背景轉換到前景時調用
        // 使用此方法撤銷進入背景時所做的更改
        
        // 通知 Banner 輪播視圖準備進入前景
        NotificationCenter.default.post(name: NSNotification.Name("SceneWillEnterForeground"), object: nil)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // 當場景從前景轉換到背景時調用
        // 使用此方法保存資料、釋放共享資源，並儲存足夠的場景特定狀態資訊
        // 以將場景恢復到當前狀態
        
        // 通知 Banner 輪播視圖進入背景
        NotificationCenter.default.post(name: NSNotification.Name("SceneDidEnterBackground"), object: nil)
    }
}

