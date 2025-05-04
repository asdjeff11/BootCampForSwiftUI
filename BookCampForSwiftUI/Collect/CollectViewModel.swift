//
//  CollectViewModel.swift
//  BookCampForSwiftUI
//
//  Created by 楊宜濱 on 2025/5/4.
//

import Combine
import SwiftUI

@MainActor
class CollectViewModel: ObservableObject {
    @Published var selectedCategory: MediaType = .電影
    @Published var collectData: [MyITuneData] = []
    @Published var isLoading = false
    @Published var activeError: AppError? = nil
    
    private let userData = UserData.shared
    private var cancellables: Set<AnyCancellable> = []
    init() {
        $selectedCategory
            .removeDuplicates() // avoid duplicates
            .map { [weak self] category -> [MyITuneData] in
                guard let self = self else { return [] }
                return self.userData.getCollectMedia(type: category)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.collectData, on: self)
            .store(in: &cancellables)
    }
    
    func removeCollect(item: MyITuneData) async {
        guard isLoading == false else { return }
        isLoading = true
        let itemIDToRemove = item.id
        collectData.removeAll { $0.id == itemIDToRemove }
        
        do {
            try await userData.removeData(type: selectedCategory, trackId: item.trackId) // *** 假設有一個異步且可能拋錯的方法 ***
        } catch let error as MyDataBaseActor.SQLiteError {
            self.activeError = .databaseError(error: error)
        } catch {
            self.activeError = .unknownError(error: error)
        }
        
        isLoading = false
    }
}
