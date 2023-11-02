//
//  ListView.swift
//  ChestnusBrowser
//
//  Created by yangjian on 2023/10/28.
//

import SwiftUI
import ComposableArchitecture

struct ListFeature: Reducer {
    struct State: Equatable {
        var content: ListContentFeature.State = .init()
        var bottom: ListBottomFeature.State = .init()
        var ad: GADNativeViewModel = .none
    }
    enum Action: Equatable {
        case content(ListContentFeature.Action)
        case bottom(ListBottomFeature.Action)
        case dismiss
    }
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            switch action {
            case let .bottom(action):
                switch action {
                case .addButtonTapped:
                    return .run { send in
                        await send(.content(.add))
                    }
                case .backButtonTapped:
                    return .run { send in
                        await send(.dismiss)
                    }
                default:
                    break
                }
            default:
                break
            }
            return .none
        }
        Scope.init(state: \.content, action: /Action.content) {
            ListContentFeature()
        }
        Scope.init(state: \.bottom, action: /Action.bottom) {
            ListBottomFeature()
        }
    }
}

struct ListView: View {
    let store: StoreOf<ListFeature>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack{
                ScrollView{
                    ListContentView(store: store.scope(state: \.content, action: ListFeature.Action.content)).padding(.all, 16)
                }
                Spacer()
                HStack{
                    GADNativeView(model: viewStore.ad)
                }.frame(height: 76).padding(.horizontal, 20)
                Spacer()
                ListBottomView(store: store.scope(state: \.bottom, action: ListFeature.Action.bottom))
            }.background
        }
    }
}



#Preview {
    ListView(store: Store.init(initialState: ListFeature.State(), reducer: {
        ListFeature()
    }))
}
