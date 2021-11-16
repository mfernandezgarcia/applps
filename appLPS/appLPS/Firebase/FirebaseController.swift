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


class FirebaseController: ObservableObject {
    
    let storage = Storage.storage()
    @Published var imagenes: [Image] = []
    @Published var refImagenesUsuario: [Data] = []
    @Published var loading = false //TODO
    
    
    var didChange = PassthroughSubject<FirebaseController, Never>()
    var session: User? { didSet { self.didChange.send(self) }}
    var handle: AuthStateDidChangeListenerHandle?
    
    
    @available(iOS 15.0.0, *)
    func getUserData(correoUsuario: String) async {
        
        print("GETUSERDATA")
        self.imagenes = []
        self.refImagenesUsuario = []
        await getAllStorage()
        await getData(correoUsuario: correoUsuario)
    }
    
  
    
    @available(iOS 15.0.0, *)
    func getData(correoUsuario: String) async  {
        let db = Firestore.firestore()

        db.collection("Files").getDocuments() { (querySnapshot, err) in
            var storageRef: StorageReference
            storageRef = self.storage.reference()
            var ref: StorageReference
            
            
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    if  (document.data()["email"] as! String) == correoUsuario {
                        print("Foto del usuario \(document.documentID)")
                        ref = storageRef.child("images/\(document.data()["name"] ?? "HOLA")")
                        ref.getData(maxSize: 1048576) { (data, error) in
                            guard let imageData = data, error == nil else {
                                   return
                               }
                            self.refImagenesUsuario.append(imageData)

                        }
                    }
                }
            }
        }
    }
    
    
    
    @available(iOS 15.0.0, *)
    func getAllStorage() async {
        let storageRef = storage.reference().child("images")
        
        storageRef.listAll { (result, error) in
            print("Por aqui ... ")
            if let error = error {
                print("Error while listing all files: ", error)
            }
            
            for item in result.items {
                print("Item in images folder: ", item)
                self.imagenes.append(Image(item.fullPath))
            }
        }
    }
    
    @available(iOS 15.0.0, *)
    func uploadStorage(image: UIImage, correoUsuario: String) async throws{
        print("SUBIENDO FOOTO")

        let nombreImagen = NSDate()
        // https://designcode.io/swiftui-advanced-handbook-firebase-storage
        let storageRef = storage.reference().child("images/\(nombreImagen)")
        
        /*let resizedImage = image.aspectFittedToHeight(200)*/
        let data = image.jpegData(compressionQuality: 0.2)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        if let data = data {
            storageRef.putData(data, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print("Error while uploading file: ", error)
                }
                
                if let metadata = metadata {
                    print("Metadata: ", metadata)
                }
            }
        }
        
        let db = Firestore.firestore()

        try await db.collection("Files").document("\(nombreImagen)").setData([
            "email": correoUsuario,
            "name": "\(nombreImagen)"
        ])
        
        print("FOTO SUBIDA")

        
        await getUserData(correoUsuario: correoUsuario)
        
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
                print("Got user: \(user)")
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
