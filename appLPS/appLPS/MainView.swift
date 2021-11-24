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
    
    @State var signInDone: Bool = false
    
    var body: some View {
        if #available(iOS 15.0, *) {
            //if (signInDone) {
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
                                    FilaView(userImage: userImage).listRowBackground(Color.white)
                                }.onDelete { indexSet in
                                    
                                    session.deleteData(indexSet: indexSet, correoUsuario: "martafernandez16garcia@gmail.com")
                                    
                                    Task {
                                        await session.getUserData(correoUsuario: "martafernandez16garcia@gmail.com")
                                    }
                                }.listRowInsets(.init(top:0, leading: 0, bottom: 0, trailing: 0))
                            }
                            
                            Spacer()
                        }.frame(width: UIScreen.main.bounds.width)
                        
                    }.onAppear {
                        Task {
                            await session.getUserData(correoUsuario: "martafernandez16garcia@gmail.com")
                            
                            // await session.getUserData(correoUsuario: (session.session?.email)!)
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
                    
                }.navigationBarTitle("Inicio")
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
            /*}else {
             LoginView(signInDone: self.$signInDone)
             }*/
        }
    }
    
    func getUser () {
        session.listen()
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
            
            HStack {
                TextField("Nombre de imagen", text:$nombreImagen)
                Button(){
                    guardarFoto = false
                    modoPresentacion.wrappedValue.dismiss()
                }label:{
                    Text("Cancelar")
                }.padding().background(Color.gray).foregroundColor(Color.white).clipShape(Capsule())
                
                if #available(iOS 15.0, *) {
                    Button(){                        
                        session.uploadStorage(image: imageGeneral, correoUsuario: "martafernandez16garcia@gmail.com", nombre: nombreImagen)
                        guardarFoto = true
                        modoPresentacion.wrappedValue.dismiss()
                        
                    }label:{
                        Text("Guardar")
                    }.disabled(imageGeneral.pngData() == nil).padding().background(Color.accentColor).foregroundColor(Color.white).clipShape(Capsule())
                                        
                }
            }
        }
    }
}

struct FilaView: View {
    var userImage: UserImage
    
    var body: some View{
        HStack(alignment: .center, spacing: 30) {
            Image(uiImage: UIImage(data: userImage.data)!).resizable().frame(width: 90, height:90)
            VStack(alignment: .leading) {
                Text("Name").font(.caption).fontWeight(.bold)
                Text("\(userImage.name)").font(.caption)
 
                Text("Date: ").font(.caption).fontWeight(.bold)
                Text("\(userImage.date)").font(.caption)
            }

            
        }.padding().frame(width: UIScreen.main.bounds.width/1.2).background(Color.white)
        
    }
}



/*struct MainView_Previews: PreviewProvider {
 static var previews: some View {
 MainView().environmentObject(FirebaseController())
 }
 }*/
