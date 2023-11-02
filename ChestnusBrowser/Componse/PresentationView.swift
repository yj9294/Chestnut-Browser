//
//  PresentationView.swift
//  ChestnusBrowser
//
//  Created by yangjian on 2023/10/30.
//

import Foundation
import SwiftUI

struct PresentationView: UIViewRepresentable {
    init(_ style: Style = .clear) {
        self.style = style
    }
    let style: Style
    func makeUIView(context: Context) -> UIView {
        if style == .blur {
            let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            DispatchQueue.main.async {
                view.superview?.superview?.backgroundColor = .clear
            }
            return view
        } else {
            let view = UIView()
            DispatchQueue.main.async {
                view.superview?.superview?.backgroundColor = .clear
            }
            return view
        }
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
    enum Style {
        case clear, blur
    }
}
