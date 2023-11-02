//
//  CleanView.swift
//  ChestnusBrowser
//
//  Created by yangjian on 2023/10/31.
//

import SwiftUI
import GADUtil
import Combine
import ComposableArchitecture

var appEnterbackground = false

struct CleanFeature: Reducer {
    @Dependency(\.continuousClock) var clock
    private enum CancelID { case timer }
    struct State: Equatable {
    }
    enum Action: Equatable {
        case dismiss
        case stop
        case start
        case checkLoadedAD
    }
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            switch action {
            case .start:
                GADUtil.share.load(.interstitial)
                let check = Timer.publish(every: 2, on: .main, in: .common).autoconnect().map { _ in
                    Action.checkLoadedAD
                }
                
                let publisher = Just(Action.dismiss).delay(for: 12.5, scheduler: DispatchQueue.main)
                return .publisher {
                    check.merge(with: publisher).eraseToAnyPublisher()
                }.cancellable(id: CancelID.timer)
            case .checkLoadedAD:
                let isLoaded = GADUtil.share.isLoaded(.interstitial)
                return .run { send in
                    if isLoaded, !appEnterbackground {
                        await send(.stop)
                        await GADUtil.share.show(.interstitial)
                        await send(.dismiss)
                    }
                }
            case .stop:
                return .cancel(id: CancelID.timer)
            default:
                break
            }
            return .none
        }
    }
}

struct CleanView: View {
    let store: StoreOf<CleanFeature>
    @State private var beigin = false
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack{
                Spacer()
                VStack {
                    ZStack{
                        Image(.cleanAnimationIcon).rotationEffect(.degrees(beigin ? 1080 : 0)).animation(.linear(duration: 12.5), value: beigin)
                        Image(.cleanIcon)
                    }
                    Text(verbatim: .cleanTitle).foregroundStyle(.black)
                }.padding(.bottom, 100)
                HStack{
                    Spacer()
                }
                Spacer()
            }.background.onAppear{
                beigin = true
            }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification), perform: { _ in
                viewStore.send(.stop)
                viewStore.send(.dismiss)
            })
        }
    }
}

extension String {
    static let cleanIcon = "clean_title"
    static let cleanAnimationIcon = "clean_animation"
    static let cleanTitle = "Cleaning..."
}

#Preview {
    CleanView(store: Store.init(initialState: CleanFeature.State(), reducer: {
        CleanFeature()
    }))
}
