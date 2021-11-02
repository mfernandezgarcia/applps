//
//  LoginView.swift
//  appLPS
//
//  Created by Marta Fernandez Garcia on 2/11/21.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State var email:String = ""
    @State var password:String = ""
    @State var signInDone: Bool = false
    @State var errorFound: String = ""
    let firebaseController = FirebaseController()
    
    var body: some View {
        
        Form {
            TextField("Introduce correo" , text: $email)
            TextField("Introduce contraseña" , text: $password)
            
            HStack {
                Button() {                    
                    login(email: email, password: password)
                } label: {
                    Text("Iniciar sesion")
                }
            }
            
            if !errorFound.isEmpty {
                if !signInDone {
                    Text(self.errorFound)
                } else {
                    Text("Inicio de sesión hecho")
                }
            }
        }
    }
    
    func login(email: String, password: String) {
        if ( !email.isEmpty &&  !password.isEmpty ) {
            Auth.auth().signIn(withEmail: email, password: password) {
                authResult, error in
                if (error != nil) {
                    signInDone = false
                    self.errorFound = error?.localizedDescription ?? ""
                } else {
                    self.signInDone = true
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
