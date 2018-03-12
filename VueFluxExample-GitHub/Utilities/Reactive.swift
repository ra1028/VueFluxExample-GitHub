protocol ReactiveCompatible: class {}

extension ReactiveCompatible {
    var reactive: Reactive<Self> {
        return Reactive(self)
    }
    
    static var reactive: Reactive<Self>.Type {
        return Reactive<Self>.self
    }
}

struct Reactive<Base> {
    let base: Base
    
    fileprivate init(_ base: Base) {
        self.base = base
    }
}
