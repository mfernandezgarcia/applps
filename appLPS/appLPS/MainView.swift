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
    @State var mostrarImagePicker: Bool = false
    @State var imageGeneral: UIImage = UIImage()
    @State var imagenes: [Image] = []
    
    
    var body: some View {
        
        VStack {
            if (session.session != nil) {
                
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
                    imagenes = session.getData(correoUsuario: (session.session?.email)!)
                    
                    
                }label:{
                    Text("Getdata")
                }
                
                /*
                 ForEach(0...imagenes.count, id: \.self) { index in
                 // Text()
                 imagenes[index]
                 }*/
                
                Button(){
                    session.uploadStorage(image: imageGeneral)
                }label:{
                    Text("Guardar")
                }.disabled(imageGeneral.pngData() == nil)
                
                
            } else {
                LoginView()
            }
        }.onAppear {
            getUser()
        }
    }
    
    func getUser () {
        session.listen()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(FirebaseController())
    }
}
