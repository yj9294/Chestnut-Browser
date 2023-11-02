//
//  HomeSearchView.swift
//  ChestnusBrowser
//
//  Created by yangjian on 2023/10/27.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct HomeSearchFeature: Reducer {
    struct State: Equatable {
        @BindingState var text: String = ""
        var isLoading: Bool = false
        fileprivate var searchURL: URL? {
            let url = text
            if url.isEmpty {
                return nil
            }
            if url.isUrl, let url = URL(string: url) {
                return url
            } else {
                let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                return URL(string:"https://www.google.com/search?q=" + urlString)!
            }
        }
    }
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case searchButtonTapped
        case stopButtonTapped
        case alert
        case searchURL(URL)
    }
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .searchButtonTapped:
                guard let url = state.searchURL else {
                    return .run { send in
                        await send(.alert)
                    }
                }
                return .run { send in
                    await send(.searchURL(url))
                }
            default:
                break
            }
            return .none
        }
    }
}

struct HomeSearchView: View {
    let store: StoreOf<HomeSearchFeature>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            HStack{
                TextField("", text: viewStore.$text, prompt: Text(verbatim: .searchPlaceholder)).padding(.all, 16)
                Spacer()
                Button {
                    viewStore.send(viewStore.isLoading ? .stopButtonTapped : .searchButtonTapped)
                } label: {
                    Image(viewStore.isLoading ? .stopIcon :  .searchIcon)
                }.padding(.all, 16)
            }.background(.white).cornerRadius(28)
        }
    }
}

extension String {
    static let searchPlaceholder = "Search or enter an address"
    static let searchIcon = "home_search"
    static let stopIcon = "home_stop"
}


#Preview {
    HomeSearchView(store: Store.init(initialState: HomeSearchFeature.State(), reducer: {
        HomeSearchFeature()
    }))
}
