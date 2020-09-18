import Foundation
import Vapor
import Fluent
import Corvus

/// A class that wraps a component which utilizes a `.notify()` modifier. That
/// allows Corvus to chain modifiers, as it gets treated as any other struct
/// conforming to `CreateEndpoint`. Requires an object `A` that represents the
/// message to send.
public final class CreateNotificationModifier<
    A: CreateEndpoint>:
CreateEndpoint, RestEndpointModifier where A.QuerySubject: NotificationProtocol {

    /// The return type for the `.handler()` modifier.
    public typealias Element = A.Element

    /// The return value of the `.query()`, so the type being operated on in
    /// the current component.
    public typealias QuerySubject = A.QuerySubject

    /// The instance of `Endpoint` the `CreateNotificationModifier` is modifying.
    public let modifiedEndpoint: A

    /// Initializes the modifier with its underlying `QueryEndpoint`
    ///
    /// - Parameter notificationEndpoint: The `QueryEndpoint` to which the modifer is attached.
    public init(_ notificationEndpoint: A) {
        self.modifiedEndpoint = notificationEndpoint
    }

    /// A default implementation of `.query()` for components that do not
    /// require customized database queries.
    ///
    /// - Parameter req: The incoming `Request`.
    /// - Throws: An error if something goes wrong.
    /// - Returns: A `QueryBuilder` object for further querying.
    public func query(_ req: Request) throws -> QueryBuilder<QuerySubject> {
        try modifiedEndpoint.query(req)
    }

    /// A method which sends the message supplied in the `Request`as a push notification.
    ///
    /// - Parameter req: An incoming `Request`.
    /// - Throws: An error if something goes wrong.
    /// - Returns: An `EventLoopFuture` containing an eagerloaded value as
    /// defined by `Element`.
    public func handler(_ req: Request) throws -> EventLoopFuture<Element> {
        let requestContent = try req.content.decode(A.QuerySubject.self)
        try req.sendNotification(message: requestContent)
        return try modifiedEndpoint.handler(req)
    }
}

/// An extension that adds the `.notify()` modifier to components conforming to
/// `NotificationProtocol`.
extension CreateEndpoint where QuerySubject: NotificationProtocol {

    public func notify() -> CreateNotificationModifier<Self> {
        CreateNotificationModifier(self)
    }
}
