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

class FirebaseController: ObservableObject {
    
    let storage = Storage.storage()
    var imagenes: [Image] = []
    
    func getData(correoUsuario: String)  -> [Image] {
        let db = Firestore.firestore()
        
        db.collection("Files").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    /*if  (document.data()["name"] as! String) == correoUsuario {
                     
                     }*/
                }
            }
        }
        
        
        self.imagenes =  self.getAllStorage()
        
        print(" ------ AQUI")
        print(self.imagenes)
        print("AQUI ----- ")
        
        return self.imagenes
    }
    
    func getAllStorage() -> [Image] {
        let storageRef = storage.reference().child("images")
        
        
        
        
        /// async
        storageRef.listAll { (result, error) in
            if let error = error {
                print("Error while listing all files: ", error)
            }
            
            for item in result.items {
                print("Item in images folder: ", item)
                print("METIENDOLO EN LA LISTA ----- ")
                self.imagenes.append(Image(item.fullPath))
                print("EIRHEIRHEREIROER----- ")
                print( self.imagenes)
                
            }
        }
    
    
    
    print("DEVOLVIENDO EL RESULTADO DESDE GETALLSOTRAGE----- ")
    print( self.imagenes)
    
    return self.imagenes
}

func uploadStorage(image: UIImage) {
    // https://designcode.io/swiftui-advanced-handbook-firebase-storage
    let storageRef = storage.reference().child("images/\(NSDate())")
    
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
}

func deleteItemStorage(item: StorageReference) {
    item.delete { error in
        if let error = error {
            print("Error deleting item", error)
        }
    }
}


var didChange = PassthroughSubject<FirebaseController, Never>()
var session: User? { didSet { self.didChange.send(self) }}
var handle: AuthStateDidChangeListenerHandle?

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
