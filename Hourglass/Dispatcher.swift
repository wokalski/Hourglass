typealias SideEffect = (state: State, action: Action) -> Void
typealias Dispatch = (action: Action) -> Void
typealias StateGetter = () -> State
typealias Dispatcher = (state: StateGetter) -> Dispatch
typealias Reducer = (State, Action) -> State
typealias HODispatcher = (
    reducer: Reducer,
    storeChanged: SideEffect) -> Dispatcher

func dispatcher(
    reducer: Reducer,
    storeChanged: SideEffect) ->
    Dispatcher {
    return { state in
        return { action in
            storeChanged(state: reducer(state(), action), action: action)
        }
    }
}
