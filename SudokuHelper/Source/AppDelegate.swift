//
//  AppDelegate.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/28/21.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var keyCoordinator = AppCoordinator()
    
    static var shared: AppDelegate {
        if Thread.isMainThread {
            return UIApplication.shared.delegate as! AppDelegate
        }

        var appDelegate: AppDelegate!
        DispatchQueue.main.sync {
            appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        }
        return appDelegate
    }
}

// MARK: - Lifecycle
extension AppDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                
        keyCoordinator.start()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
