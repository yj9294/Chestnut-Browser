//
//  HomeContentView.swift
//  ChestnusBrowser
//
//  Created by yangjian on 2023/10/28.
//

import SwiftUI
import WebKit
import ComposableArchitecture

struct HomeContentFeature: Reducer {
    struct State: Equatable, Identifiable {
        var browser: Browser.State = .init()
        
        var id: String = UUID().uuidString
        var isSelected: Bool = true
        var hasDeleteIcon: Bool = false
        var ad: GADNativeViewModel = .none
    }
    
    enum Action: Equatable {
        case itemButtonTapped(State.Item)
        case browser(Browser.Action)
        case remove
        case seleted
    }
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            return .none
        }
        Scope.init(state: \.browser, action: /Action.browser) {
            Browser()
        }
    }
}

extension HomeContentFeature.State {
    var progress: Double {
        browser.progress
    }
    var isLoading: Bool {
        browser.webView.isLoading
    }
    var isBrowser: Bool {
        !browser.url.isEmpty
    }
    var items: [Item] {
        Item.allCases
    }
    var url: String {
        browser.url
    }
    enum Item: String, Equatable, CaseIterable {
        case facebook,google, youtube, twitter, instagram, amazon, gmail, yahoo
        var icon: String {
            "home_\(self.rawValue)"
        }
        var title: String {
            self.rawValue.capitalized
        }
        var url: String {
            "https://www.\(self.rawValue).com"
        }
    }
}

struct HomeContentView: View {
    let store: StoreOf<HomeContentFeature>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack{
                if viewStore.isLoading {
                    ProgressView(value: viewStore.progress).tint(.orange)
                }
                VStack {
                    if viewStore.isBrowser {
                        BrowserView(store: store.scope(state: \.browser, action: HomeContentFeature.Action.browser))
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())], spacing: 28) {
                            ForEach(viewStore.items, id: \.self) { item in
                                Button(action: {
                                    viewStore.send(.itemButtonTapped(item))
                                }, label: {
                                    VStack{
                                        Image(item.icon)
                                        Text(item.title)
                                    }
                                }).font(.system(size: 13.0)).foregroundColor(.black)
                            }
                        }
                    }
                }
                .padding(.top, 10)
                Spacer()
                HStack{
                    GADNativeView(model: viewStore.ad)
                }.frame(height: 76).padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    HomeContentView(store: Store.init(initialState: HomeContentFeature.State(), reducer: {
        HomeContentFeature()
    }))
}
