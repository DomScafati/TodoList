import Vapor
import Fluent

final class Todo: Model, Content, @unchecked Sendable {
    
    static let schema = "todos"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "description")
    var description: String?
    
    @Field(key: "is_done")
    var isDone: Bool
    
    init(id: UUID? = nil,
         title: String,
         description: String? = nil,
         isDone: Bool) {
        self.id = id
        self.title = title
        self.description = description
        self.isDone = isDone
    }
    
    init() {}
}

struct CreateTodoDTO: Content {
    var title: String
    var description: String?
    var isDone: Bool
}

struct UpdateTodoDTO: Content {
    var title: String
    var description: String?
    var isDone: Bool
}
