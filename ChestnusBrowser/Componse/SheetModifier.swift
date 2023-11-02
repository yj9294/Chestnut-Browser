//
//  SheetModifier.swift
//  ChestnusBrowser
//
//  Created by yangjian on 2023/10/30.
//

import SwiftUI
import ComposableArchitecture

struct SheetModifier: ViewModifier {
    let store: StoreOf<HomeRootFeature>
    let presentation: SheetPresentation
    func body(content: Content) -> some View {
        switch presentation {
        case .list:
            AnyView(
                content.sheet(store: store.scope(state: \.$list, action: {.listAction($0)})) { store in
                    ListView(store: store)
                }
            )
        case .settings:
            AnyView(
                content.fullScreenCover(store: store.scope(state: \.$settings, action: {.settingsAction($0)})) { store in
                    SettingsView(store: store).background(PresentationView(.clear))
                }
            )
        case .share:
            AnyView(
                content.sheet(store: store.scope(state: \.$share, action: {.shareAction($0)})) { store in
                    ShareViwe(store: store)
                }
            )
        case .privacy:
            AnyView(
                content.fullScreenCover(store: store.scope(state: \.$privacy, action: {.privacyAction($0)})) { store in
                    PrivacyView(store: store)
                }
            )
        case .cleanAlert:
            AnyView(
                content.fullScreenCover(store: store.scope(state: \.$cleanAlert, action: {.cleanAlertAction($0)})) { store in
                    CleanAlertView(store: store).background(PresentationView(.clear))
                }
            )
        case .clean:
            AnyView(
                content.fullScreenCover(store: store.scope(state: \.$clean, action: {.cleanAction($0)})) { store in
                    CleanView(store: store)
                }
            )
        }
        
    }
    
    enum SheetPresentation {
        case list, settings, clean, cleanAlert, share, privacy
    }
}

extension View {
    func sheetPresent(store: StoreOf<HomeRootFeature>,  presentation: SheetModifier.SheetPresentation) -> some View {
        self.modifier(SheetModifier(store: store, presentation: presentation))
    }
}
