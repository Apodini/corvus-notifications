import Foundation
import Corvus

/// A protocol  used to provide a common interface for `CorvusModel`
/// components so they can access their own `.notify` modifier.
public protocol NotificationProtocol: CorvusModel {

    /// The recipients of a notification, identified by their device tokens.
    var recipients: [String] { get set }

    /// The title of a notification, which will be displayed as the first line.
    var title: String { get set }

    /// The subtitle of a notification, which will be displayed as the second line.
    var subtitle: String { get set }

    /// The body of a notification, which will be displayed as the last line.
    var body: String { get set }
}
