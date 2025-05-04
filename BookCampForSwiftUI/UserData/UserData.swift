//
//  UserData.swift
//  BootCamp
//
//  Created by esb23904 on 2023/10/16.
//

import Foundation

@MainActor
class UserData:ObservableObject {
    static let shared = UserData()
    
    enum Language:String, CaseIterable, Identifiable {
        case english = "en"
        case chinese = "zh-Hant"
        var id: String { self.rawValue }
        var displayName: String {
            switch self {
            case .english: return "English"
            case .chinese: return "繁體中文"
            }
        }
    }
    
    
    @Published private var collectDatas:[Int:[Int:MyITuneData]] = [:] // 類別 => [trackId => Data]
    @Published private var language:Language = .chinese {
        didSet {
            if oldValue != language {
                UserDefaults.standard.set(language.rawValue, forKey: LANGUAGEUSERKEY)
            }
        }
    }
    private var localizedStrings: [String: String] = [:]
    
    var selectedLanguage: Language {
        get { language }
        set { setUserLanguage(language: newValue) }
    }
    
    private let dbActor = MyDataBaseActor.shared
    
    private init() {
        let savedLanguageCode = UserDefaults.standard.string(forKey: LANGUAGEUSERKEY)
        let initialLanguage = Language(rawValue: savedLanguageCode ?? "") ?? .chinese
        _language = Published(initialValue: initialLanguage)
        
        for type in MediaType.allCases {
            collectDatas[type.rawValue] = [:]
        }
        Task {
            do {
                try await self.dbActor.executeQuery(query: MyITuneData.createTable())
                await self.getDbData()
            } catch {
                print("DB get data error!")
            }
        }
    }
    
    private func getDbData() async {
        let query = "Select * from `CollectITuneData` ;"
        do {
            let ITuneDatas: [MyITuneData] = try await dbActor.read2Object(query: query)
            for data in ITuneDatas {
                collectDatas[data.type]?[data.trackId] = data
            }
        } catch {
            print("GetDbData failed - \(error)")
        }
    }
}

extension UserData {
    func saveData(data:MyITuneData) async throws {
        try await dbActor.executeQuery(query: data.getUpdateQuery())
        self.collectDatas[data.type]?[data.trackId] = data
    }
    
    func removeData(type:MediaType,trackId:Int) async throws {
        let query = """
        DELETE FROM `\(MyITuneData.tableName)` WHERE `trackId` = \(trackId) and `type` = \(type.rawValue);
        """
        
        try await dbActor.executeQuery(query: query)
        collectDatas[type.rawValue]?.removeValue(forKey: trackId)
    }
}


extension UserData {
    func getCollectMedia(type:MediaType)->[MyITuneData] {
        guard let datas = collectDatas[type.rawValue]?.values else { return [] }
        return Array(datas)
    }
   
    func isCollect(type:MediaType, trackId:Int) -> Bool {
        if let datas = collectDatas[type.rawValue],
           datas[trackId] != nil {
            return true
        }
        else {
            return false
        }
    }
    
    func getTotalCount()->String {
        var count = 0
        for datas in collectDatas.values {
            count += datas.values.count
        }
        
        //count += 1000   // 為了展示收藏數量千分位 而使用 , 真實數量扣除掉此行
        
        if #available(iOS 15.0, *) {
            return count.formatted()
        }
        else {
            let formate = NumberFormatter()
            formate.maximumFractionDigits = 0
            formate.numberStyle = .decimal
            return formate.string(from: NSNumber(value:count)) ?? "\(count)"
        }
        
    }
}

extension UserData {
    func setUserLanguage( language: Language ) {
        if self.language != language {
            self.language = language
        }
    }
    
    func getUserLanguage_display()-> String {
        language.displayName
    }
    
    func getUserLanguage()-> Language {
        language
    }
}
