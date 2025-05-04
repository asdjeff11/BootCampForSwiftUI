//
//  SearchViewModel.swift
//  BookCampForSwiftUI
//
//  Created by 楊宜濱 on 2025/5/3.
//

import Combine
import Alamofire

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var sections: [ITuneDataSection] = [ITuneDataSection(type: .電影, title: "電影"),
                                                   ITuneDataSection(type: .音樂, title: "音樂")]
    @Published var activeError: AppError? = nil
    
    func toggleFolderState(for sectionId: UUID) {
        if let index = sections.firstIndex(where: { $0.id == sectionId }) {
            sections[index].isFolder.toggle()
        }
    }
    
    
    func loadingData() async {
        guard !searchText.isEmpty, !isLoading else { return }
        
        isLoading = true
        self.sections.indices.forEach { self.sections[$0].items = [] }
        do {
            try await withThrowingTaskGroup(of: (MediaType, [MyITuneData]).self) { group in
                for mediaType in MediaType.allCases {
                    group.addTask {
                        let items = try await self.fetchKeyword(condition:SearchITuneCondition(term: self.searchText,media: mediaType))
                        return (mediaType, items)
                    }
                    
                    for try await (mediaType, items) in group {
                        if let index = self.sections.firstIndex(where: { $0.type == mediaType }) {
                            self.sections[index].items = items
                        }
                    }
                }
            }
        } catch {
            self.activeError = .dataLoadError(underlyingError: error)
            print("Error during fetching data: \(error)")
        }
        
        isLoading = false
    }

    
    private func fetchKeyword(condition:SearchITuneCondition) async throws -> [MyITuneData] {
        let itunResult: ITuneResult = try await self.fetchURLData(url_Str: condition.getUrl())
        return itunResult.results.map({ MyITuneData(detail: $0, type: condition.media) })
    }
    
    // URL 撈取資訊
    func fetchURLData<T:Codable>(url_Str:String) async throws -> T {
        let response = await AF.request(url_Str) { $0.timeoutInterval = 30 }
                            .validate() // status code
                            .serializingDecodable(T.self) // decodable
                            .response // API reponse
        switch response.result {
        case .success(let data) :
            return data
        case .failure(let error) :
            throw error
        }
    }
    
    
    
    func setCollect(item: MyITuneData) async {
        guard isLoading == false else { return }
        
        let trackId = item.trackId
        let type = item.type == 0 ? MediaType.電影 : MediaType.音樂
        isLoading = true
        do {
            if ( UserData.shared.isCollect(type: type, trackId: trackId) ) { // 原本追蹤
                try await UserData.shared.removeData(type: type, trackId: trackId)
            } else { // 原本沒追蹤
                try await UserData.shared.saveData(data: item)
            }
        } catch let error as MyDataBaseActor.SQLiteError {
            self.activeError = .databaseError(error: error)
        } catch {
            self.activeError = .unknownError(error: error)
        }
            
        isLoading = false
    }
    
    func isCollect(item: MyITuneData) -> Bool {
        let trackId = item.trackId
        let type = item.type == 0 ? MediaType.電影 : MediaType.音樂
        return UserData.shared.isCollect(type: type, trackId: trackId)
    }
}
