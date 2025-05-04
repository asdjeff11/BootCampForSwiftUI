//
//  SearchView.swift
//  BookCampForSwiftUI
//
//  Created by 楊宜濱 on 2025/5/3.
//


import SwiftUI
import Combine
struct SearchView: View {
    @StateObject var viewModel = SearchViewModel()
    @State private var showingEmptyInputAlert = false
    @StateObject var userData = UserData.shared
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    TextField("請輸入文字...".localized, text: $viewModel.searchText)
                        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                    
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        if ( viewModel.searchText.isEmpty) {
                            showingEmptyInputAlert = true
                        } else {
                            Task(priority: .background) {
                                await viewModel.loadingData()
                            }
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .resizable() // 讓圖片可調整大小
                            .scaledToFit() // 保持圖片的原始比例縮放
                            .tint(Color(Theme.yellowBtn))
                            .frame(width: 30, height: 30)
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                .alert("輸入錯誤".localized, isPresented: $showingEmptyInputAlert) {
                    Button("確定".localized) {}
                } message: {
                    Text("請填寫搜尋內容".localized)
                }
                
                
                ScrollView {
                    LazyVStack(alignment: .leading,spacing: 0, pinnedViews: [.sectionHeaders]){
                        ForEach(viewModel.sections) { section in
                            Section {
                                if ( !section.isFolder ) {
                                    ForEach(section.items) { item in
                                        SearchCell(
                                            item: item, isCollected: userData.isCollect(
                                                type: MediaType(rawValue: item.type) ?? .電影,
                                                trackId: item.trackId
                                            )
                                        ) {
                                            Task {
                                                await viewModel.setCollect(item: item)
                                            }
                                        }
                                        // 分隔線
                                        if section.items.last != item {
                                            Divider().padding(.leading)
                                        }
                                    }
                                } else {
                                    EmptyView()
                                }
                            } header: {
                                SectionHeaderView(title: section.title.localized, isFolder: section.isFolder) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.toggleFolderState(for: section.id)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 30)
        }
        .loadingOverlay(isShowing: $viewModel.isLoading)
        .alert(isPresented: .constant(viewModel.activeError != nil), // 手動控制 isPresented
                           error: viewModel.activeError) // 綁定到錯誤狀態
        { error in
            Button("確定".localized) {
                viewModel.activeError = nil
            }
        } message: { error in
            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
            } else {
                Text("Data error")
            }
        }
    }
}

//#Preview {
//    SearchView()
//}
