import SwiftUI

struct LoadingOverlay<Content: View>: View {
    @Binding var isShowing: Bool // 綁定到你的 isLoading 狀態
    let content: () -> Content // 允許傳入自定義的加載內容 (例如 Spinner + Text)

    var body: some View {
        GeometryReader { geometry in // 使用 GeometryReader 獲取可用空間
            ZStack(alignment: .center) { // 居中對齊
                // 只有在 isShowing 為 true 時才顯示覆蓋層
                if isShowing {
                    // 半透明黑色背景
                    Rectangle()
                        .fill(.black.opacity(0.4)) // 半透明黑色
                        .frame(width: geometry.size.width, height: geometry.size.height) // 填滿父視圖
                        .edgesIgnoringSafeArea(.all) // 忽略安全區域，填滿整個屏幕
                        // .allowsHitTesting(true) // Rectangle 默認會阻止點擊穿透

                    // 加載指示器的內容
                    VStack {
                        content() // 顯示傳入的加載內容
                    }
                    // 可選：給加載內容加個背景和圓角，讓它更突出
                    .padding(20)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 15)) // 毛玻璃效果
                    .shadow(radius: 10)
                    // .frame(width: geometry.size.width / 2, height: geometry.size.height / 5) // 可選：限制大小
                    // .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // 確保居中 (ZStack 默認會居中)
                }
            }
        }
    }
}

// 提供一個默認的加載內容視圖 (Spinner + Text)
struct DefaultLoadingContent: View {
    var text: String? = "處理中...".localized // 默認文本，支持本地化

    var body: some View {
        VStack(spacing: 15) {
            ProgressView() // Spinner
                .progressViewStyle(CircularProgressViewStyle(tint: .primary)) // 使用主題顏色
                .scaleEffect(1.5) // 可以稍微放大 Spinner

            if let text = text, !text.isEmpty {
                Text(text)
                    .font(.caption)
                    .foregroundColor(.secondary) // 使用次要文字顏色
            }
        }
    }
}

// 為了方便使用，創建一個 ViewModifier (更高級的用法)
struct LoadingOverlayModifier: ViewModifier {
    @Binding var isShowing: Bool
    var text: String?

    func body(content: Content) -> some View {
        ZStack {
            content // 你應用這個 Modifier 的原始視圖

            LoadingOverlay(isShowing: $isShowing) {
                DefaultLoadingContent(text: text)
            }
        }
    }
}

// 提供一個易於使用的擴展
extension View {
    func loadingOverlay(isShowing: Binding<Bool>, text: String? = "處理中...".localized) -> some View {
        self.modifier(LoadingOverlayModifier(isShowing: isShowing, text: text))
    }
}