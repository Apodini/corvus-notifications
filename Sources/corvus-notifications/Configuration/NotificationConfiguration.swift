import Foundation
import Vapor
import Fluent
import Corvus
import APNSwift
import NIO
import NIOHTTP1
import NIOHTTP2
import NIOSSL

extension Application {
    var configuration: NotificationSettings? {
        get {
            self.storage[NotificationSettingsKey.self]
        }
        set {
            self.storage[NotificationSettingsKey.self] = newValue
        }
    }
}

struct NotificationSettings {
    let filePathToAuthKey: String
    let teamIdentifier: String
    let keyIdentifier: String
    let topic: String

    init(filePathToAuthKey: String, teamIdentifier: String, keyIdentifier: String, topic: String) {
        self.filePathToAuthKey = filePathToAuthKey
        self.teamIdentifier = teamIdentifier
        self.keyIdentifier = keyIdentifier
        self.topic = topic
    }

    func sendNotification<T: NotificationProtocol>(message: T) throws {
        let apnsConfig = try APNSwiftConfiguration(
            authenticationMethod: .jwt(
                key: .private(filePath: self.filePathToAuthKey),
                keyIdentifier: .init(string: self.keyIdentifier),
                teamIdentifier: self.teamIdentifier
            ),
            topic: self.topic,
            environment: .sandbox
            )

        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let alert = APNSwiftPayload.APNSwiftAlert(title: message.title,
                                                  subtitle: message.subtitle,
                                                  body: message.body)
        let aps = APNSwiftPayload(alert: alert, badge: 0, sound: .none, hasContentAvailable: true)
        let notification = AcmeNotification(aps: aps)

        _ = try APNSwiftConnection.connect(configuration: apnsConfig,
                                           on: group.next()).flatMapThrowing { (connection: APNSwiftConnection) in
            do {
                let expiry = Date().addingTimeInterval(5)
                for recipient in message.recipients {
                    _ = try connection.send(notification,
                                            pushType: .alert,
                                            to: recipient,
                                            expiration: expiry,
                                            priority: 10).flatMapThrowing {
                           _ = try connection.close().flatMapThrowing {
                               //try group.syncShutdownGracefully()
                               //exit(0)
                           }
                       }
                }
            } catch {
                throw error
            }
        }
    }
}

struct NotificationSettingsKey: StorageKey {
    typealias Value = NotificationSettings
}

extension Request {
    func sendNotification<T: NotificationProtocol>(message: T) throws {
        try self.application.configuration?.sendNotification(message: message)
    }
}

struct AcmeNotification: APNSwiftNotification {

    var aps: APNSwiftPayload

    init(aps: APNSwiftPayload) {
        self.aps = aps
    }
}
