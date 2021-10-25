//
//  Firebase.swift
//  appLPS
//
//  Created by Marta Fernandez Garcia on 25/10/21.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions:
                   [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
      content_copy

    return true
  }
}
