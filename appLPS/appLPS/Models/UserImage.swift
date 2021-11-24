//
//  UserImage.swift
//  appLPS
//
//  Created by Marta Fernandez Garcia on 24/11/21.
//

import Foundation


struct UserImage: Hashable {
    var name: String
    var date: String
    var email: String
    var data: Data

    init(name: String, date: String, email: String, data: Data) {
        self.name = name
        self.date = date
        self.email = email
        self.data = data
    }

}
