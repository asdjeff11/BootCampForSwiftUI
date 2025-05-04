//
//  MainView.swift
//  BookCampForSwiftUI
//
//  Created by 楊宜濱 on 2025/5/3.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var navigationManager: NavigationManager
    let appRouter: AppRouter
    
    @State private var selectedTab: Int = 0
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            TabView(selection: $selectedTab) {
                SearchView()
                .tabItem {
                    Label("搜尋".localized, systemImage: "magnifyingglass")
                }.tag(0)
                
                PersonView()
                .tabItem {
                    Label("個人資料".localized, systemImage: "person")
                }.tag(1)
            }
            .navigationTitle("Bookcamp".localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: NavigationDestination.self) { destination in
                appRouter.view(for: destination, userData: userData)
            }
//                .toolbar {
//                    ToolbarItem(placement: .topBarTrailing) {
//                        Button("Edit") {
//                            // action
//                        }
//                    }
//                }
        }
        .onAppear() {
            let apperance = UINavigationBarAppearance()
            apperance.configureWithOpaqueBackground()
            apperance.backgroundColor = Theme.navigationBarBG
            apperance.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 24, weight: .semibold),
                .foregroundColor: UIColor.white
            ]
            UINavigationBar.appearance().standardAppearance = apperance
            UINavigationBar.appearance().scrollEdgeAppearance = apperance
            // tabBar
            let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithOpaqueBackground()
                tabBarAppearance.backgroundColor = UIColor.systemGray6
                
                tabBarAppearance.shadowColor = UIColor.gray
                
            
            UITabBar.appearance().standardAppearance = tabBarAppearance
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
       
    }
    
}

#Preview {
    MainView(appRouter: AppRouter())
}
