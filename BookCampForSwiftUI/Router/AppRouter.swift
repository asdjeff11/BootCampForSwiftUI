//
//  AppRouter.swift
//  BookCampForSwiftUI
//
//  Created by 楊宜濱 on 2025/5/3.
//
import SwiftUI

enum NavigationDestination: Hashable {
    case collectView
}

class AppRouter {
    @ViewBuilder
    func view(for destination: AnyHashable, userData: UserData) -> some View { // 接收 UserData
        // 使用 if let 或 switch 判斷 destination 的類型
        if let dest = destination as? NavigationDestination { // 假設你有 NavigationDestination enum
             switch dest {
             case .collectView:
                 CollectView().environmentObject(userData) // 注入 UserData
             // ... 其他 case
             }
        } else {
             Text("未知導航目標")
        }
    }
}
