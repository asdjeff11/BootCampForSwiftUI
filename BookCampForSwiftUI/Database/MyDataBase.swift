//
//  MyDataBase.swift
//  BootCamp
//
//  Created by esb23904 on 2023/10/16.
//

import Foundation
import SQLite3
class MyDataBase {
    private var db : OpaquePointer? // database
    private var path:String = "myDataBase.sqlite" // 檔案名稱
    private var semphore = DispatchSemaphore(value: 1)
    
    init() {
        self.db = createDB() // 資料庫連接
        //dropTable(tableName: MyITuneData.tableName)
        // 建立 table
        executeQuery(query: MyITuneData.createTable())
    }
    
    func createDB()-> OpaquePointer? { // 建立 database
        // 若該路徑 沒有該檔案 系統會嘗試建立此檔案
        // 若該路徑 已經有檔案 單純連接database
        let mypath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first! // 取得儲存路徑
        var db: OpaquePointer? = nil // 資料庫
        let dbStatus = sqlite3_open("\(mypath)/\(path)", &db) // 連接資料庫
        
        //print("\(mypath)/\(path)")
        if ( dbStatus != SQLITE_OK) { // 連接失敗
            print("error to create Database. Error Code:\(dbStatus)")
            return nil
        }
        else { // 連接成功
            //print("creating Database with path \(path)")
            return db
        }
    }
    
    func dropTable(tableName:String) { // 移除table
        var statement:OpaquePointer?
        let query = "DROP TABLE \(tableName);" as NSString
        defer {
            semphore.signal()
        }
        semphore.wait()
        if ( sqlite3_prepare_v2(self.db, query.utf8String, -1, &statement, nil) == SQLITE_OK ) {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Data delete Success!")
            }
            else {
                print("Data is not deleted in table!")
            }
            sqlite3_finalize(statement)
        }
        else {
            print("Query is not as per requirement")
        }
    } // 移除table
}

// 計算 query 指令
extension MyDataBase {
    func executeQuery(query:String) {
        var statement:OpaquePointer?
        let q = query as NSString
        let com = String(query.prefix(query.positionOf(sub: " ")))
        
        if ( sqlite3_prepare_v2(self.db, q.utf8String, -1, &statement, nil) == SQLITE_OK ) { // 傳遞創建刪除 的command 給 database
            if sqlite3_step(statement) == SQLITE_DONE {  // 完成
                //print("\(com) Success!")
            }
            else {
                print( "\(com) is not Success! query:\(q)")
            }
            sqlite3_finalize(statement)
        }
        else {  // 傳遞command 失敗
            print( "Query is not as per requirement! query:\(q)")
        }
    }
    
    func update(object:MyDataBaseStructer) {
        let query = object.getUpdateQuery()
        executeQuery(query: query)
    }
}

// 讀取資訊
extension MyDataBase {
    func read2Object<T:Codable>(query:String) -> [T] { // 下query 去取得物件資訊
        defer {
            semphore.signal()
        }
        semphore.wait()
        
        let jsonString = sqliteToJsonString(query:query)
        guard !jsonString.isEmpty ,
              let data = jsonString.data(using: .utf8)
        else { return [] }
        
        let decoder = JSONDecoder()
        do {
            var arr:[T] = []
            if ( jsonString.hasPrefix("[") ) {
                arr = try decoder.decode([T].self, from: data)
            }
            else {
                let item = try decoder.decode(T.self, from: data)
                arr = [item]
            }
            return arr
        }
        catch {
            print(error.localizedDescription)
        }
        return []
    }
    
    private func sqliteToJsonString(query:String) ->String { // sqlite data => jsonString
        var statement:OpaquePointer?
        var jsonString = ""
        if ( sqlite3_prepare_v2(self.db, query, -1, &statement,nil) == SQLITE_OK ) {
            var count = 0
            while sqlite3_step(statement) == SQLITE_ROW { // 資料筆數
                jsonString = "\(jsonString){"
                let col_count = sqlite3_column_count(statement)
                for i in 0..<col_count { // 資料內容
                    let name = String(describing: String(cString:sqlite3_column_origin_name(statement, i)))
                    var data = ""
                    let type = sqlite3_column_type(statement, i)
                    switch (type) {
                    case SQLITE_TEXT :
                        data = "\"\(String(describing: String(cString: sqlite3_column_text(statement, i))))\""
                    case SQLITE_INTEGER :
                        data = String(describing: sqlite3_column_int(statement, i))
                    case SQLITE_FLOAT :
                        data = String(describing: sqlite3_column_double(statement, i))
                    default : // 類別有誤 直接跳過該類別
                        continue
                    }
                    
                    jsonString += "\"\(name)\":\(data),"
                }
                
                jsonString = String(jsonString.dropLast()) + "}," // 去掉最後的 ,
                count += 1
            }
            
            if ( count > 1 ) { // 筆數 > 1 加 [] 表示陣列
                jsonString = "[" + String(jsonString.dropLast()) + "]"
            }
            else {
                jsonString = String(jsonString.dropLast())
            }
        }
        return jsonString
    }
}
