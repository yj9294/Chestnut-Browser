//
//  HomeBottomView.swift
//  ChestnusBrowser
//
//  Created by yangjian on 2023/10/27.
//

import SwiftUI
import ComposableArchitecture

struct HomeBottomFeature: Reducer {
    struct State: Equatable {
        var count: Int = 1
        var canGoBack: Bool = false
        var canGoForward: Bool = false
    }
    enum Action: Equatable {
        case backButtonTapped
        case forwardButtonTapped
        case cleanButtonTapped
        case listButtonTapped
        case settingsButtonTapped
        case itemButtonTapped(State.Item)
    }
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            switch action {
            case let .itemButtonTapped(item):
                switch item {
                case .back:
                    return .run{ send in
                        await send(.backButtonTapped)
                    }
                case .forward:
                    return .run{ send in
                        await send(.forwardButtonTapped)
                    }
                case .clean:
                    return .run{ send in
                        await send(.cleanButtonTapped)
                    }
                case .list:
                    return .run{ send in
                        await send(.listButtonTapped)
                    }
                case .settings:
                    return .run{ send in
                        await send(.settingsButtonTapped)
                    }
                }
            default:
                break
            }
            return .none
        }
    }
}

extension HomeBottomFeature.State {
    var items: [Item] {
        [.back(canGoBack), .forward(canGoForward), .clean, .list(count), .settings]
    }
    enum Item: Equatable, Hashable {
        case back(Bool), forward(Bool), clean, list(Int), settings
        var title: String {
            switch self {
            case .back:
                return "back"
            case .forward:
                return "forward"
            case .clean:
                return "clean"
            case .settings:
                return "settings"
            case .list:
                return "list"
            }
        }
        var icon: String {
            "home_\(self.title)"
        }
    }
}

struct HomeBottomView: View {
    let store: StoreOf<HomeBottomFeature>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            LazyHGrid(rows: [GridItem(.flexible())]) {
                ForEach(viewStore.items, id:\.self) { item in
                    Button(action: {
                        viewStore.send(.itemButtonTapped(item))
                    }, label: {
                        getItem(item)
                    })
                }
            }.frame(height: 65)
        }
    }
    
    func getItem(_ item: HomeBottomFeature.State.Item) -> some View {
        VStack{
            switch item {
            case .back(let canGoBack):
                Image(item.icon).opacity(canGoBack ? 1.0 : 0.5)
            case .forward(let canGoBack):
                Image(item.icon).opacity(canGoBack ? 1.0 : 0.5)
            case .list(let count):
                ZStack{
                    Image(item.icon)
                    Text("\(count)").font(.system(size: 13, weight: .medium))
                }.foregroundColor(.black)
            default:
                Image(item.icon)
            }
        }.padding()
    }
}

#Preview {
    HomeBottomView(store: Store.init(initialState: HomeBottomFeature.State(), reducer: {
        HomeBottomFeature()
    }))
}
