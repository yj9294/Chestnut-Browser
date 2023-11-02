//
//  HomeRootView.swift
//  ChestnusBrowser
//
//  Created by yangjian on 2023/10/27.
//

import SwiftUI
import Combine
import ComposableArchitecture
import UniformTypeIdentifiers

struct HomeRootFeature: Reducer {
    struct State: Equatable {
        @PresentationState var alert: AlertState<String>?
        @PresentationState var list: ListFeature.State?
        @PresentationState var settings: SettingsFeature.State?
        @PresentationState var share: ShareFeature.State?
        @PresentationState var privacy: PrivacyFeature.State?
        @PresentationState var cleanAlert: CleanAlertFeature.State?
        @PresentationState var clean: CleanFeature.State?

        var home: HomeFeature.State = .init()
        var items: IdentifiedArrayOf<HomeContentFeature.State> = [.init()]
    }
    
    enum Action: Equatable {
        case alertAction(PresentationAction<String>)
        case shareAction(PresentationAction<ShareFeature.Action>)
        case listAction(PresentationAction<ListFeature.Action>)
        case settingsAction(PresentationAction<SettingsFeature.Action>)
        case privacyAction(PresentationAction<PrivacyFeature.Action>)
        case cleanAlertAction(PresentationAction<CleanAlertFeature.Action>)
        case cleanAction(PresentationAction<CleanFeature.Action>)

        case home(HomeFeature.Action)
        
        case dismissCleanView
        
        case alert(String)
    }
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            switch action{
            case let .alert(message):
                state.alert = AlertState {
                    TextState(message)
                }
            case let .listAction(.presented(action)):
                switch action {
                case let .content(action):
                    switch action {
                    case .update:
                        state.update()
                    case .dismiss:
                        state.dismissListView()
                        return .run { send in
                            await send(.home(.content(.browser(.refresh(true)))))
                            await send(.listAction(.presented(.dismiss)))
                        }
                    default:
                        break
                    }
                case let.bottom(action):
                    switch action {
                    case .backButtonTapped:
                        state.dismissListView()
                        return .run { send in
                            await send(.listAction(.presented(.dismiss)))
                        }
                    default:
                        break
                    }
                default:
                    break
                }
            case let .settingsAction(.presented(action)):
                switch action {
                case .dismiss:
                    state.dismissSettingsView()
                case .newButtonTapped:
                    state.add()
                    state.update()
                    state.dismissSettingsView()
                case .copyButtonTapped:
                    UIPasteboard.general.setValue(state.home.search.text, forPasteboardType: UTType.plainText.identifier)
                    state.dismissSettingsView()
                    return .run { send in
                        await send(.alert(CAlertState.clean.message))
                    }
                case .shareButtonTapped:
                    state.dismissSettingsView()
                    state.presentShareView()
                case .rateButtonTapped:
                    state.dismissSettingsView()
                case .privacyButtonTapped:
                    state.dismissSettingsView()
                    state.presentPrivacyView(.privacy)
                case .termsButtonTapped:
                    state.dismissSettingsView()
                    state.presentPrivacyView(.terms)
                default:
                    break
                }
            case let .privacyAction(.presented(action)):
                switch action {
                case .dismiss:
                    state.dismissPrivacyView()
                }
            case let .cleanAlertAction(.presented(action)):
                switch action {
                case .dismiss:
                    state.dismissCleanAlert()
                case .confirmButtonTapped:
                    state.dismissCleanAlert()
                    state.presentCleanView()
                    return .run { send in
                        await send(.cleanAction(.presented(.start)))
                    }
                }
            case let .cleanAction(.presented(action)):
                switch action {
                case .dismiss:
                    let publisher = Just(Action.dismissCleanView).delay(for: 0.5, scheduler: DispatchQueue.main)
                    return .publisher{
                        publisher
                    }
                default:
                    break
                }
            case let .shareAction(.presented(action)):
                switch action {
                case .dismiss:
                    state.dismissShareView()
                }
            case let .home(action):
                switch action {
                case let .search(action):
                    switch action {
                    case .alert:
                        state.alert = AlertState {
                            TextState(CAlertState.search.message)
                        }
                    default:
                        break
                    }
                case let .bottom(action):
                    switch action {
                    case .listButtonTapped:
                        state.presentListView()
                    case .settingsButtonTapped:
                        state.presentSettingsView()
                    case .cleanButtonTapped:
                        state.presentCleanAlertView()
                    default:
                        break
                    }
                default:
                    break
                }
            case .dismissCleanView:
                state.dismissCleanView()
                state.items = [.init()]
                state.update()
            default:
                break
            }
            return .none
        }.ifLet(\.$list, action: /Action.listAction) {
            ListFeature()
        }.ifLet(\.$settings, action: /Action.settingsAction) {
            SettingsFeature()
        }.ifLet(\.$share, action: /Action.shareAction) {
            ShareFeature()
        }.ifLet(\.$privacy, action: /Action.privacyAction) {
            PrivacyFeature()
        }.ifLet(\.$clean, action: /Action.cleanAction) {
            CleanFeature()
        }.ifLet(\.$alert, action: /Action.alertAction)
        
        Scope.init(state: \.home, action: /Action.home) {
            HomeFeature()
        }
            
    }
}

extension HomeRootFeature.State {
    var presentation: SheetModifier.SheetPresentation {
        if list != nil {
            return .list
        } else if settings != nil {
            return .settings
        } else if share != nil {
            return .share
        } else if privacy != nil {
            return .privacy
        } else if clean != nil {
            return .clean
        } else if cleanAlert != nil {
            return .cleanAlert
        }
        return .list
    }
    fileprivate mutating func presentListView() {
        items = IdentifiedArray(uniqueElements: items.compactMap({
            if $0.isSelected {
                return home.content
            }
            return $0
        }))
        list = .init(content: .init(items: items))
    }
    
    fileprivate mutating func dismissListView() {
        list = nil
    }
    
    fileprivate mutating func update() {
        items = list?.content.items ?? items
        if let item = items.filter({$0.isSelected}).first {
            home.content = item
            home.bottom.count = items.count
            home.update()
        }
    }
    
    fileprivate mutating func presentSettingsView() {
        settings = .init()
    }
    
    fileprivate mutating func dismissSettingsView() {
        settings = nil
    }
    
    fileprivate mutating func presentShareView() {
        share = .init()
    }
    
    fileprivate mutating func dismissShareView() {
        share = nil
    }
    
    fileprivate mutating func presentPrivacyView(_ item: PrivacyFeature.State.Item) {
        privacy = .init(item: item)
    }
    
    fileprivate mutating func dismissPrivacyView() {
        privacy = nil
    }
    
    fileprivate mutating func presentCleanAlertView() {
        cleanAlert = .init()
    }
    
    fileprivate mutating func dismissCleanAlert() {
        cleanAlert = nil
    }
    
    fileprivate mutating func presentCleanView() {
        clean = .init()
    }
    
    fileprivate mutating func dismissCleanView() {
        clean = nil
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
    
}

enum CAlertState {
    case clean, copy, search
    var message: String {
        switch self {
        case .clean:
            return "Clean successfully."
        case .copy:
            return "Copy successfully."
        case .search:
            return "Please enter your search content."
        }
    }
}

struct HomeRootView: View {
    let store: StoreOf<HomeRootFeature>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack{
                HomeView.init(store: store.scope(state: \.home, action: HomeRootFeature.Action.home))
            }.sheetPresent(store: store, presentation: viewStore.presentation).alert(store: self.store.scope(state: \.$alert, action: { .alertAction($0)}))
        }
    }
}

#Preview {
    HomeRootView(store: Store.init(initialState: HomeRootFeature.State(), reducer: {
        HomeRootFeature()
    }))
}
