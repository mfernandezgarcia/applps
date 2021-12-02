//
//  User.swift
//  appLPS
//
//  Created by Marta Fernandez Garcia on 9/11/21.
//

import Foundation


struct User {
    var uid: String
    var email: String?

    init(uid: String, email: String?) {
        self.uid = uid
        self.email = email
    }

}
