import Foundation
import SQLite3

actor MyDataBaseActor {
    private var db: OpaquePointer
    private var path: String = "myDataBase.sqlite"

    static let shared = MyDataBaseActor()

    private init() {
        do {
            let mypath = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!
            var db: OpaquePointer? = nil
            let dbPath = "\(mypath)/\(path)"
            let dbStatus = sqlite3_open(dbPath, &db)

            guard dbStatus == SQLITE_OK, let database = db else {
                let errorMsg = db.map { String(cString: sqlite3_errmsg($0)) } ?? "未知 SQLite 錯誤"
                sqlite3_close(db)
                throw SQLiteError.OpenDatabase(message: "Can not open DB at \(dbPath). Error: \(errorMsg)")
            }
            self.db = database
        } catch {
            fatalError("數據庫初始化失敗: \(error)")
        }
    }

    func executeQuery(query: String) throws {
        var statement: OpaquePointer?
        defer { sqlite3_finalize(statement) }

        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(db))
                print("執行查詢失敗: \(errorMsg) (Query: \(query))")
                throw SQLiteError.ExecuteQuery(message: "Execute failed: \(errorMsg)")
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(db))
            print("準備查詢失敗: \(errorMsg) (Query: \(query))")
            throw SQLiteError.PrepareStatement(message: "Perpare failed: \(errorMsg)")
        }
    }

    func update(object: MyDataBaseStructer) throws {
        let query = object.getUpdateQuery()
        try executeQuery(query: query)
    }

    func read2Object<T: Codable>(query: String) throws -> [T] {
        let jsonString = try sqliteToJsonString(query: query)
        guard !jsonString.isEmpty, let data = jsonString.data(using: .utf8) else {
            return []
        }

        let decoder = JSONDecoder()
        do {
            if jsonString.hasPrefix("[") {
                return try decoder.decode([T].self, from: data)
            } else if !jsonString.isEmpty {
                 let item = try decoder.decode(T.self, from: data)
                 return [item]
            } else {
                 return []
            }
        } catch {
            print("JSON 解碼錯誤: \(error.localizedDescription) for JSON: \(jsonString)")
            throw SQLiteError.JSONDecoding(message: error.localizedDescription)
        }
    }

    private func sqliteToJsonString(query: String) throws -> String {
        var statement: OpaquePointer?
        defer { sqlite3_finalize(statement) }

        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) != SQLITE_OK {
             let errorMsg = String(cString: sqlite3_errmsg(db))
             throw SQLiteError.PrepareStatement(message: "Perpare failed: \(errorMsg)")
        }

        var jsonArray: [[String: Any]] = []

        while sqlite3_step(statement) == SQLITE_ROW {
            var rowDict: [String: Any] = [:]
            let col_count = sqlite3_column_count(statement)
            for i in 0..<col_count {
                if let namePtr = sqlite3_column_name(statement, i) {
                     let name = String(cString: namePtr)
                     let type = sqlite3_column_type(statement, i)
                     switch type {
                     case SQLITE_TEXT:
                         if let textPtr = sqlite3_column_text(statement, i) {
                              rowDict[name] = String(cString: textPtr)
                         }
                     case SQLITE_INTEGER:
                         rowDict[name] = sqlite3_column_int64(statement, i)
                     case SQLITE_FLOAT:
                         rowDict[name] = sqlite3_column_double(statement, i)
                     case SQLITE_NULL:
                          rowDict[name] = NSNull()
                     default:
                         print("未處理的 SQLite 類型 \(type) for column \(name)")
                         continue
                     }
                } else {
                     print("無法獲取列名 at index \(i)")
                }

            }
             if !rowDict.isEmpty {
                 jsonArray.append(rowDict)
             }
        }

        guard !jsonArray.isEmpty else { return "" }

        do {
             let jsonData: Data
             if jsonArray.count == 1 {
                  jsonData = try JSONSerialization.data(withJSONObject: jsonArray[0], options: [])
             } else {
                  jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
             }
             return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
             print("JSON 序列化錯誤: \(error)")
             throw SQLiteError.JSONSerialization(message: error.localizedDescription)
        }
    }

     enum SQLiteError: Error, LocalizedError {
         case OpenDatabase(message: String)
         case PrepareStatement(message: String)
         case ExecuteQuery(message: String)
         case JSONSerialization(message: String)
         case JSONDecoding(message: String)

         var errorDescription: String? {
             switch self {
             case .OpenDatabase(let message): return "打開數據庫失敗: \(message)"
             case .PrepareStatement(let message): return "準備 SQL 語句失敗: \(message)"
             case .ExecuteQuery(let message): return "執行 SQL 語句失敗: \(message)"
             case .JSONSerialization(let message): return "JSON 序列化失敗: \(message)"
             case .JSONDecoding(let message): return "JSON 解碼失敗: \(message)"
             }
         }
     }
}
