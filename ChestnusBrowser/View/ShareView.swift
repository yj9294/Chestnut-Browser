//
//  ShareView.swift
//  ChestnusBrowser
//
//  Created by yangjian on 2023/10/30.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct ShareFeature: Reducer {
    struct State: Equatable {}
    enum Action: Equatable {
        case dismiss
    }
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            return .none
        }
    }
}

struct ShareViwe: UIViewControllerRepresentable {
    let store: StoreOf<ShareFeature>
    func makeUIViewController(context: Context) -> some UIViewController {
        let vc = UIActivityViewController(
            activityItems: ["https://itunes.apple.com/cn/app/id"],
            applicationActivities: nil)
        vc.completionWithItemsHandler = context.coordinator.handle
        return vc
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: ShareViwe
        var handle: UIActivityViewController.CompletionWithItemsHandler? = nil
        init(_ parent: ShareViwe) {
            self.parent = parent
            self.handle = { _,_,_,_ in
                parent.store.send(.dismiss)
            }
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

#Preview {
    ShareViwe(store: Store.init(initialState: ShareFeature.State(), reducer: {
        ShareFeature()
    }))
}
