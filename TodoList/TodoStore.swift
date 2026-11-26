//
//  TodoStore.swift
//  TodoList
//
//  Created by Dom S on 11/26/26.
//

import Foundation

protocol Storable {
    associatedtype Item
    func getAll() async -> [Item]
    func get(at id: UUID) async -> Item?
    func add(element: Item) async
    func delete(at id: UUID) async
    func replaceAll(with elements: [Item]) async
    func update(element: Item) async
}

actor TodoStore: Storable {
    typealias Item = Todo
    private var store: [Todo] = []

    func getAll() async -> [Todo] {
        return store
    }
    
    func get(at id: UUID) async -> Todo? {
        for todo in store {
            if todo.id == id {
                return todo
            }
        }
        
        return nil
    }
    
    func add(element: Todo) async {
        store.append(element)
    }
    
    func delete(at id: UUID) async {
        guard let index = store.lastIndex(where: { $0.id == id }) else {
            return
        }
        
        store.remove(at: index)
    }
    
    func replaceAll(with elements: [Todo]) async {
        store = elements
    }
    
    func update(element: Todo) async {
        guard let index = store.firstIndex(where: { $0.id == element.id } ) else {
            return
        }
        
        store[index] = element
    }
    
}
