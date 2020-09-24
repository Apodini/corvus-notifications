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
                ReadAll<GroupChat>()
                Group(groupChatParameter) {
                    ReadOne<GroupChat>(groupChatParameter).notify()
                    Update<GroupChat>(groupChatParameter).notify()
                    Delete<GroupChat>(groupChatParameter).notify()
                }
            }
        }

        try app.register(collection: api)
    }

    func testCreateNotification() throws {
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
        let groupChat = GroupChat(recipients: ["aornf3j"], title: "Delete", subtitle: "Group was deleted", body: "")
        try groupChat.create(on: database()).wait()
        let gID = try XCTUnwrap(groupChat.id)

        try app.testable()
            .test(
                .GET,
                "/api/groupchats/\(gID)",
                headers: ["content-type": "application/json"],
                body: groupChat.encode())
            { res in
                    let content = try res.content.decode(GroupChat.self)
                    XCTAssertEqual(content, groupChat)
            }
        }

    func testUpdateNotification() throws {
            let groupChat = GroupChat(recipients: ["aornf3j"], title: "Delete", subtitle: "Group was deleted", body: "")
            try groupChat.create(on: database()).wait()
            let gID = try XCTUnwrap(groupChat.id)

            let update = GroupChat(recipients: ["aorne3j"], title: "Delte", subtitle: "Grop was deleted", body: "sdf")

            try app.testable()
            .test(
                .PUT,
                "/api/groupchats/\(gID)",
                headers: ["content-type": "application/json"],
                body: update.encode()
            )
            .test(
            .GET,
            "/api/groupchats/\(gID)",
            headers: ["content-type": "application/json"],
            body: groupChat.encode()
                )
            { res in
                let content = try res.content.decode(GroupChat.self)
                XCTAssertEqual(content, update)
            }
    }

    func testDeleteNotification() throws {
        let groupChat = GroupChat(recipients: ["aornf3j"], title: "Delete", subtitle: "Group was deleted", body: "")
        try groupChat.create(on: database()).wait()
        let groupChatId = try XCTUnwrap(groupChat.id)

        try app.testable()
            .test(.DELETE, "/api/groupchats/\(groupChatId)",
                headers: ["content-type": "application/json"],
                body: groupChat.encode()
            ) { res in
                XCTAssertEqual(res.status, .ok)
            }
    }
}
