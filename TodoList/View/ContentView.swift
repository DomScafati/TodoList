//
//  ContentView.swift
//  TodoList
//
//  Created by Dom S on 11/20/26.
//

import SwiftUI

struct ContentView: View {
    @State var viewModel = TodoViewModel()
    @State private var formMode: TodoFormMode?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.todos) { todo in
                        Button {
                            formMode = .edit(todo)
                        } label: {
                            TodoCardView(todo: todo)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .task {
                viewModel.getTodos()
            }
            .navigationTitle("Todos")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Todo", systemImage: "plus") {
                        formMode = .add
                    }
                }
            }
            .sheet(item: $formMode) { mode in
                TodoFormSheet(mode: mode) { title, description, isDone in
                    switch mode {
                    case .add:
                        viewModel.createTodo(title: title, description: description, isDone: isDone)
                    case .edit(let todo):
                        viewModel.updateTodo(id: todo.id, title: title, description: description, isDone: isDone)
                    }
                } onDelete: {
                    if case .edit(let todo) = mode {
                        viewModel.deleteTodo(id: todo.id)
                    }
                }
            }
            .alert("An Error Occurred",
                   isPresented: $viewModel.isShowingError,
                   presenting: viewModel.error) { _ in
                Button("OK") {}
            } message: { error in
                Text(error.localizedDescription)
            }
        }
    }
}

struct TodoCardView: View {
    let todo: Todo

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(todo.isDone ? Color.accentColor : Color.secondary)

            Text(todo.title)
                .font(.headline)
                .strikethrough(todo.isDone)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    ContentView()
}
