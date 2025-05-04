//
//  LanguageSelectionView.swift
//  BookCampForSwiftUI
//
//  Created by 楊宜濱 on 2025/5/3.
//
import SwiftUI
struct LanguageSelectionView: View {
    @EnvironmentObject var userData: UserData
    
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedLanguageInSheet:UserData.Language
    init( selectedLanguage: UserData.Language) {
        self.selectedLanguageInSheet = selectedLanguage
    }
    
    var body: some View {
        VStack(spacing: 0) { // 使用 VStack 佈局
            HStack {
                Button("取消".localized) { // 取消按鈕
                    dismiss()
                }
                Spacer()
                Text("選擇語言".localized) // 標題
                    .font(.headline)
                Spacer()
                Button("完成".localized) { // 完成按鈕
                    userData.selectedLanguage = selectedLanguageInSheet 
                    dismiss()
                }
            }
            .padding()
            .background(.thinMaterial)

            Divider()

            Picker("選擇語言".localized, selection: $selectedLanguageInSheet) {
                ForEach(UserData.Language.allCases) { lang in
                    Text(lang.displayName).tag(lang)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .padding()
        }
    }
}
