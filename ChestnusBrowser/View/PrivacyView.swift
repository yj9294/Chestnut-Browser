//
//  PrivacyView.swift
//  ChestnusBrowser
//
//  Created by yangjian on 2023/10/30.
//

import SwiftUI
import ComposableArchitecture

struct PrivacyFeature: Reducer {
    struct State: Equatable {
        var item: Item = .privacy
    }
    enum Action: Equatable {
        case dismiss
    }
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            return .none
        }
    }
}

extension PrivacyFeature.State {
    enum Item {
        case privacy, terms
        var title: String {
            if self == .privacy {
                return "Privacy Policy"
            } else {
                return "Terms of Users"
            }
        }
    }
}

struct PrivacyView: View {
    let store: StoreOf<PrivacyFeature>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            NavigationView(content: {
                VStack(content: {
                    ScrollView{
                        Text("""
The following terms and conditions (the “Terms”) govern your use of the VPN services we provide (the “Service”) and their associated website domains (the “Site”). These Terms constitute a legally binding agreement (the “Agreement”) between you and Tap VPN. (the “Tap VPN”).

Activation of your account constitutes your agreement to be bound by the Terms and a representation that you are at least eighteen (18) years of age, and that the registration information you have provided is accurate and complete.

Tap VPN may update the Terms from time to time without notice. Any changes in the Terms will be incorporated into a revised Agreement that we will post on the Site. Unless otherwise specified, such changes shall be effective when they are posted. If we make material changes to these Terms, we will aim to notify you via email or when you log in at our Site.

By using Tap VPN
You agree to comply with all applicable laws and regulations in connection with your use of this service.regulations in connection with your use of this service.
""").padding().font(.system(size: 13.0, weight: .medium))
                    }
                }).background.navigationTitle(viewStore.item.title).navigationBarTitleDisplayMode(.inline).toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            viewStore.send(.dismiss)
                        }, label: {
                            Image("back")
                        })
                    }
                })
            })
        }
    }
}

#Preview {
    PrivacyView(store: Store.init(initialState: PrivacyFeature.State(), reducer: {
        PrivacyFeature()
    }))
}
