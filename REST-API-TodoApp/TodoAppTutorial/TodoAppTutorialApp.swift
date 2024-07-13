//
//  TodoAppTutorialApp.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/09.
//

import SwiftUI

@main
struct TodoAppTutorialApp: App {
    
    @StateObject var todosVM: TodosVM = TodosVM()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                TodosView()
                    .tabItem {
                        Image(systemName: "1.square.fill")
                        Text("SwiftUi")
                    }
                
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
