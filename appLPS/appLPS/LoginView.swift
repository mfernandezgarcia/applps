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
    @State var error: Bool = false
    @State var loading = false
    
    @EnvironmentObject var session: FirebaseController

    
    var body: some View {
        
        NavigationView {
            VStack {
                Form {
                    TextField("Introduce correo" , text: $email).textCase(.lowercase)
                    SecureField("Introduce contraseña" , text: $password)
                    
                    HStack {
                        NavigationLink(destination:  MainView(), isActive: self.$signInDone) {
                            Text("Iniciar sesion").onTapGesture {
                                login()
                            }
                        }.disabled(email.isEmpty || password.isEmpty )
                    }
                    
                    NavigationLink(destination:  RegistroView()) {
                        Button() {
                        } label: {
                            Text("Registrarse")
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
                
            }.navigationTitle("Log in")
                .onAppear {
                    self.password = ""
                    self.email = ""
                    self.errorFound = ""
                }
            
        }
    }
    
    func login () {
        loading = true
        error = false
        session.signIn(email: email, password: password) { (result, error) in
            self.loading = false
            if error != nil {
                self.error = true
                self.errorFound = error?.localizedDescription ?? ""

            } else {
                self.email = ""
                self.password = ""
                self.signInDone = true
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
