//
//  TabItemView.swift
//  BookCampForSwiftUI
//
//  Created by 楊宜濱 on 2025/5/3.
//

import SwiftUI

struct TabItemView: View {
    let buttonIcon: Image
    let buttonAction: () -> Void
    
    var body : some View {
        VStack {
            Button {
                buttonAction()
            } label: {
                buttonIcon.resizable()  // 讓圖示可以調整大小
                    .scaledToFit()  // 保持比例
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
            }.padding()
            
        }
    }
}

#Preview {
    TabItemView(buttonIcon: Image(systemName: "search"), buttonAction: {})
}
