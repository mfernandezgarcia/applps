//
//  Prueba.swift
//  appLPS
//
//  Created by Marta Fernandez Garcia on 31/10/21.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase


class FirebaseController {
       
    @Published var errorFound: String = ""
   
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signUp(email: String, password: String) -> Bool {
         var aux: Bool = true
        if ( !email.isEmpty &&  !password.isEmpty ) {
            Auth.auth().createUser(withEmail: email, password: password) {
                authResult, error in
                if (error != nil) {
                    aux = false
                    self.errorFound = error?.localizedDescription ?? ""
                    
                    print("Dentro del bloque")
                    print(self.errorFound)
                }
            }
        }
        print("Antes del return")
        print(self.errorFound)

        return aux
    }
    
}
