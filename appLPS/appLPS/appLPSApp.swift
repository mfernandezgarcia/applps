//
//  appLPSApp.swift
//  appLPS
//
//  Created by Marta Fernandez Garcia on 25/10/21.
//

import SwiftUI
import Firebase

@main
struct appLPSApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
