//
//  SearchModel.swift
//  BookCampForSwiftUI
//
//  Created by 楊宜濱 on 2025/5/3.
//

import Foundation

struct ITuneDataSection: Identifiable, Hashable {
    let id = UUID()
    var isFolder:Bool
    let type: MediaType
    let title: String
    var items: [MyITuneData]
    
    init(type: MediaType, title: String, items: [MyITuneData] = [], isFolder: Bool = false) {
        self.type = type
        self.title = title
        self.items = items
        self.isFolder = false
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: ITuneDataSection, rhs: ITuneDataSection) -> Bool {
        lhs.id == rhs.id
    }
}
