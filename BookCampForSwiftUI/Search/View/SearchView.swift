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
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                TextField("請輸入文字...", text: $viewModel.searchText)
                    .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                
                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    Task {
                        await viewModel.loadingData()
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .resizable() // 讓圖片可調整大小
                        .scaledToFit() // 保持圖片的原始比例縮放
                        .tint(Color(Theme.yellowBtn))
                        .frame(width: 30, height: 30)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                .disabled(viewModel.searching) // 防止重複點擊
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            
            ScrollView {
                LazyVStack(alignment: .leading,spacing: 0, pinnedViews: [.sectionHeaders]){
                    ForEach(viewModel.sections) { section in
                        Section {
                            if ( !section.isFolder ) {
                                ForEach(section.items) { item in
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("\(item.trackName)")
                                    }
                                    if section.items.last != item {
                                        Divider().padding(.leading)
                                    }
                                }
                            } else {
                                EmptyView()
                            }
                        } header: {
                            HStack {
                                Text(section.title)
                                    .font(.headline)
                                Spacer()
                                Image(systemName: section.isFolder ? "chevron.down": "chevron.up")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(.gray)

                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.thinMaterial)
                            .contentShape(Rectangle())
                            .onTapGesture {
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
        .overlay {
            if( viewModel.searching ) {
                spinner
            } else {
                Empty()
            }
        }
    }
}

//#Preview {
//    SearchView()
//}
