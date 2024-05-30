import Combine
import Foundation

/// A composite cancellable object that can manage multiple cancellable subscriptions.
class CompositeCancellable: Cancellable {
    
    /// The collection of cancellable subscriptions.
    private var cancellables = [AnyCancellable]()
    
    /// Cancels all the cancellable subscriptions.
    func cancel() {
        cancellables.forEach { $0.cancel() }
    }
    
    /// Adds a cancellable subscription to the composite cancellable.
    ///
    /// - Parameters:
    ///   - lhs: The composite cancellable to which the subscription will be added.
    ///   - rhs: The cancellable subscription to be added.
    static func +=(lhs: CompositeCancellable, rhs: AnyCancellable) {
        lhs.cancellables.append(rhs)
    }
    
}

extension Publisher where Self.Failure == Never {
    
    /// Subscribes to the publisher and handles the received values and completion on the main dispatch queue.
    func sinkOnMain(receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) -> Void), receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        return receive(on: DispatchQueue.main).sink(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
    }
    
    /// Subscribes to the publisher and handles the received values on the main dispatch queue.
    func sinkOnMain(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        return receive(on: DispatchQueue.main).sink(receiveValue: receiveValue)
    }

}
