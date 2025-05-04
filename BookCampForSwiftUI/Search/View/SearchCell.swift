//
//  SearchCell.swift
//  BookCampForSwiftUI
//
//  Created by 楊宜濱 on 2025/5/3.
//
import SwiftUI

struct SearchCell: View {
    let item: MyITuneData
    let isCollected:Bool
    var collectionBtnAction:() -> Void
    var cellTapAction: (() -> Void)? = nil
    var body: some View {
        HStack {
            AsyncImage(url: URL(string:item.imageURL)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 100, height: 100)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(item.trackName)
                    .font(.system(size: 25))
                    .lineLimit(2)
                Text(item.artistName)
                    .font(.system(size: 15))
                    .lineLimit(2)
                Text(item.collectionName)
                    .font(.system(size: 15))
                    .lineLimit(2)
                Text(item.longTime)
                    .font(.system(size: 10))
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button( isCollected ? "取消收藏".localized : "收藏".localized) {
                collectionBtnAction()
            }
            .foregroundStyle(Color.white)
            .frame(width: 70)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(Color(Theme.yellowBtn))
            .contentShape(Rectangle())
            .cornerRadius(20)
            .buttonStyle(.plain) // 解除List的默認交互行為
            
        }.padding(10)
        .onTapGesture {
            cellTapAction?()
        }
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    SearchCell(item: MyITuneData(detail: ITuneDataDetail(trackId: 1, trackName: "Prince Noodle", artistName: "Mayday", collectionName: "自傳", trackTimeMillis: 300, trackViewUrl: "", artworkUrl100: ""), type: .音樂), isCollected: false, collectionBtnAction: {})
}
