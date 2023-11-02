//
//  ChestnusBrowserApp.swift
//  ChestnusBrowser
//
//  Created by yangjian on 2023/10/27.
//

import SwiftUI
import GADUtil
import ComposableArchitecture

@main
struct ChestnusBrowserApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appdelegate
    
    var body: some Scene {
        WindowGroup {
            AppView(store: Store.init(initialState: AppFeature.State(), reducer: {
                AppFeature()
            }))
        }
    }
    
    class AppDelegate: NSObject, UIApplicationDelegate {
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            GADUtil.share.requestConfig()
            return true
        }
    }
}
