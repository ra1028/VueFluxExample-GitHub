extension Signal {
    func filter(_ isIncluded: @escaping (Value) -> Bool) -> Signal<Value> {
        return .init { send in
            self.observe { value in
                if isIncluded(value) {
                    send(value)
                }
            }
        }
    }
    
    func combinePrevious(initial: Value? = nil) -> Signal<(Value, Value)> {
        return .init { send in
            var previousValue = initial
            
            return self.observe { value in
                if let previousValue = previousValue {
                    send((previousValue, value))
                }
                previousValue = value
            }
        }
    }
}
