//
//  PersonalCellView.swift
//  BookCampForSwiftUI
//
//  Created by 楊宜濱 on 2025/5/3.
//

import SwiftUI

struct PersonalCellView: View {
    var item: PersonlModel
    var body: some View {
        HStack {
            Text(item.title)
                .font(.title)
            
            Spacer()
            
            Text(item.text)
                .font(.system(size: 15))
            
            Image(systemName: "chevron.right.to.line")
            .tint(.black)
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 10))
        .cornerRadius(15)
        .background(Color.gray.opacity(0.2))
        .padding(20)
    }
    
}

#Preview {
    PersonalCellView(item:PersonlModel(title: "語言", text: "繁體中文"))
}
