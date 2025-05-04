//
//  BookCampForSwiftUIApp.swift
//  BookCampForSwiftUI
//
//  Created by 楊宜濱 on 2025/5/3.
//

import SwiftUI

@main
struct BookCampForSwiftUIApp: App {
    @StateObject private var userData = UserData.shared
    @StateObject private var navigationManager = NavigationManager.shared
    private let appRouter = AppRouter()
    var body: some Scene {
        WindowGroup {
            MainView(appRouter: appRouter).environmentObject(userData)
                .environmentObject(navigationManager)
        }
    }
}
