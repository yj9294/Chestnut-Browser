//
//  CleanAlertView.swift
//  ChestnusBrowser
//
//  Created by yangjian on 2023/10/31.
//

import SwiftUI
import ComposableArchitecture

struct CleanAlertFeature: Reducer {
    struct State: Equatable {}
    enum Action: Equatable {
        case dismiss
        case confirmButtonTapped
    }
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            return .none
        }
    }
}

struct CleanAlertView: View {
    let store: StoreOf<CleanAlertFeature>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack{
                Spacer()
                VStack{
                    Image(.cleanAlertIcon)
                    Text(verbatim: .cleanAlertTitle).font(.system(size: 15))
                    Button(action: {
                        viewStore.send(.confirmButtonTapped)
                    }, label: {
                        HStack {
                            Spacer()
                            Text(verbatim: .confirm).padding(.vertical, 14).font(.system(size: 14, weight: .medium))
                            Spacer()
                        }
                    }).background(Color.cleeanAlertColor.cornerRadius(22)).padding(.horizontal, 50).padding(.top, 20)
                    HStack{
                        Spacer()
                    }
                }.padding(.vertical, 32).background(Color.white.cornerRadius(12)).padding(.horizontal, 34)
                Spacer()
            }.background(Color.black.ignoresSafeArea().opacity(0.5).onTapGesture {
                viewStore.send(.dismiss)
            })
        }
    }
}

extension Color {
    static let cleeanAlertColor = Color("#7C3F29")
}

extension String {
    static let cleanAlertIcon = "clean_alert"
    static let cleanAlertTitle = "Close Tabs and Clear Data"
    static let confirm = "Confirm"
}

#Preview {
    CleanAlertView(store: Store.init(initialState: CleanAlertFeature.State(), reducer: {
        CleanAlertFeature()
    }))
}
