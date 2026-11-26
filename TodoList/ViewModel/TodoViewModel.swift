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
    var error: Error?
    var isShowingError: Bool {
        get { error != nil }
        set { if !newValue { error = nil } }
    }
    var todos: [Todo]
    let store = TodoStore()

    init(service: TodoServiceProtocol = TodoService(),
         todos: [Todo] = []) {
        self.service = service
        self.todos = todos
    }
    
    func getTodos() {
        Task {
            todos = await store.getAll()

            do {
                let fresh = try await service.fetchTodos()
                await store.replaceAll(with: fresh)
                todos = await store.getAll()
            } catch(let todoError) {
                error = todoError
            }
        }
    }
    
    func createTodo(title: String, description: String, isDone: Bool) {
        Task {
            do {
                let todo = try await service.createTodo(title: title,
                                                        description: description,
                                                        isDone: isDone)
                await store.add(element: todo)
                todos = await store.getAll()
            } catch(let todoError) {
                error = todoError
            }
        }
    }
    
    func updateTodo(id: UUID, title: String, description: String, isDone: Bool) {
        Task {
            do {
                try await service.updateTodo(id: id,
                                             title: title,
                                             description: description,
                                             isDone: isDone)
                let todo = Todo(id: id,
                                title: title,
                                description: description,
                                isDone: isDone)
                
                await store.update(element: todo)
                todos = await store.getAll()
            } catch(let todoError) {
                error = todoError
            }
        }
    }
    
    func deleteTodo(id: UUID) {
        Task {
            do {
                try await service.deleteTodo(id: id)
                await store.delete(at: id)
                todos = await store.getAll()
            } catch(let todoError) {
                error = todoError
            }
        }
    }
}
