//
//  ITuneData.swift
//  BootCamp
//
//  Created by esb23904 on 2023/10/13.
//

import Foundation

enum MediaType:Int,CaseIterable {
    case 電影 = 0
    case 音樂 = 1
    func getType()->String { // 提供給api使用
        switch ( self ) {
        case .電影 :
            return "movie"
        case .音樂 :
            return "music"
        }
    }
    
    func getChineseString()->String {
        switch( self ) {
        case .電影 :
            return "電影"
        case .音樂 :
            return "音樂"
        }
    }
}

struct ITuneResult:Codable {
    var resultCount:Int
    var results:[ITuneDataDetail]
}

struct ITuneDataDetail:Hashable {
    var trackId:Int
    var trackName:String // 電影
    var artistName:String // 作者
    var collectionName:String //
    var trackTimeMillis:Double // 長度
    var trackViewUrl:String // url 連結
    var artworkUrl100:String // 圖片連結
    var longDescription:String? // 描述
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case trackId = "trackId"
        case trackName = "trackName"
        case artistName = "artistName"
        case collectionName = "collectionName"
        case trackTimeMillis = "trackTimeMillis"
        case trackViewUrl = "trackViewUrl"
        case artworkUrl100 = "artworkUrl100"
        case longDescription = "longDescription"
    }
    
    
    static func == (lhs: ITuneDataDetail, rhs: ITuneDataDetail) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(trackId)
        hasher.combine(trackName)
    }
}

extension ITuneDataDetail:Codable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        // 至少要有trackId
        guard let decode_trackId = try values.decodeIfPresent(Int.self, forKey: .trackId)
        else {
            throw DecodingError.dataCorruptedError(forKey: .trackId, in: values, debugDescription: "trackId error")
        }
        
        trackId = decode_trackId
        trackName = try values.decodeIfPresent(String.self, forKey: .trackName) ?? ""
        artistName = try values.decodeIfPresent(String.self, forKey: .artistName) ?? ""
        collectionName = try values.decodeIfPresent(String.self, forKey: .collectionName) ?? ""
        trackTimeMillis = try values.decodeIfPresent(Double.self, forKey: .trackTimeMillis) ?? 0
        
        trackViewUrl = try values.decodeIfPresent(String.self, forKey: .trackViewUrl) ?? ""
        artworkUrl100 = try values.decodeIfPresent(String.self, forKey: .artworkUrl100) ?? ""
        longDescription = try values.decodeIfPresent(String.self, forKey: .longDescription)
    }
}

struct SearchITuneCondition {
    var term:String
    //var country:String?
    var media:MediaType = .音樂
    func getUrl(offset:Int? = nil, limit:Int? = nil)->String {
        var url = "https://itunes.apple.com/search?"
        url += "term=\(term)"
        url += "&media=\(media.getType())"
//        if let country = country {
//            url += "&country=\(country)"
//        }
        
        if let offset = offset {
            url += "&offset=\(offset)"
        }
        
        if let limit = limit {
            url += "&limit=\(limit)"
        }
        
        return url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
}
