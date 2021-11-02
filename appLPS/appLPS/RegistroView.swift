//
//  RegistroView.swift
//  appLPS
//
//  Created by Marta Fernandez Garcia on 2/11/21.
//

import SwiftUI
import FirebaseAuth

struct RegistroView: View {
    @State var email:String = ""
    @State var password:String = ""
    @State var signUpDone: Bool = false
    @State var errorFound: String = ""
    let firebaseController = FirebaseController()

    var body: some View {
        Form {
            TextField("Introduce correo" , text: $email)
            TextField("Introduce contraseña" , text: $password)
            
            HStack {
                Button() {
                    signUp(email: email, password: password)
                } label: {
                    Text("Registro")
                }
            }
            
            if !errorFound.isEmpty {
                if !signUpDone {
                    Text(self.errorFound)
                } else {
                    Text("Registro hecho")
                }
            }
        }
    }
    
    func signUp(email: String, password: String) {
        if ( !email.isEmpty &&  !password.isEmpty ) {
            Auth.auth().createUser(withEmail: email, password: password) {
                authResult, error in
                if (error != nil) {
                    signUpDone = false
                    self.errorFound = error?.localizedDescription ?? ""
                } else {
                    self.signUpDone = true

                }
            }
        }
        print("Antes del return")
        print(self.errorFound)

    }
}

struct RegistroView_Previews: PreviewProvider {
    static var previews: some View {
        RegistroView()
    }
}
