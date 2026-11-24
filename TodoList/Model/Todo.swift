//
//  Todo.swift
//  TodoList
//
//  Created by Dom S on 11/20/26.
//

import Foundation

struct Todo: Codable, Identifiable {
    let id: UUID
    var title: String
    var description: String?
    var isDone: Bool
}

struct CreateTodo: Encodable {
    let title: String
    let description: String?
    let isDone: Bool
}
