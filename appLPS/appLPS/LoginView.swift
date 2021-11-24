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
    @State var errorFound: String = ""
    @State var error: Bool = false
    @State var loading = false
    @State var visible = false
    
    @Binding var signInDone: Bool
    
    @EnvironmentObject var session: FirebaseController
    @Environment(\.colorScheme) var colorScheme

    init(signInDone: Binding<Bool>) {
        self._signInDone = signInDone
        
        // Todas estas propiedades se hacen a nivel global por lo que solo es necesario indicarlo una vez
        UITableView.appearance().backgroundColor = UIColor(named:"backgroundP")
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: (colorScheme == .dark) ? UIColor.white : UIColor.black]
        UITableView.appearance().separatorStyle = .none
        UINavigationBar.appearance().tintColor = (colorScheme == .dark) ? .white : .black
        UINavigationBar.appearance().backgroundColor = UIColor(named:"backgroundP")
        UINavigationBar.appearance().tintColor = UIColor(named:"Color")
        
        UITableViewCell.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        
        NavigationView {
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
                                    self.login()
                                } label: {
                                    Text("Log in")
                                }.padding().frame(width: UIScreen.main.bounds.width/1.5, alignment: .center).foregroundColor(.white).background(Color.accentColor).clipShape(Capsule())
                                Spacer()
                            }
                            
                            NavigationLink(destination: RegistroView()) {
                                Text("Registrarse")
                            }.listRowSeparator(.hidden)
                            
                            if !errorFound.isEmpty {
                                if !signInDone {
                                    Text(self.errorFound).foregroundColor(.red).listRowSeparator(.hidden)
                                }
                            }
                        }.cornerRadius(50).padding().frame(width: geometry.size.width, height: 450, alignment: .center).background(Color("backgroundP")).navigationTitle("Sign In")
                        
                }
            }
        }.ignoresSafeArea().navigationTitle("Log in")
            .onAppear {
                self.password = ""
                self.email = ""
                self.errorFound = ""
            }.toolbar(content: {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Text("Marta Fernández & Alejandro Roca").foregroundColor(.accentColor)
                }
            }
            })
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



/*struct LoginView_Previews: PreviewProvider {
 static var previews: some View {
 LoginView()
 }
 }*/
