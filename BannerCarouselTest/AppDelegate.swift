//
//  AppDelegate.swift
//  BannerCarousel
//
//  應用程式委託，處理應用程式生命週期事件
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 在 iOS 13+ 中，視窗管理由 SceneDelegate 處理
        return true
    }

    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // 為新的場景建立設定，使用程式碼建立配置而不依賴 Info.plist
        let sceneConfiguration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // 當場景被丟棄時調用
        // 釋放任何與被丟棄場景相關的資源
    }
}
