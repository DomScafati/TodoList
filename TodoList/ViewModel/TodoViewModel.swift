//
//  TodoViewModel.swift
//  TodoList
//
//  Created by Dom S on 11/23/26.
//

import Foundation

@Observable
final class TodoViewModel {
    private let service: TodoServiceProtocol
    var todos: [Todo]

    init(service: TodoServiceProtocol = TodoService(),
         todos: [Todo] = []) {
        self.service = service
        self.todos = todos
    }
    
    func getTodos() {
        Task {
            do {
                todos = try await service.fetchTodos()
            } catch {
                print(error)
            }
        }
    }
    
    func createTodo(title: String, description: String, isDone: Bool) {
        Task {
            do {
                _ = try await service.createTodo(title: title, description: description, isDone: isDone)
                todos = try await service.fetchTodos()
            } catch {
                print(error)
            }
        }
    }
    
    func updateTodo(id: UUID, title: String, description: String, isDone: Bool) {
        Task {
            do {
                try await service.updateTodo(id: id, title: title, description: description, isDone: isDone)
                todos = try await service.fetchTodos()
            } catch {
                print(error)
            }
        }
    }
    
    func deleteTodo(id: UUID) {
        Task {
            do {
                try await service.deleteTodo(id: id)
                todos.removeAll { $0.id == id }
            } catch {
                print(error)
            }
        }
    }
}
