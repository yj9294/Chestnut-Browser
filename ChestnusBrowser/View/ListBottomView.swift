//
//  ListBottomeView.swift
//  ChestnusBrowser
//
//  Created by yangjian on 2023/10/28.
//

import SwiftUI
import ComposableArchitecture

struct ListBottomFeature: Reducer {
    struct State: Equatable {}
    enum Action: Equatable {
        case backButtonTapped
        case addButtonTapped
    }
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            return .none
        }
    }
}

struct ListBottomView: View {
    let store: StoreOf<ListBottomFeature>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            ZStack{
                HStack{
                    Spacer()
                    Button(action: {
                        viewStore.send(.addButtonTapped)
                    }, label: {
                        Image(.addIcon)
                    })
                    Spacer()
                }
                HStack{
                    Spacer()
                    Button {
                        viewStore.send(.backButtonTapped)
                    } label: {
                        Text(verbatim: .back).font(.system(size: 14)).padding(.trailing, 24)
                    }.foregroundColor(.black)
                }
            }.frame(height: 56)
        }
    }
}


extension String {
    static let addIcon = "icon_add"
    static let back = "back"
}

#Preview {
    ListBottomView(store: Store.init(initialState: ListBottomFeature.State(), reducer: {
        ListBottomFeature()
    }))
}
