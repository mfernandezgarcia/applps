//
//  Prueba.swift
//  appLPS
//
//  Created by Marta Fernandez Garcia on 31/10/21.
//

import FirebaseAuth
import FirebaseDatabase
import Firebase
import FirebaseStorage

class FirebaseController: ObservableObject {
    let storage = Storage.storage()
    @Published var refImagenesUsuario: [UserImage] = []
    @Published var loading = false
    @Published var empty = true
    
    var session: User?
    var handle: AuthStateDidChangeListenerHandle?

    @available(iOS 15.0.0, *)
    func getUserData(correoUsuario: String) async
    {
        self.loading = true
        self.empty = true
        let db = Firestore.firestore()
        self.refImagenesUsuario = []
        
        db.collection("Files").getDocuments() { [self] (querySnapshot, err) in
            var storageRef: StorageReference
            storageRef = self.storage.reference()
            var ref: StorageReference
            
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if  (document.data()["email"] as! String) == correoUsuario {
                        self.empty = false
                        ref = storageRef.child("images/\(document.data()["date"] ?? "none")")
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
                            
                            self.refImagenesUsuario.append(userImage)
                            self.loading = false
                        }
                    }
                }
            }
            self.loading = false
        }
    }
    
    
    @available(iOS 15.0.0, *)
    func uploadData(image: UIImage, correoUsuario: String, nombre: String, fecha: String)  {
        self.loading = true
        let db = Firestore.firestore()
                        
        db.collection("Files").document("\(fecha)").setData([
            "email": correoUsuario,
            "name": nombre,
            "date": "\(fecha)"
        ]) { err in
            if let err = err {
                self.loading = false
                print(err.localizedDescription)
            } else {
                self.loading = false
                    Task {
                        await self.getUserData(correoUsuario: correoUsuario)
                    }
            }
        }
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
            let uploadTask = storageRef.putData(data, metadata: metadata)
            
            _ = uploadTask.observe(.success) { snapshot in
                self.uploadData(image: image, correoUsuario: correoUsuario, nombre: nombre, fecha: fecha)
            }
        }
    }
    
    @available(iOS 15.0.0, * )
    func updateData(image: UserImage, correoUsuario: String, nuevoNombre: String){
        let db = Firestore.firestore()
                
        db.collection("Files").document("\(image.date)").setData([
            "email": correoUsuario,
            "name": nuevoNombre,
            "date": image.date
        ])
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
    
    func resetPassword(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
          print("\(error)")
        }
    }
    
    func signOut () {
        do {
            try Auth.auth().signOut()
            self.session = nil
        } catch { }
    }
    
    func unbind () {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
}
