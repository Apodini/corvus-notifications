import Corvus
import Fluent
import FluentSQLiteDriver
import XCTVapor
import Foundation
import corvus_notifications
import Vapor

final class NotificationsTest: CorvusNotificationsTests {

    override func setUpWithError() throws {
        try super.setUpWithError()

        let groupChatParameter = Parameter<GroupChat>().id

        let api = Api("api") {
            Group("groupchats") {
                Create<GroupChat>().notify()
                ReadOne<GroupChat>(groupChatParameter).notify()
                Update<GroupChat>(groupChatParameter).notify()
                Delete<GroupChat>(groupChatParameter).notify()
            }
        }

        try app.register(collection: api)
    }

    func testCreateNotification() throws {

        final class CreateNotificationTest: RestApi {
            var content: Endpoint {
                Group("api", "groupchats") {
                    Create<GroupChat>().notify()
                }
            }
        }

        let app = Application(.testing)
        defer { app.shutdown() }
        let createNotificationTest = CreateNotificationTest()
        app.databases.use( .sqlite(.memory), as: .init(string: "CorvusNotificationsTest"), isDefault: true
        )
        app.migrations.add(CreateGroupChat())
        try app.autoMigrate().wait()
        try app.register(collection: createNotificationTest)

        let groupChat = GroupChat(id: UUID(),
                                  recipients: ["salnvdv"],
                                  title: "Test Group",
                                  subtitle: "Welcome",
                                  body: "You were added")

        try app.testable()
            .test(
                .POST,
                "/api/groupchats",
                headers: ["content-type": "application/json"],
                body: groupChat.encode()
            ) { res in
                let content = try res.content.decode(GroupChat.self)
                XCTAssertEqual(content, groupChat)
            }
    }

    func testReadNotification() throws {
        final class ReadNotificationTest: RestApi {
            let groupChatParameter = Parameter<GroupChat>().id

            var content: Endpoint {
                Group("api", "groupchats") {
                    ReadOne<GroupChat>(groupChatParameter).notify()
                }
            }
        }

        let app = Application(.testing)
        defer { app.shutdown() }
        let readNotificationTest = ReadNotificationTest()
        app.databases.use( .sqlite(.memory), as: .init(string: "CorvusNotificationsTest"), isDefault: true
        )
        app.migrations.add(CreateGroupChat())
        try app.autoMigrate().wait()
        try app.register(collection: readNotificationTest)

        try app.testable()
            .test(
                .GET,
                "/api/groupchats") { res in
                let content = try res.content.decode(GroupChat.self)
                XCTAssertEqual(content, group1)
            }
    }

    func testUpdateNotification() throws {
        final class UpdateNotificationTest: RestApi {
            let groupChatParameter = Parameter<GroupChat>().id

            var content: Endpoint {
                Group("api", "groupchats") {
                    Update<GroupChat>(groupChatParameter).notify()
                }
            }
        }

        let app = Application(.testing)
        defer { app.shutdown() }
        let updateNotificationTest = UpdateNotificationTest()
        app.databases.use( .sqlite(.memory), as: .init(string: "CorvusNotificationsTest"), isDefault: true
        )
        app.migrations.add(CreateGroupChat())
        try app.autoMigrate().wait()
        try app.register(collection: updateNotificationTest)

        let groupChat = GroupChat(recipients: ["aornf3j"], title: "Update", subtitle: "Group was updated", body: "")

        try app.testable()
            .test(
                .PUT,
                "/api/groupchats/\(String(describing: group1.id))",
                headers: ["content-type": "application/json"],
                body: groupChat.encode()
            ).test(.GET, "/api/accounts/\(group1ID)") { res in
                let content = try res.content.decode(GroupChat.self)
                XCTAssertEqual(content, groupChat)
            }
    }

    func testDeleteNotification() throws {
        final class DeleteNotificationTest: RestApi {
            let groupChatParameter = Parameter<GroupChat>().id

            var content: Endpoint {
                Group("api", "groupchats") {
                    Delete<GroupChat>(groupChatParameter).notify()
                }
            }
        }

        let app = Application(.testing)
        defer { app.shutdown() }
        let deleteNotificationTest = DeleteNotificationTest()
        app.databases.use( .sqlite(.memory), as: .init(string: "CorvusNotificationsTest"), isDefault: true
        )
        app.migrations.add(CreateGroupChat())
        try app.autoMigrate().wait()
        try app.register(collection: deleteNotificationTest)

        let groupChat = GroupChat(recipients: ["aornf3j"], title: "Delete", subtitle: "Group was deleted", body: "")
        try groupChat.create(on: database()).wait()
        let groupChatId = try XCTUnwrap(groupChat.id)

        try app.testable()
            .test(.DELETE, "/api/groupChats/\(groupChatId)") { res in
                XCTAssertEqual(res.status, .ok)
            }
    }
}
