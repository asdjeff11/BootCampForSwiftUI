//
//  CollectView.swift
//  BookCampForSwiftUI
//
//  Created by 楊宜濱 on 2025/5/3.
//
import SwiftUI
struct CollectView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var userData: UserData
    @StateObject var viewModel = CollectViewModel()
    @State var timer = Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()
    @State var offset: Double = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Picker("選擇分類", selection: $viewModel.selectedCategory) {
                    ForEach(MediaType.allCases) { category in
                        Text(category.getChineseString().localized).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding(25)
                
                Divider()
           
                if viewModel.collectData.isEmpty {
                    VStack {
                        Spacer()
                        Text("沒有追蹤項目".localized)
                            .font(.system(size: 20))
                            .textRenderer(CustomTextRenderer(timeOffset: offset))
                            .onReceive(timer) { _ in
                                if offset > 1_000_000_000_000 { offset = 0 }
                                else { offset += 10 }
                            }.padding(.bottom, 50)
                        LottieView(
                            animationName: "EmptyAnimation",
                            loopMode: .loop
                        )
                        .frame(width: 200, height: 200)
                        Spacer()
                    }
                    .transition(.opacity.animation(.easeIn))

                } else {
                    // List
                    List {
                        ForEach(viewModel.collectData) { item in
                            SearchCell(item: item, isCollected: true, collectionBtnAction: {
                                Task(priority: .background) {
                                    await viewModel.removeCollect(item: item)
                                }
                            }, cellTapAction: {
                                if let url = URL(string: item.trackViewURL) {
                                    UIApplication.shared.open(url)
                                }
                            })
                            .listRowInsets(EdgeInsets()) // 移除邊距
                            .listRowSeparator(.hidden) // 移除分隔線
                            // .transition(...) // 保留或移除
                        }
                    }
                    .listStyle(.plain)
                    .transition(.asymmetric(insertion: .opacity.animation(.easeIn), removal: .opacity.animation(.easeOut)))
                    .id(viewModel.selectedCategory)
                }
            } // VStack
        } // ZStack
        .loadingOverlay(isShowing: $viewModel.isLoading)
        .alert(isPresented: .constant(viewModel.activeError != nil),
                           error: viewModel.activeError)
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
        .navigationTitle("收藏".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                 Button {
                     navigationManager.goBack()
                 } label: {
                     Image(systemName: "arrowtriangle.backward.fill")
                 } .tint(.white)
             }
        }
    }
}

#Preview {
    CollectView()
}
