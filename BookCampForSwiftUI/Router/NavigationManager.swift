//
//  NavigationManager.swift
//  BookCampForSwiftUI
//
//  Created by 楊宜濱 on 2025/5/3.
//
import SwiftUI

@MainActor
class NavigationManager: ObservableObject {
    static let shared = NavigationManager()
    @Published var path = NavigationPath()

    private init() {}

    func navigate(to destination: any Hashable) {
        path.append(destination)
    }
    func goBack() {
         if !path.isEmpty { path.removeLast() }
    }
    func goToHome() {
         path = NavigationPath()
    }
}
