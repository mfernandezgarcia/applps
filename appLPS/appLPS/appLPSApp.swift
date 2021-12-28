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
            ZStack{
                //Color("backgroundP").ignoresSafeArea()
                VStack {
                        Wave().fill(Color.accentColor).frame(height: 120).overlay(
                            //Text("Firebase App").font(.title).fontWeight(.bold).foregroundColor(.white)
                            Image("logoBlancoColor").resizable().frame(width: 239 , height: 68 ,alignment: .center)
                        )
                    
                    MainView().background(Color("backgroundP")).ignoresSafeArea().environmentObject(FirebaseController()).onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
                }.ignoresSafeArea().background(Color("backgroundP"))
            }

        }
    }
}

/// Estas tres extensiones son para que cuando estemos en un input y seleccionemos fuera se cierre el teclado
extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // set to `false` if you don't want to detect tap during other gestures
    }
}
