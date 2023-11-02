//
//  ListContentView.swift
//  ChestnusBrowser
//
//  Created by yangjian on 2023/10/28.
//

import SwiftUI

import ComposableArchitecture

struct ListContentFeature: Reducer {
    struct State: Equatable {
        var items: IdentifiedArrayOf<HomeContentFeature.State> = [.init()]
        fileprivate mutating func remove(_ id: String) {
            guard let item = items[id: id] else {
                debugPrint("Error state is not exist")
                return
            }
            items.remove(item)

            if items.count == 1 {
                let newItems = items.compactMap {
                    var it = $0
                    it.hasDeleteIcon = true
                    return it
                }
                items = IdentifiedArray(uniqueElements: newItems)
            }
        }
        fileprivate mutating func add() {
            let newItems = items.compactMap {
                var it = $0
                it.hasDeleteIcon = true
                if it.isSelected {
                    it.isSelected = false
                }
                return it
            }
            items = IdentifiedArray(uniqueElements: newItems)
            items.insert(.init(hasDeleteIcon: true), at: 0)
        }
        fileprivate mutating func seleted(_ id: String) {
            guard let item = items[id: id] else {
                debugPrint("Error state is not exist")
                return
            }
            let newItems = items.compactMap {
                var it = $0
                if item == it {
                    it.isSelected = true
                } else {
                    it.isSelected = false
                }
                return it
            }
            items = IdentifiedArray(uniqueElements: newItems)
        }
    }
    enum Action: Equatable {
        indirect case items(id: HomeContentFeature.State.ID, action: HomeContentFeature.Action)
        case add
        case update
        case dismiss
    }
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            switch action {
            case let .items(id, action: action):
                switch action {
                case .seleted:
                    state.seleted(id)
                    return .run { send in
                        await send(.update)
                        await send(.dismiss)
                    }
                case .remove:
                    state.remove(id)
                    return .run { send in
                        await send(.update)
                    }
                default:
                    break
                }
            case .add:
                state.add()
                return .run { send in
                    await send(.update)
                    await send(.dismiss)
                }
            default:
                break
            }
            return .none
        }
    }
}


struct ListContentView: View {
    let store: StoreOf<ListContentFeature>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack{
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                    ForEachStore(store.scope(state: \.items, action: {.items(id: $0, action: $1)})) { store in
                        ListContentItemView(store: store)
                    }
                }
            }
        }
    }
}

struct ListContentItemView: View {
    let store: StoreOf<HomeContentFeature>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            Button(action: {
                viewStore.send(.seleted)
            }, label: {
                ZStack{
                    if viewStore.isBrowser {
                        Color.red
                    }
                    VStack{
                        HStack{
                            Spacer()
                            Button {
                                viewStore.send(.remove)
                            } label: {
                                Image(.homeStop)
                            }.padding(.all, 4)
                        }.padding(.all, 8).opacity(viewStore.hasDeleteIcon ? 1.0 : 0.0)
                        Text(verbatim: !viewStore.isBrowser ? .navigation : viewStore.url).lineLimit(1).padding(.top, 30).foregroundColor(.black)
                        Spacer()
                    }
                }
            }).cornerRadius(8).background(RoundedRectangle(cornerRadius: 8).stroke(viewStore.isSelected ? Color.red : .gray)).frame(height: 216)
        }
    }
}

extension String {
    static let navigation = "Navigation"
}
