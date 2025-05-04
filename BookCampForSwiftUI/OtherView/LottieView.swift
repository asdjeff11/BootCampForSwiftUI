//
//  NoItemLottie.swift
//  BookCampForSwiftUI
//
//  Created by 楊宜濱 on 2025/5/4.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var animationName: String
    var loopMode: LottieLoopMode = .loop
    
    var animationSpeed: CGFloat = 1
    var completion: LottieCompletionBlock? = nil
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        animationView.animation = LottieAnimation.named(animationName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        animationView.backgroundBehavior = .pauseAndRestore // 結束後回到最初
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        animationView.play(completion: completion)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let animationView = uiView.subviews.first(where: { $0 is LottieAnimationView }) as? LottieAnimationView else {
            return
        }
        if animationView.contentMode != .scaleAspectFit { // 強制設回
             animationView.contentMode = .scaleAspectFit
        }

        if animationView.loopMode != loopMode {
            animationView.loopMode = loopMode
        }
        if animationView.animationSpeed != animationSpeed {
            animationView.animationSpeed = animationSpeed
        }
    }
}
