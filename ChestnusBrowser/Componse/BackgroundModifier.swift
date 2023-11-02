//
//  BackgroundModifier.swift
//  ChestnusBrowser
//
//  Created by yangjian on 2023/10/27.
//

import SwiftUI

struct BackgroundModifier: ViewModifier {
        
    func body(content: Content) -> some View {
        content.background(
            LinearGradient.linearGradient(colors: [.primary, .yellowWhite, .white], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
        )
    }
}

extension Color {
    static let primary = Color("#FFD289")
    static let yellowWhite = Color("#FFF7EB")
    static let orange = Color("#FE7B00")
}

extension View {
    var background: some View {
        self.modifier(BackgroundModifier())
    }
}
