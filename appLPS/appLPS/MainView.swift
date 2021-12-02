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
                            Text("Your pictures").font(.title).fontWeight(.bold)
                            if (session.refImagenesUsuario.count == 0) {
                                Text("Loading...")
                                ProgressView()
                            }
                            
                            VStack {
                                Spacer()
                                
                                List {
                                    ForEach(session.refImagenesUsuario, id: \.self) { userImage in
                                        NavigationLink(destination: EditImagenView(image: userImage).environmentObject(session), isActive: $editImage ) {
                                            FilaView(userImage: userImage)
                                        }.listRowSeparator(.hidden).background(RoundedRectangle(cornerRadius: 10).fill(Color("filaBackground"))).listRowInsets(EdgeInsets())
                                        Spacer(minLength: 3)
                                    }.onDelete { indexSet in
                                        session.deleteData(indexSet: indexSet, correoUsuario: session.session?.email ?? "none" )
                                        Task {
                                            await session.getUserData(correoUsuario: session.session?.email ?? "none")
                                        }
                                    }//.listRowInsets(.init(top:0, leading: 0, bottom: 10, trailing: 0))
                                        
                                }.onAppear {
                                    UITableView.appearance().backgroundColor = .clear
                                }
                                Spacer()
                            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                            
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
                        
                    }.navigationBarTitle("Home")
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
        Image(uiImage: UIImage(data: image.data)!).resizable().frame(width: 90, height:90).cornerRadius(10)
        
        
        TextField("Nombre de imagen", text:$nombreImagen)
            .padding().background(Color.gray.opacity(self.nombreImagen == "" ? 0.1 : 0.2 )).cornerRadius(10)
            .frame(width: UIScreen.main.bounds.midX)

        HStack {
            if #available(iOS 15.0, *) {
                Button(){
                    session.updateData(image: image, correoUsuario: image.email, nuevoNombre: nombreImagen)
                    showingAlert = true

                }label:{
                    Text("Guardar")
                }.padding().background(Color.accentColor).foregroundColor(Color.white).clipShape(Capsule())
                    .alert("Your image has been edited successfully", isPresented: $showingAlert) {
                        Button("OK", role: .cancel) { }
                    }
                
            }
        }.onAppear {
            nombreImagen = image.name
        }

    }
}

struct AddImagenView: View {
    @State var mostrarImagePicker: Bool = false
    @Binding var imageGeneral: UIImage
    @Binding var guardarFoto: Bool
    
    @Binding var nombreImagen: String
    @EnvironmentObject var session: FirebaseController
    
    @Environment(\.presentationMode) var modoPresentacion
    
    var body: some View{
        VStack {
            Button(){
                mostrarImagePicker.toggle() }label:{
                    Image(uiImage: imageGeneral) .resizable()
                        .frame(width: 200, height:200)
                        .cornerRadius(100)
                        .overlay(RoundedRectangle(cornerRadius: 100).stroke(Color.accentColor, lineWidth: 2))
                        .padding(.vertical)
                    
                }
                .sheet(isPresented: $mostrarImagePicker){
                    ImagePicker(sourceType: .photoLibrary, selectedImage: $imageGeneral )
                }
            
            TextField("Nombre de imagen", text:$nombreImagen)
                .padding().background(Color.gray.opacity(self.nombreImagen == "" ? 0.1 : 0.2 )).cornerRadius(10)
                .frame(width: UIScreen.main.bounds.midX)

            HStack {
                Button(){
                    guardarFoto = false
                    modoPresentacion.wrappedValue.dismiss()
                }label:{
                    Text("Cancelar")
                }.padding().background(Color.gray).foregroundColor(Color.white).clipShape(Capsule())
                
                if #available(iOS 15.0, *) {
                    Button(){
                        session.uploadStorage(image: imageGeneral, correoUsuario: session.session?.email ?? "none", nombre: nombreImagen)
                        guardarFoto = true
                        modoPresentacion.wrappedValue.dismiss()
                        
                    }label:{
                        Text("Guardar")
                    }.disabled(imageGeneral.pngData() == nil).padding().background(Color.accentColor).foregroundColor(Color.white).clipShape(Capsule())
                    
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
