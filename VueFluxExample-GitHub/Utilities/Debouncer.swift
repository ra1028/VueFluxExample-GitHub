import Foundation

final class Debouncer {
    private let queue: DispatchQueue
    
    private var currentWorkItem: DispatchWorkItem? {
        didSet { oldValue?.cancel() }
    }
    
    private var pendingWorkItem: DispatchWorkItem? {
        didSet { oldValue?.cancel() }
    }
    
    deinit {
        currentWorkItem?.cancel()
    }
    
    init(on queue: DispatchQueue) {
        self.queue = queue
    }
    
    func debounce(interval: TimeInterval, _ execute: @escaping () -> Void) {
        let workItem = DispatchWorkItem(block: execute)
        currentWorkItem = workItem
        pendingWorkItem = nil
        queue.asyncAfter(deadline: .now() + interval, execute: workItem)
    }
}
