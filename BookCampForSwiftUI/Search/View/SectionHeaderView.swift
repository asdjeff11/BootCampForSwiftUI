//
//  SectionHeaderView.swift
//  BookCampForSwiftUI
//
//  Created by 楊宜濱 on 2025/5/3.
//
import SwiftUI

struct SectionHeaderView: View {
    let title: String
    let isFolder: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Image(systemName: isFolder ? "chevron.down": "chevron.up")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.gray)
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
}
