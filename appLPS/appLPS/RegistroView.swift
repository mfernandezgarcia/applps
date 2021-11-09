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
                        
                       
                        Button() {
                            signUp()
                        } label: {
                            Text("Registro")
                        }

                    }
                    
                                        
                    if !errorFound.isEmpty {
                        Text(self.errorFound)
                    } else if (signUpDone) {
                        Text("Sign up done correctly. Please login")
                    }
                    

                }
            }.navigationTitle("Sign Up")
                .onAppear {
                    self.signUpDone = false
                    self.password = ""
                    self.email = ""
                    self.errorFound = ""
                }
            
        }
    }
    
    
    func signUp () {
        signUpDone = false
        errorFound = ""
        loading = true
        error = false
        session.signUp(email: email, password: password) { (result, error) in
            self.loading = false
            if error != nil {
                self.error = true
                self.errorFound = error?.localizedDescription ?? ""

            } else {
                self.email = ""
                self.password = ""
                self.signUpDone = true
            }
        }
    }
}

struct RegistroView_Previews: PreviewProvider {
    static var previews: some View {
        RegistroView()
    }
}
