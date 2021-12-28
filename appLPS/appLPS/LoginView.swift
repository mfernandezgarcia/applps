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
    @State var showResetView = false
    @State var enResetPassword = false
    @EnvironmentObject var session: FirebaseController
    @Environment(\.colorScheme) var colorScheme
    
    init(signInDone: Binding<Bool>) {
        self._signInDone = signInDone
        UINavigationBar.appearance().backgroundColor = UIColor(named:"backgroundP")
        UINavigationBar.appearance().tintColor = UIColor(named: "Color")
        UITableViewCell.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                if #available(iOS 15.0, *) {
                    VStack(alignment: .leading) {
                        Spacer()
                        VStack(alignment: .leading) {
                            HStack {
                                TextField("Email" , text: $email)
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
                            
                            Button() {
                                showResetView.toggle()
                            } label: {
                                Text("Reset password")
                            }.foregroundColor(Color.accentColor).listRowSeparator(.hidden).sheet(isPresented: $showResetView) {} content: {
                                ResetPasswordView().environmentObject(session)
                            }.environment(\.editMode, .constant(enResetPassword ? EditMode.active : EditMode.inactive))
                            
                            HStack {
                                Spacer()
                                Button() {
                                    self.login()
                                } label: {
                                    Text("Log in")
                                }.padding().frame(width: UIScreen.main.bounds.width/1.5, alignment: .center).foregroundColor(.white).background(Color.accentColor).clipShape(Capsule())
                                Spacer()
                            }
                            
                            HStack {
                                NavigationLink(destination: RegistroView()) {
                                    Text("Sign Up").foregroundColor(Color("Color"))
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundColor(Color.gray)
                                }
                            }
                            if !errorFound.isEmpty {
                                if !signInDone {
                                    Text(self.errorFound).foregroundColor(.red).listRowSeparator(.hidden)
                                }
                            }
                        }.padding()
                        Spacer()
                        
                    }.ignoresSafeArea().navigationTitle("Log in").background(Color("backgroundP"))
                }
            }
        }
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
        self.loading = true
        self.error = false
        self.session.signIn(email: email, password: password) { (result, error) in
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

struct ResetPasswordView: View {
    @State var email: String = ""
    @Environment(\.presentationMode) var modoPresentacion
    @EnvironmentObject var session: FirebaseController
    var body: some View{
        GeometryReader { geometry in
            VStack {
                Spacer()
                Spacer()
                VStack {
                    Text("Reset your password").font(.title).fontWeight(.bold)
                    if #available(iOS 15.0, *) {
                        HStack {
                            TextField("Email" , text: $email)
                            Image(systemName: "envelope.fill").foregroundColor(self.email != "" ? Color.accentColor: Color.gray)
                        }.padding().background(Color.gray.opacity(self.email == "" ? 0.1 : 0.2 )).cornerRadius(10).listRowSeparator(.hidden)
                        HStack {
                            Spacer()
                            Button() {
                                session.resetPassword(email: email)
                                modoPresentacion.wrappedValue.dismiss()
                            } label: {
                                Text("Reset")
                            }.padding().frame(width: UIScreen.main.bounds.width/1.5, alignment: .center).foregroundColor(.white).background(Color.accentColor).clipShape(Capsule())
                            Spacer()
                        }
                    }
                }.padding().position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
            }
        }
    }
}



/*struct LoginView_Previews: PreviewProvider {
 static var previews: some View {
 LoginView()
 }
 }*/
