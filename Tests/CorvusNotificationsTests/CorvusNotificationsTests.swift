import Corvus
import XCTVapor
import Fluent
import corvus_notifications

class CorvusNotificationsTests: XCTestCase {

    let app = Application(.testing)
    var group1 = GroupChat(recipients: ["scjk1wf"], title: "iOS Fans", subtitle: "Welcome", body: "You were added")
    var group1ID = UUID()

    override func setUpWithError() throws {
        try super.setUpWithError()

        app.databases.use(
            .sqlite(.memory),
            as: .init(string: "CorvusNotificationsTest"),
            isDefault: true
        )

        app.migrations.add(
            CreateGroupChat()
        )

        try app.autoMigrate().wait()
        try group1.create(on: database()).wait()
        group1ID = try XCTUnwrap(group1.id)
        let group1body = try XCTUnwrap(group1.body)
    }

    override func tearDownWithError() throws {
        let app = try XCTUnwrap(self.app)
        app.shutdown()
    }

    func tester() throws -> XCTApplicationTester {
        try XCTUnwrap(app.testable())
    }

    func database() throws -> Database {
        try XCTUnwrap(self.app.db)
    }
}
