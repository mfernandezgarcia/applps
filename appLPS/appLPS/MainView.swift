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
    
    
    var body: some View {
        if #available(iOS 15.0, *) {
            NavigationView {
                                
                if (session.session != nil) {
                    VStack {
                        if (session.refImagenesUsuario.count == 0) {
                            Text("Esta cargando")
                        }
                        
                        VStack {
                            List() {
                                ForEach(session.refImagenesUsuario, id: \.self) { ref in
                                    FilaView(ref: ref)
                                }
                            }
                        }.onAppear {
                            Task {
                                await session.getUserData(correoUsuario:(session.session?.email)!)
                            }
                        }
                        
                    }.navigationBarTitle("Inicio")
                        .navigationBarItems(trailing:
                                                Button(){
                            mostrarAddImagen.toggle()
                        }label:{
                            Image(systemName:"plus.circle").frame(width:30, height: 30)
                        }.foregroundColor(.blue)
                                            
                        ).sheet(isPresented: $mostrarAddImagen) {
                        } content: {
                            AddImagenView(imageGeneral: $imageGeneral, guardarFoto: $guardarFoto).environmentObject(session)
                        } .environment(\.editMode, .constant(enAnadirImagen ? EditMode.active : EditMode.inactive))
                    
                    
                }else {
                    LoginView()
                }
            }.onAppear {
                getUser()
               
            }
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
    @EnvironmentObject var session: FirebaseController
    
    @Environment(\.presentationMode) var modoPresentacion
    
    var body: some View{
        VStack {
            Button(){
                mostrarImagePicker.toggle() }label:{
                    Image(uiImage: imageGeneral) .resizable()
                        .frame(width: 90, height:90)
                        .cornerRadius(100)
                        .overlay(RoundedRectangle(cornerRadius: 100).stroke(Color.red, lineWidth: 2))
                        .padding(.vertical)
                    
                }
                .sheet(isPresented: $mostrarImagePicker){
                    ImagePicker(sourceType: .photoLibrary, selectedImage: $imageGeneral )
                }
            
            Button(){
                guardarFoto = false
                modoPresentacion.wrappedValue.dismiss()
            }label:{
                Text("Cancelar")
            }
            
            if #available(iOS 15.0, *) {
                Button(){
                    
                    Task {
                        do {
                            try await session.uploadStorage(image: imageGeneral, correoUsuario:(session.session?.email)!)
                            
                        } catch {
                            //
                        }
                    }
                    guardarFoto = true
                    modoPresentacion.wrappedValue.dismiss()
                }label:{
                    Text("Guardar")
                }.disabled(imageGeneral.pngData() == nil)
                
            }
        }
    }
}

struct FilaView: View {
    var ref: Data
    
    var body: some View{
        VStack {
            Image(uiImage: UIImage(data: ref)!).resizable().frame(width: 100, height: 100)
        }
    }
}

/*struct MainView_Previews: PreviewProvider {
 static var previews: some View {
 MainView().environmentObject(FirebaseController())
 }
 }*/
