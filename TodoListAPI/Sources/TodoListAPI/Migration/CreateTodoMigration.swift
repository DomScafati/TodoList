//
//  CreateTodos.swift
//  TodoListAPI
//
//  Created by Dom S on 11/19/26.
//
import Fluent

struct CreateTodoMigration: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema("todos")
            .id()
            .field("title", .string, .required)
            .field("description", .string)
            .field("is_done", .bool, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("todos").delete()
    }
}
