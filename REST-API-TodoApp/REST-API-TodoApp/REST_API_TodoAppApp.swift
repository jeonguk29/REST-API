//
//  REST_API_TodoAppApp.swift
//  REST-API-TodoApp
//
//  Created by 정정욱 on 7/12/24.
//

import SwiftUI

@main
struct REST_API_TodoAppApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                
                ContentView()
                    .tabItem {
                        Image(systemName: "1.square.fill")
                        Text("SwiftUi")
                    }
                
                // 앱 레벨은 전체적으로 스유지만 부분적으로 UIKit을 사용
                MainVC.instantiate()
                    .getRepresentable()
                    .tabItem {
                        Image(systemName: "2.square.fill")
                        Text("UIKit")
                    }
            }
        }
    }
}
