//
//  Localized.swift
//  BookCampForSwiftUI
//
//  Created by 楊宜濱 on 2025/5/3.
//
import Foundation

let LANGUAGEUSERKEY = "AppSelectedLanguage"

extension String {
    /// 返回此字串作為 Key 對應的、根據 UserData 中設置的語言的本地化版本。
    var localized: String {
        let defaultLanguageCode = UserData.Language.chinese.rawValue
        let currentLanguageCode = UserDefaults.standard.string(forKey: LANGUAGEUSERKEY) ?? defaultLanguageCode

        var bundlePath: String?
        bundlePath = Bundle.main.path(forResource: currentLanguageCode, ofType: "lproj")
        if let path = bundlePath, let languageBundle = Bundle(path: path) {
            return languageBundle.localizedString(forKey: self, value: nil, table: nil)
        } else {
            print("警告：找不到語言包 \(currentLanguageCode).lproj。將嘗試回退。")
            let baseLanguageCode = UserData.Language.chinese.rawValue
            if let basePath = Bundle.main.path(forResource: baseLanguageCode, ofType: "lproj"),
               let baseBundle = Bundle(path: basePath) {
                print("回退到基礎語言: \(baseLanguageCode)")
                return baseBundle.localizedString(forKey: self, value: nil, table: nil)
            } else {
                // 連基礎語言都找不到，這是個問題，返回 Key 本身或標記
                print("錯誤：無法加載基礎語言 (\(baseLanguageCode)) 的 Bundle。返回 Key。")
                return "~\(self)~" // 返回帶標記的 Key，方便調試
            }
        }
    }
    
    func localized(with arguments: CVarArg...) -> String {
        let localizedFormat = self.localized // 獲取基礎格式字串 ("共有 %@ 項收藏")
        return String(format: localizedFormat, arguments: arguments) // 填入參數
    }
}
