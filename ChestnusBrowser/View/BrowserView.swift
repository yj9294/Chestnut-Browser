//
//  BrowserView.swift
//  ChestnusBrowser
//
//  Created by yangjian on 2023/10/28.
//

import Foundation
import WebKit
import SwiftUI
import ComposableArchitecture

struct Browser: Reducer {
    @Dependency(\.continuousClock) var clock
    enum CancelID { case timer}
    struct State: Equatable {
        private(set) var webView: WKWebView = .init()
        private(set) var progress: Double = 0
        private(set) var canGoBack: Bool = false
        private(set) var canGoForward: Bool = false
        private(set) var isLoading: Bool = false
        private(set) var url: String = ""
        
        var isRefresh = false
        
        enum Property: Equatable {
            case progress(Double), canGoBack(Bool), canGoForward(Bool), url(String), isLoading(Bool)
        }
        
        fileprivate mutating func update(property: Browser.State.Property) {
            switch property {
            case .progress(let double):
                progress = double
            case .canGoBack(let bool):
                canGoBack = bool
            case .canGoForward(let bool):
                canGoForward = bool
            case .url(let string):
                url = string
            case .isLoading(_):
                isLoading = webView.isLoading
            }
        }
        
        fileprivate mutating func stop() {
            url = webView.url?.absoluteString ?? ""
            progress = 0.0
        }
    }
    enum Action: Equatable {
        case searchURL(URL)
        case stop
        case goBack
        case goForward
        case update(Browser.State.Property)
        case refresh(Bool)
    }
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .update(property):
            state.update(property: property)
        case let .searchURL(url):
            state.webView.load(URLRequest(url: url))
            let progress = state.webView.publisher(for: \.estimatedProgress).map{Action.update(.progress($0))}
            let url = state.webView.publisher(for: \.url).compactMap({$0?.absoluteString}).map{Action.update(.url($0))}
            let canGoBack = state.webView.publisher(for: \.canGoBack).map{Action.update(.canGoBack($0))}
            let canGoForward = state.webView.publisher(for: \.canGoForward).map{Action.update(.canGoForward($0))}
            let isLoading = state.webView.publisher(for: \.isLoading).map{Action.update(.isLoading($0))}
            let publisher = progress.merge(with: url).merge(with: canGoBack).merge(with: canGoForward).merge(with: isLoading).eraseToAnyPublisher()
            return .publisher {
                publisher
            }
        case .stop:
            state.webView.stopLoading()
            state.stop()
        case .goBack:
            state.webView.goBack()
        case .goForward:
            state.webView.goForward()
        case let .refresh(bool):
            state.isRefresh = bool
            if bool {
                return .run { send in
                    for await _ in clock.timer(interval: .milliseconds(10)) {
                        await send(.refresh(false))
                    }
                }.cancellable(id: CancelID.timer)
            } else {
                return .cancel(id: CancelID.timer)
            }
        }
        return .none
    }
}

struct BrowserView: View {
    let store: StoreOf<Browser>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack{
                if !viewStore.isRefresh {
                    UIBrowserView(webView: viewStore.webView)
                } else {
                    Spacer()
                }
            }
        }
    }
}

struct UIBrowserView: UIViewRepresentable, Equatable {
    let webView: WKWebView
    func makeUIView(context: Context) -> some UIView {
        return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}


extension String {
    var isUrl: Bool {
        let url = "[a-zA-z]+://.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", url)
        return predicate.evaluate(with: self)
    }
}
