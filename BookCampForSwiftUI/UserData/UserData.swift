//
//  UserData.swift
//  BootCamp
//
//  Created by esb23904 on 2023/10/16.
//

import Foundation
import UIKit
class UserData {
    private var collectDatas:[Int:[Int:MyITuneData]] = [:] // 類別 => [trackId => Data]
    private let userDefault = UserDefaults()
    private var themeType:Theme.ThemeStyle = .LightTheme
    
    init() {
        if let themeStyle = userDefault.value(forKey: "ThemeStyle") as? String ,
           let type = Theme.ThemeStyle(rawValue: themeStyle) {
            themeType = type
        }
        for type in MediaType.allCases {
            collectDatas[type.rawValue] = [:]
        }
        
        getDbData()
    }
    
    private func getDbData() {
        let query = "Select * from `CollectITuneData` ;"
        let ITuneDatas:[MyITuneData] = db.read2Object(query: query)
        for data in ITuneDatas {
            collectDatas[data.type]?[data.trackId] = data
        }
    }
}

// 主題色
extension UserData {
    func getSecondColor()->UIColor {
        themeType.getSecondColor()
    }
    
    func getMainColor()->UIColor {
        themeType.getMainColor()
    }
    
    func getThemeType()->Theme.ThemeStyle {
        themeType
    }
    
    func updateThemeType(type:Theme.ThemeStyle) {
        userDefault.set(type.rawValue, forKey: "ThemeStyle")
        themeType = type
    }
}

// 新增 刪除 追蹤
extension UserData {
    func saveData(data:MyITuneData) {
        db.executeQuery(query: data.getUpdateQuery())
        self.collectDatas[data.type]?[data.trackId] = data
    }
    
    func removeData(type:MediaType,trackId:Int) {
        let query = """
        DELETE FROM `\(MyITuneData.tableName)` WHERE `trackId` = \(trackId) and `type` = \(type.rawValue);
        """
        db.executeQuery(query: query)
        
        collectDatas[type.rawValue]?.removeValue(forKey: trackId)
    }
}


// 取得追蹤
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
        
        count += 1000   // 為了展示收藏數量千分位 而使用 , 真實數量扣除掉此行
        
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
