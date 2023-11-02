//
//  ContentView.swift
//  ChestnusBrowser
//
//  Created by yangjian on 2023/10/27.
//

import SwiftUI
import GADUtil
import Combine
import ComposableArchitecture

struct AppFeature: Reducer {
    struct State: Equatable {
        var isLaunch = true
        
        var launch: LaunchFeature.State = .init()
        var homeRoot: HomeRootFeature.State = .init()
        var homeImpressionDate: Date = .init(timeIntervalSinceNow: -11)
        var listImpressionDate: Date = .init(timeIntervalSinceNow: -11)
        var isAllowImpressionHome: Bool {
            if Date().timeIntervalSince(homeImpressionDate) <= 10 {
                debugPrint("[ad] home native ad 间隔小于10秒 ")
                return false
            } else {
                return true
            }
        }
        
        var isAllowImpressionList: Bool {
            if Date().timeIntervalSince(listImpressionDate) <= 10 {
                debugPrint("[ad] list native ad 间隔小于10秒 ")
                return false
            } else {
                return true
            }
        }
    }
    
    enum Action: Equatable {
        case launch(LaunchFeature.Action)
        case homeRoot(HomeRootFeature.Action)
        case willEnterForground
        
        case loadingAD(GADShowPosition = .home)
        case cleanAD
        case updateAD(GADNativeViewModel?, GADShowPosition = .home)
    }
    
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            switch action {
            case .willEnterForground:
                state.isLaunch = true
            case let .launch(action):
                switch action {
                case .completion:
                    if state.launch.progress >= 1.0 {
                        state.isLaunch = false
                    }
                case .loadingNativeAD:
                    return .run { send in
                        await send(.loadingAD(.home))
                    }
                default:
                    break
                }
            case let .homeRoot(action):
                switch action {
                case let .home(.bottom(action)):
                    switch action {
                    case .listButtonTapped:
                        return .run { send in
                            await send(.cleanAD)
                            await send(.loadingAD(.list))
                        }
                    default:
                        break
                    }
                case let .listAction(.presented(action)):
                    switch action {
                    case .dismiss:
                        return .run { send in
                            await send(.cleanAD)
                            await send(.loadingAD(.home))
                        }
                    default:
                        break
                    }
                case let .privacyAction(.presented(action)):
                    switch action {
                    case .dismiss:
                        return .run { send in
                            await send(.cleanAD)
                            await send(.loadingAD(.home))
                        }
                    }
                case let .cleanAlertAction(.presented(action)):
                    switch action {
                    case .confirmButtonTapped:
                        return .run { send in
                            await send(.cleanAD)
                        }
                    default:
                        break
                    }
                case let .cleanAction(.presented(action)):
                    switch action {
                    case .dismiss:
                        let publisher = Just(Action.loadingAD(.home)).delay(for: 0.5, scheduler: DispatchQueue.main)
                        return .publisher {
                            publisher
                        }
                    default:
                        break
                    }
                default:
                    break
                }
            case let .loadingAD(postion):
                return .run { send in
                    do {
                        _ = try await GADUtil.share.load(.native)
                        let model = await GADUtil.share.show(.native) as? GADNativeModel
                        await send(.updateAD(.init(model: model), postion))
                    } catch let err {
                        if (err as? GADPreloadError) != .loading {
                            await send(.updateAD(nil, postion))
                        }
                    }
                }
            case let .updateAD(model, postion):
                if let model = model, postion == .home {
                    if state.isAllowImpressionHome {
                        state.homeRoot.home.content.ad = model
                        state.homeImpressionDate = Date()
                    }
                } else if let model = model, postion == .list {
                    if state.isAllowImpressionList {
                        state.homeRoot.list?.ad = model
                        state.listImpressionDate = Date()
                    }
                } else {
                    state.homeRoot.home.content.ad = .none
                    state.homeRoot.list?.ad = .none
                }
                
            case .cleanAD:
                GADUtil.share.disappear(.native)
                return .run{ send in
                    await send(.updateAD(nil))
                }
            }
            return .none
        }
        
        Scope.init(state: \.launch, action: /Action.launch) {
            LaunchFeature()
        }
        Scope.init(state: \.homeRoot, action: /Action.homeRoot) {
            HomeRootFeature()
        }
    }
}


enum GADShowPosition {
    case home, list
}

struct AppView: View {
    let store: StoreOf<AppFeature>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack{
                if viewStore.isLaunch {
                    LaunchView(store: store.scope(state: \.launch, action: AppFeature.Action.launch))
                } else {
                    HomeRootView(store: store.scope(state: \.homeRoot, action: AppFeature.Action.homeRoot))
                }
            }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: { _ in
                appEnterbackground = false
                viewStore.send(.launch(.dismissAD))
                viewStore.send(.willEnterForground)
            }).onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification), perform: { _ in
                appEnterbackground = true
            }).onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification), perform: { _ in
                appEnterbackground = true
            })
        }
    }
}


#Preview {
    AppView(store: Store.init(initialState: AppFeature.State(), reducer: {
        AppFeature()
    }))
}
