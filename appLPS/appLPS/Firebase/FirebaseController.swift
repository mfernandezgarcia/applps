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
import SwiftUI
import Firebase
import Combine
import UIKit
import FirebaseStorage
import Photos

// https://www.andyibanez.com/posts/understanding-async-await-in-swift/


class FirebaseController: ObservableObject {
    
    let storage = Storage.storage()
    // @Published var imagenes: [Image] = []
    @Published var refImagenesUsuario: [UserImage] = []
    @Published var loading = false
    
    
    var didChange = PassthroughSubject<FirebaseController, Never>()
    var session: User? { didSet { self.didChange.send(self) }}
    var handle: AuthStateDidChangeListenerHandle?
    
    let queue = DispatchQueue(label: "Prueba", attributes: .concurrent);
    let myGroup = DispatchGroup()
    
    // let semph = DispatchSemaphore(value: 0)
    
    @available(iOS 15.0.0, *)
    func getUserData(correoUsuario: String) async
    {
        // self.imagenes = []
        self.refImagenesUsuario = []
        
        
        // await getAllStorage()
        // sleep(2)
        //self.semph.wait()
        await getData(correoUsuario: correoUsuario)
    }
    
    
    
    @available(iOS 15.0.0, *)
    func getData(correoUsuario: String) async {
        let db = Firestore.firestore()
        
        db.collection("Files").getDocuments() { [self] (querySnapshot, err) in
            print("EMPEZANDO GETDATA");
            
            var storageRef: StorageReference
            storageRef = self.storage.reference()
            var ref: StorageReference
            
            
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if  (document.data()["email"] as! String) == correoUsuario {
                        ref = storageRef.child("images/\(document.data()["date"] ?? "none")")
                        
                        print("REF: \(ref)")
                        
                        ref.getData(maxSize: 10048576) { (data, error) in
                            guard let imageData = data, error == nil else {
                                return
                            }
                            
                            let userImage = UserImage(
                                name: document.data()["name"] as! String ,
                                date: document.data()["date"] as! String ,
                                email: document.data()["email"] as! String ,
                                data: imageData
                            );
                            
                            print( "IMAGE: \(userImage)")
                            
                            self.refImagenesUsuario.append(userImage)
                        }
                    }
                }
            }            
        }
    }
      
    
    /*@available(iOS 15.0.0, *)
     func getAllStorage() async {
     let storageRef = storage.reference().child("images")
     
     storageRef.listAll { (result, error) in
     
     print("EMPEZANDO GETALLSOTRAGE");
     
     if let error = error {
     print("Error while listing all files: ", error)
     }
     
     for item in result.items {
     self.imagenes.append(Image(item.fullPath))
     }
     
     print("TERMINANDO GETALLSOTRAGE");
     // self.myGroup.leave()
     
     // self.semph.signal()
     }
     
     
     print("DEVOLVIENDO GETALLSOTRAGE");
     
     }*/
    
    @available(iOS 15.0.0, *)
    func uploadData(image: UIImage, correoUsuario: String, nombre: String, fecha: String)  {
        let db = Firestore.firestore()
        
        print("ANTES DEL DB COLLECTION")
                
        db.collection("Files").document("\(fecha)").setData([
            
            "email": correoUsuario,
            "name": nombre,
            "date": "\(fecha)"
        ]) { err in
            if let err = err {
                print(err.localizedDescription)
            } else {
                print("Todo hecho bien")

                    Task {
                        print("Se está haciendo esto")
                        await self.getUserData(correoUsuario: "martafernandez16garcia@gmail.com")
                    }
            }
        }
        
        
        print("DESPUES DEL DB COLLECTION")
    }
    
    @available(iOS 15.0.0, *)

    func uploadStorage(image: UIImage, correoUsuario: String, nombre: String) {
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let fecha = formater.string(from: Date())

        let data = image.jpegData(compressionQuality: 0.2)
        let metadata = StorageMetadata()
        let storageRef = storage.reference().child("images/\(fecha)")
        
        metadata.contentType = "image/jpg"

        
        if let data = data {
            print("Empezando uploadstorage")
            let uploadTask = storageRef.putData(data, metadata: metadata)
            
            
            let observer = uploadTask.observe(.success) { snapshot in
                print("OTROOOO")

                self.uploadData(image: image, correoUsuario: correoUsuario, nombre: nombre, fecha: fecha)
                
                print("OTROOOO2222")

            }
            
            
            /*{ (metadata, error) in
                if let error = error {
                    print("Error while uploading file: ", error)
                }
                
                if let metadata = metadata {
                    print("Metadata: ", metadata)
                }
            }*/
        }
        
        

    }
    
    func deleteData(indexSet: IndexSet, correoUsuario: String) {
        let db = Firestore.firestore()
        var storageRef: StorageReference
        storageRef = self.storage.reference()
        
        indexSet.forEach { index in
            let userImage = self.refImagenesUsuario[index]
            db.collection("Files").document(userImage.date).delete { error in
                self.deleteItemStorage(item: storageRef.child("images/\(userImage.date)" ))
                
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    func deleteItemStorage(item: StorageReference) {
        item.delete { error in
            if let error = error {
                print("Error deleting item", error)
            }
        }
    }
    
    
    
    func listen () {
        // monitor authentication changes using firebase
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                // if we have a user, create a new user model
                self.session = User(
                    uid: user.uid,
                    displayName: user.displayName,
                    email: user.email
                )
            } else {
                // if we don't have a user, set our session to nil
                self.session = nil
            }
        }
    }
    
    func signUp(
        email: String,
        password: String,
        handler: @escaping AuthDataResultCallback
    ) {
        Auth.auth().createUser(withEmail: email, password: password, completion: handler)
    }
    
    func signIn(
        email: String,
        password: String,
        handler: @escaping AuthDataResultCallback
    ) {
        Auth.auth().signIn(withEmail: email, password: password, completion: handler)
    }
    
    func signOut () -> Bool {
        do {
            try Auth.auth().signOut()
            self.session = nil
            return true
        } catch {
            return false
        }
    }
    
    func unbind () {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
}
