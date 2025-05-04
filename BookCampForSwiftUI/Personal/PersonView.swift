//
//  PersonView.swift
//  BookCampForSwiftUI
//
//  Created by 楊宜濱 on 2025/5/3.
//

import SwiftUI

struct PersonView: View {
    @EnvironmentObject var userData: UserData
    @State private var showingLanguageSheet = false
    @EnvironmentObject var navigationManager: NavigationManager
    var body: some View {
        VStack(spacing: 20) {
            
            PersonalCellView(item: PersonlModel(title: "語言".localized, text: userData.getUserLanguage_display()))
                .contentShape(Rectangle()) // 讓整行可點擊
                .onTapGesture {
                    showingLanguageSheet = true
                }
            
            PersonalCellView(item: PersonlModel(title: "收藏".localized, text:String(format:  "共有 %@ 項收藏".localized, userData.getTotalCount())))
                .onTapGesture {
                    navigationManager.navigate(to: NavigationDestination.collectView)
                }
            HStack {
                Spacer()
                Button {
                    if let url = URL(string: "https://www.apple.com/tw/itunes/") {
                        UIApplication.shared.open(url)
                    }
                } label : {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                        Text("關於Apple iTunes".localized)
                            .font(.system(size: 15))
                    }.tint(.black)
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
            }
            Spacer()
        }
        .padding(.vertical, 30)
        .sheet(isPresented: $showingLanguageSheet) {
            LanguageSelectionView(selectedLanguage: userData.getUserLanguage())
             .environmentObject(userData)
             .presentationDetents([.height(300)])
        }
    }
}

#Preview {
    PersonView()
}
