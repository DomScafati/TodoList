import Vapor
import Foundation
import Fluent

func routes(_ app: Application) throws {
    
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    app.get("todos", ":id") { req async throws -> Todo in
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let todo = try await Todo.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        return todo
    }
    
    app.get("todos") { req async throws -> [Todo] in
        return try await Todo.query(on: req.db).all()
    }
    
    app.post("todos") { req async throws -> Todo in
        let input = try req.content.decode(CreateTodoDTO.self)
        let todo = Todo(title: input.title,
                        description: input.description,
                        isDone: input.isDone)
        try await todo.save(on: req.db)
        return todo
    }
    
    app.put("todos", ":id") { req async throws -> HTTPStatus in
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let todo = try await Todo.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        let input = try req.content.decode(UpdateTodoDTO.self)
        todo.title = input.title
        todo.isDone = input.isDone
        if let description = input.description {
            todo.description = description
        }
        try await todo.save(on: req.db)
        
        return .noContent
    }
    
    app.delete("todos", ":id") { req async throws -> HTTPStatus in
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let todo = try await Todo.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await todo.delete(on: req.db)
        
        return .noContent
    }
}
