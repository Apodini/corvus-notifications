import Corvus
import Fluent
import Foundation
import corvus_notifications

final class GroupChat: CorvusModel, NotificationProtocol {

    static let schema = "groups"

    @ID
    var id: UUID? {
        didSet {
              if id != nil {
                  $id.exists = true
              }
          }
    }

    @Field(key: "recipients")
    var recipients: [String]

    @Field(key: "title")
    var title: String

    @Field(key: "subtitle")
    var subtitle: String

    @Field(key: "body")
    var body: String

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init(id: UUID? = nil, recipients: [String], title: String, subtitle: String, body: String) {
        self.id = id
        self.recipients = recipients
        self.title = title
        self.subtitle = subtitle
        self.body = body
    }

    init() {}
}

struct CreateGroupChat: Migration {

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(GroupChat.schema)
        .id()
        .field("recipients", .string, .required)
        .field("title", .string, .required)
        .field("subtitle", .string, .required)
        .field("body", .string, .required)
        .field("deleted_at", .date)
//        .field(
//            "user_id",
//            .uuid,
//            .references(CorvusUser.schema, .id, onDelete: .cascade)
//        )
        .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(GroupChat.schema).delete()
    }
}

extension GroupChat: Equatable {
    static func == (lhs: GroupChat, rhs: GroupChat) -> Bool {
        var result = lhs.title == rhs.title

        if let lhsId = lhs.id, let rhsId = rhs.id {
            result = result && lhsId == rhsId
        }

        return result
    }
}
