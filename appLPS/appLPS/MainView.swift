//
//  MainView.swift
//  appLPS
//
//  Created by Marta Fernandez Garcia on 9/11/21.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var session: FirebaseController

    var body: some View {     
        
        Group {
          if (session.session != nil) {
            Text("Hello user!")
          } else {
            LoginView()
          }
        }.onAppear(perform: getUser)
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
