//
//  MainView.swift
//  appLPS
//
//  Created by Marta Fernandez Garcia on 9/11/21.
//

import SwiftUI
import FirebaseStorage

struct MainView: View {
    @EnvironmentObject var session: FirebaseController
    @State var mostrarAddImagen: Bool  = false
    @State var enAnadirImagen: Bool = false
    @State var guardarFoto: Bool = false
    @State var imageGeneral: UIImage = UIImage()
    @State var nombreImage: String = ""
    @State var editImage : Bool = false
    @State var signInDone: Bool = false
    
    var body: some View {
        if #available(iOS 15.0, *) {
            if (signInDone) {
                NavigationView {
                    VStack {
                        VStack {
                            if (session.loading == true){
                                Text("Loading...")
                                ProgressView()
                            }else if (session.empty && session.refImagenesUsuario.count == 0) {
                                Spacer()
                                Text("No pictures found 🙁").padding().background(Color(UIColor.systemGray5)).cornerRadius(10)
                                Spacer()
                                Spacer()
                            } else {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "photo").foregroundColor(Color(UIColor.systemGray)).font(.footnote)
                                        Text("Total: \(session.refImagenesUsuario.count)").foregroundColor(Color(UIColor.systemGray)).font(.footnote)
                                        Spacer()
                                    }.padding(.leading, 20)
                                    List {
                                        ForEach(session.refImagenesUsuario, id: \.self) { userImage in
                                            NavigationLink(destination: EditImagenView(image: userImage).environmentObject(session), isActive: $editImage ) {
                                                FilaView(userImage: userImage)
                                            }.background(Color("backgroundP"))
                                        }.onDelete { indexSet in
                                            session.deleteData(indexSet: indexSet, correoUsuario: session.session?.email ?? "none" )
                                            Task {
                                                await session.getUserData(correoUsuario: session.session?.email ?? "none")
                                            }
                                        }.listRowBackground(Color("backgroundP"))
                                    }.listStyle(.plain)

                                    .onAppear {
                                        UITableView.appearance().backgroundColor = .clear
                                    }
                                    Spacer()
                                }
                            }
                        }.onAppear {
                            Task {
                                await session.getUserData(correoUsuario: (session.session?.email)!)
                            }
                        }
                        Divider()
                        Spacer()
                        Button() {
                            session.signOut()
                            self.signInDone = false
                        } label: {
                            Text("Log out")
                        }.padding().background(Color.accentColor).foregroundColor(Color.white).clipShape(Capsule())
                        Spacer()
                    }.navigationBarTitle("Pictures")
                        .navigationBarItems(trailing:
                                                Button(){
                            mostrarAddImagen.toggle()
                        }label:{
                            Image(systemName:"plus.circle").frame(width:30, height: 30).foregroundColor(Color.accentColor)
                        }
                        ).sheet(isPresented: $mostrarAddImagen) {
                        } content: {
                            AddImagenView(imageGeneral: $imageGeneral, guardarFoto: $guardarFoto, nombreImagen: $nombreImage).environmentObject(session)
                        } .environment(\.editMode, .constant(enAnadirImagen ? EditMode.active : EditMode.inactive))
                        .onAppear {
                            getUser()
                        }.background(Color("backgroundP"))
                    
                }.ignoresSafeArea()
            }else {
                LoginView(signInDone: self.$signInDone)
            }
        }
    }
    
    func getUser () {
        session.listen()
    }
}

struct EditImagenView: View {
    let image: UserImage
    @State var nombreImagen = ""
    @State var showingAlert: Bool = false
    @EnvironmentObject var session: FirebaseController
    
    var body: some View{
        
        VStack {
            Spacer()
            Spacer()
            VStack {
                Image(uiImage: UIImage(data: image.data)!)
                    .resizable()
                       .frame(width: 200, height:200)
                       .cornerRadius(20)
                       .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.accentColor, lineWidth: 3))
                       .padding()
                
                TextField("Nombre de imagen", text:$nombreImagen)
                    .padding().background(Color.gray.opacity(self.nombreImagen == "" ? 0.1 : 0.2 )).cornerRadius(10)
                    .frame(width: UIScreen.main.bounds.midX)
            }.padding().background(Color("backgroundP")).cornerRadius(30)

            Spacer()
            HStack {
                if #available(iOS 15.0, *) {
                    Button(){
                        session.updateData(image: image, correoUsuario: image.email, nuevoNombre: nombreImagen)
                        showingAlert = true
                    }label:{
                        Text("Save")
                    }.padding(.leading, 30).padding(.trailing, 30).padding(.top, 15).padding(.bottom, 15).background(Color.accentColor).foregroundColor(Color.white).clipShape(Capsule())
                        .alert("Your image has been edited successfully", isPresented: $showingAlert) {
                            Button("OK", role: .cancel) { }
                        }
                }
            }.onAppear {
                nombreImagen = image.name
            }
            Spacer()
            Spacer()
        }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).background(Color("backgroundP"))
    }
}

struct AddImagenView: View {
    @State var mostrarImagePicker: Bool = false
    @Binding var imageGeneral: UIImage
    @Binding var guardarFoto: Bool
    @Binding var nombreImagen: String
    @EnvironmentObject var session: FirebaseController
    @State var changed = false
    @Environment(\.presentationMode) var modoPresentacion
    
    var body: some View{
        VStack {
            Text("New image").font(.largeTitle).fontWeight(.bold)
            Button(){
                mostrarImagePicker.toggle() }label:{
                    if ( changed ) {
                        Image(uiImage: imageGeneral) .resizable()
                            .frame(width: 200, height:200)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.accentColor, lineWidth: 3))
                            .padding(.vertical)
                    } else {
                        Image("placeholder") .resizable()
                            .frame(width: 200, height:200)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.accentColor, lineWidth: 3))
                            .padding(.vertical)
                    }
                }
                .sheet(isPresented: $mostrarImagePicker){
                    ImagePicker(sourceType: .photoLibrary, selectedImage: $imageGeneral, changed: $changed )
                }
            
            TextField("Name", text:$nombreImagen)
                .padding().background(Color.gray.opacity(self.nombreImagen == "" ? 0.1 : 0.2 )).cornerRadius(10)
                .frame(width: UIScreen.main.bounds.midX)
            
            Spacer().frame(height: 20)
            HStack {
                Button(){
                    guardarFoto = false
                    modoPresentacion.wrappedValue.dismiss()
                }label:{
                    Text("Cancel")
                }.padding(.leading, 30).padding(.trailing, 30).padding(.top, 15).padding(.bottom, 15).background(Color.gray).foregroundColor(Color.white).clipShape(Capsule())
                
                if #available(iOS 15.0, *) {
                    Button(){
                        session.uploadStorage(image: imageGeneral, correoUsuario: session.session?.email ?? "none", nombre: nombreImagen)
                        guardarFoto = true
                        modoPresentacion.wrappedValue.dismiss()
                        
                    }label:{
                        Text("Save")
                    }.disabled(imageGeneral.pngData() == nil || nombreImagen.isEmpty ).padding(.leading, 30).padding(.trailing, 30).padding(.top, 15).padding(.bottom, 15).background(imageGeneral.pngData() == nil || nombreImagen.isEmpty ? Color.accentColor.opacity(0.5) : Color.accentColor).foregroundColor(Color.white).clipShape(Capsule())
                }
            }
        }.onDisappear() {
            nombreImagen = ""
            imageGeneral = UIImage()
        }
    }
}

struct FilaView: View {
    var userImage: UserImage
    
    var body: some View{
        HStack(alignment: .center, spacing: 30) {
            Image(uiImage: UIImage(data: userImage.data)!).resizable().frame(width: 90, height:90).cornerRadius(10)
            VStack(alignment: .leading) {
                Text("Name").font(.caption).fontWeight(.bold)
                Text("\(userImage.name)").font(.caption)
                
                Text("Date: ").font(.caption).fontWeight(.bold)
                Text("\(userImage.date)").font(.caption)
            }
            
            
        }.padding().frame(width: UIScreen.main.bounds.width/1.2)
        
    }
}



/*struct MainView_Previews: PreviewProvider {
 static var previews: some View {
 MainView().environmentObject(FirebaseController())
 }
 }*/
