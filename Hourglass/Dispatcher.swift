typealias SideEffect = (State, Action) -> Void
typealias Dispatch = (Action) -> Void
typealias StateGetter = () -> State
typealias Dispatcher = (@escaping StateGetter) -> Dispatch
typealias Reducer = (State, Action) -> State
typealias HODispatcher = (
    Reducer,
    SideEffect) -> Dispatcher

func dispatcher(
    _ reducer: @escaping Reducer,
    storeChanged: @escaping SideEffect) ->
    Dispatcher {
    return { state in
        return { action in
            storeChanged(reducer(state(), action), action)
        }
    }
}
