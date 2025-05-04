//
//  LoadingOverlay.swift
//  BookCampForSwiftUI
//
//  Created by 楊宜濱 on 2025/5/4.
//
import SwiftUI

struct DefaultLoadingContent: View {
    var text: String? = "處理中...".localized

    var body: some View {
        VStack(spacing: 15) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                .scaleEffect(1.5)

            if let text = text, !text.isEmpty {
                Text(text)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
         .padding(20)
         .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 15))
         .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct LoadingOverlayView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack(alignment: .center) {
            Rectangle()
                .fill(.black.opacity(0.4))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            content()
        }
        .allowsHitTesting(true)
    }
}


extension View {
    @ViewBuilder func loadingOverlay<V: View>(
        isShowing: Binding<Bool>,
        alignment: Alignment = .center,
        @ViewBuilder content: @escaping () -> V = { DefaultLoadingContent() }
    ) -> some View {
        self.overlay(alignment: .center) {
             if isShowing.wrappedValue {
                 LoadingOverlayView(content: content)
                     .transition(.opacity.animation(.default))
             }
        }
         .allowsHitTesting(!isShowing.wrappedValue) // 停止交互
    }
}
