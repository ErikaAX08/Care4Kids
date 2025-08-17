//
//  HomeView.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if let user = authViewModel.currentUser {
                switch user.userType {
                case .parent:
                    ParentHomeView()
                case .child:
                    ChildHomeView()
                }
            } else {
                LoadingView(message: "Cargando perfil...")
            }
        }
    }
}
