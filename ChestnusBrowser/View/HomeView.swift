//
//  HomeView.swift
//  ChestnusBrowser
//
//  Created by yangjian on 2023/10/27.
//

import SwiftUI
import WebKit
import ComposableArchitecture

struct HomeFeature: Reducer {
    struct State: Equatable {
        var search: HomeSearchFeature.State = .init()
        var bottom: HomeBottomFeature.State = .init()
        var content: HomeContentFeature.State = .init()
        
        mutating func update() {
            self.bottom.canGoBack = content.browser.canGoBack
            self.bottom.canGoForward = content.browser.canGoForward
            self.search.text = content.browser.url
            self.search.isLoading = content.isLoading
        }
    }
    enum Action: Equatable {

        case alert(String)
        case search(HomeSearchFeature.Action)
        case bottom(HomeBottomFeature.Action)
        case content(HomeContentFeature.Action)
    }
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            switch action {
            case let .search(action):
                switch action{
                case let .searchURL(url):
                    return .run { send in
                        await send(.content(.browser(.searchURL(url))))
                    }
                case .stopButtonTapped:
                    return .run { send in
                        await send(.content(.browser(.stop)))
                    }
                case .alert:
                    return .run { send in
                        await send(.alert(CAlertState.search.message))
                    }
                default:
                    break
                }
            case let .content(action):
                switch action{
                case let .itemButtonTapped(item):
                    state.search.text = item.url
                    return .run { send in
                        await send(.search(.searchButtonTapped))
                    }
                case let .browser(action):
                    switch action {
                    case .update:
                        state.update()
                    default:
                        break
                    }
                default:
                    break
                }
            case let .bottom(action):
                switch action {
                case .backButtonTapped:
                    return .run { send in
                        await send(.content(.browser(.goBack)))
                    }
                case .forwardButtonTapped:
                    return .run { send in
                        await send(.content(.browser(.goForward)))
                    }
                default:
                    break
                }
            default:
                break
            }
            return .none
        }
        
        Scope.init(state: \.search, action: /Action.search) {
            HomeSearchFeature()
        }
        Scope.init(state: \.bottom, action: /Action.bottom) {
            HomeBottomFeature()
        }
        Scope.init(state: \.content, action: /Action.content) {
            HomeContentFeature()
        }
    }
    
}

struct HomeView: View {
    let store: StoreOf<HomeFeature>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack{
                HomeSearchView(store: store.scope(state: \.search, action: HomeFeature.Action.search)).padding(.horizontal, 28)
                HomeContentView(store: store.scope(state: \.content, action: HomeFeature.Action.content))
                Spacer()
                HomeBottomView(store: store.scope(state: \.bottom, action: HomeFeature.Action.bottom))
            }.background
        }
    }
}

#Preview {
    HomeView(store: Store.init(initialState: HomeFeature.State(), reducer: {
        HomeFeature()
    }))
}
