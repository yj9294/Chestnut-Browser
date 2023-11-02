//
//  LaunchView.swift
//  ChestnusBrowser
//
//  Created by yangjian on 2023/10/27.
//

import SwiftUI
import GADUtil
import ComposableArchitecture

struct LaunchFeature: Reducer {
    @Dependency(\.continuousClock) var clock
    enum CancelID { case timer }
    struct State: Equatable {
        var onAppear = false
        var progress = 0.0
        var duration = 12.5
        var isPresentingAD = false
    }
    enum Action: Equatable {
        case start
        case stop
        case update
        case completion
        case checkLoadedAD
        case updateDuration
        case dismissAD
        case loadingNativeAD
    }
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            switch action {
            case .start:
                if state.onAppear {
                    return .none
                }
                if state.isPresentingAD {
                    return .none
                }
                state.onAppear = true
                state.progress = 0.0
                state.duration = 12.5
                return .run { send in
                    for await _ in clock.timer(interval: .milliseconds(10)) {
                        await send(.update)
                        await send(.checkLoadedAD)
                        await send(.loadingNativeAD)
                    }
                }.cancellable(id: CancelID.timer)
            case .stop:
                state.onAppear = false
                return .cancel(id: CancelID.timer)
            case .update:
                let progress = state.progress
                if progress >= 1.0 {
                    return .none
                }
                state.progress += 0.01 / state.duration
                if state.progress >= 1.0 {
                    state.progress = 1.0
                    state.isPresentingAD = true
                    return .run { send in
                        await GADUtil.share.show(.interstitial)
                        await send(.completion)
                    }
                }
            case .checkLoadedAD:
                let progress = state.progress
                if progress >= 1.0 {
                    return .none
                }
                return .run{ send in
                    do {
                        let _ = try await GADUtil.share.load(.interstitial)
                        if progress > 0.2 {
                            await send(.updateDuration)
                        }
                    } catch let err {
                        if (err as? GADPreloadError) != GADPreloadError.loading, progress > 0.2 {
                            await send(.updateDuration)
                        }
                    }
                }
            case .updateDuration:
                state.duration = 0.02
            case .dismissAD:
                state.onAppear = false
                state.isPresentingAD = false
                return .run { _ in
                    await  GADUtil.share.dismiss()
                }
            default:
                break
            }
            return .none
        }
    }
}


struct LaunchView: View {
    let store: StoreOf<LaunchFeature>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack{
                Image(.launchIcon).padding(.top, 132)
                Image(.launchTitle).padding(.top, 27)
                Spacer()
                HStack{
                    ProgressView(value: viewStore.progress)
                }.padding(.horizontal, 70).padding(.bottom, 40)
            }.background.onAppear{
                viewStore.send(.start)
            }.onDisappear {
                viewStore.send(.stop)
            }
        }
    }
}


#Preview {
    LaunchView(store: Store(initialState: LaunchFeature.State(), reducer: {
        LaunchFeature()
    }))
}

extension String {
    static let launchIcon = "launch_icon"
    static let launchTitleIcon = "launch_title"
}
