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
    @State var visible = false
    
    @EnvironmentObject var session: FirebaseController
    
    var body: some View {
        GeometryReader { geometry in
            
            if #available(iOS 15.0, *) {
                Form {
                    HStack {
                        TextField("Email" , text: $email).textCase(.lowercase)
                        Image(systemName: "envelope.fill").foregroundColor(self.email != "" ? Color.accentColor: Color.gray)
                        
                    }.padding().background(Color.gray.opacity(self.email == "" ? 0.1 : 0.2 )).cornerRadius(10).listRowSeparator(.hidden)
                                        
                    
                    HStack {
                        if self.visible {
                            TextField("Password" , text: $password)
                        } else {
                            SecureField("Password" , text: $password)
                        }
                        
                        Button() {
                            self.visible.toggle()
                        } label: {
                            Image(systemName: self.visible ? "eye.fill" : "eye.slash.fill").foregroundColor(self.password != "" ? Color.accentColor: Color.gray)
                        }
                    }.padding().background(Color.gray.opacity(self.password == "" ? 0.1 : 0.2 )).cornerRadius(10).listRowSeparator(.hidden)
                    
                    HStack {
                        Spacer()
                        Button() {
                            signUp()
                        } label: {
                            Text("Sign up")
                        }.padding().frame(width: UIScreen.main.bounds.width/1.5, alignment: .center).foregroundColor(.white).background(Color.accentColor).clipShape(Capsule())
                        Spacer()
                    }.listRowSeparator(.hidden)
                    
                    if !errorFound.isEmpty {
                        Text(self.errorFound).listRowSeparator(.hidden).foregroundColor(.red)
                    } else if (signUpDone) {
                        Text("Sign up done correctly. Please login").listRowSeparator(.hidden).foregroundColor(.green)
                    }
                    
                    
                }.padding().frame(width: geometry.size.width, height: 450).navigationTitle("Sign Up")
                    .onAppear {
                        self.signUpDone = false
                        self.password = ""
                        self.email = ""
                        self.errorFound = ""
                    }.background(Color("backgroundP"))
            }
        }
    }
    
    func signUp () {
        self.signUpDone = false
        self.errorFound = ""
        self.error = false
        self.session.signUp(email: email, password: password) { (result, error) in
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



/*struct RegistroView_Previews: PreviewProvider {
 static var previews: some View {
 RegistroView()
 }
 }*/
