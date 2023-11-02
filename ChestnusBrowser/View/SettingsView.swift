//
//  SettingView.swift
//  ChestnusBrowser
//
//  Created by yangjian on 2023/10/30.
//

import SwiftUI
import ComposableArchitecture
import UniformTypeIdentifiers

struct SettingsFeature: Reducer {
    struct State: Equatable {
    }
    enum Action: Equatable {
        case dismiss
        case newButtonTapped
        case shareButtonTapped
        case copyButtonTapped
        case termsButtonTapped
        case rateButtonTapped
        case privacyButtonTapped
        case item(State.Item)
    }
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            switch action {
            case .item(let item):
                switch item {
                case .new:
                    return .run { send in
                        await send(.newButtonTapped)
                    }
                case .rate:
                    let AppUrl = "https://itunes.apple.com/cn/app/id"
                    OpenURLAction { URL in
                        .systemAction(URL)
                    }.callAsFunction(URL(string: AppUrl)!)
                    return .run { send in
                        await send(.rateButtonTapped)
                    }
                case .share:
                    return .run { send in
                        await send(.shareButtonTapped)
                    }
                case .terms:
                    return .run { send in
                        await send(.termsButtonTapped)
                    }
                case .privacy:
                    return .run { send in
                        await send(.privacyButtonTapped)
                    }
                case .copy:
                    return .run { send in
                        await send(.copyButtonTapped)
                    }
                }
            default:
                break
            }
            return .none
        }
    }
}

extension SettingsFeature.State {
    var items: [Item] {
        Item.allCases
    }
    enum Item: String, CaseIterable {
        case new, share, copy, terms, rate, privacy
        var title: String {
            if self == .rate {
                return "Rate Us"
            }
            if self == .terms {
                return "Terms of Users"
            }
            if self == .privacy {
                return "Privacy Policy"
            }
            return self.rawValue.capitalized
        }
        var icon: String {
            "settings_" + self.rawValue
        }
    }
}

struct SettingsView: View {
    let store: StoreOf<SettingsFeature>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], content: {
                        ForEach(viewStore.items, id: \.self) { item in
                            Button(action: {
                                viewStore.send(.item(item))
                            }, label: {
                                VStack{
                                    Image(item.icon)
                                    Text(item.title)
                                }
                            }).font(.system(size: 14)).foregroundColor(.black)
                        }
                    }).padding(.all, 15).background.cornerRadius(12).padding(.horizontal, 12)
                    Spacer()
                }.padding(.bottom, 90)
            }.background(Color.black.ignoresSafeArea().opacity(0.5).onTapGesture {
                viewStore.send(.dismiss)
            })
        }
    }
}

#Preview {
    SettingsView(store: Store.init(initialState: SettingsFeature.State(), reducer: {
        SettingsFeature()
    }))
}
