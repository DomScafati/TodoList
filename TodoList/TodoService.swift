//
//  TodoService.swift
//  TodoList
//
//  Created by Dom S on 11/23/26.
//

import Foundation

enum TodoError: LocalizedError {
    case invalidURL
    case decodingFailed
    case badStatus
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL: "The server address is invalid."
        case .decodingFailed: "The server sent data the app couldn't read."
        case .badStatus: "The server couldn't complete the request."
        case .unknown: "Something went wrong."
        }
    }
}

protocol TodoServiceProtocol {
    func fetchTodos() async throws -> [Todo]
    func createTodo(title: String, description: String, isDone: Bool) async throws -> Todo
    func updateTodo(id: UUID, title: String, description: String, isDone: Bool) async throws
    func deleteTodo(id: UUID) async throws
}

struct TodoService: TodoServiceProtocol {
    
    let baseURLString = "http://localhost:8080"
    let urlEndpointString = "/todos"
    
    func fetchTodos() async throws -> [Todo] {
        guard let url = URL(string: baseURLString + urlEndpointString) else {
            throw TodoError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpURLResponse = response as? HTTPURLResponse,
              (200...299).contains(httpURLResponse.statusCode) else {
            throw TodoError.badStatus
        }
        
        guard let todos = try? JSONDecoder().decode([Todo].self, from: data) else {
            throw TodoError.decodingFailed
        }
        
        return todos
    }
    
    func createTodo(title: String, description: String, isDone: Bool) async throws -> Todo {
        guard let url = URL(string: baseURLString + urlEndpointString) else {
            throw TodoError.invalidURL
        }
        let createTodo = CreateTodo(title: title, description: description, isDone: isDone)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(createTodo)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpURLResponse = response as? HTTPURLResponse,
              (200...299).contains(httpURLResponse.statusCode) else {
            throw TodoError.badStatus
        }
        
        
        guard let todo = try? JSONDecoder().decode(Todo.self, from: data) else {
            throw TodoError.decodingFailed
        }
        
        return todo
    }

    func updateTodo(id: UUID, title: String, description: String, isDone: Bool) async throws {
        guard let url = URL(string: baseURLString + urlEndpointString + "/\(id.uuidString)") else {
            throw TodoError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(CreateTodo(title: title, description: description, isDone: isDone))

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpURLResponse = response as? HTTPURLResponse,
              (200...299).contains(httpURLResponse.statusCode) else {
            throw TodoError.badStatus
        }
    }

    func deleteTodo(id: UUID) async throws {
        guard let url = URL(string: baseURLString + urlEndpointString + "/\(id.uuidString)") else {
            throw TodoError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpURLResponse = response as? HTTPURLResponse,
              (200...299).contains(httpURLResponse.statusCode) else {
            throw TodoError.badStatus
        }
    }

}
