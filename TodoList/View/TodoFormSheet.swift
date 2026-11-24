//
//  TodoFormSheet.swift
//  TodoList
//

import SwiftUI

enum TodoFormMode: Identifiable {
    case add
    case edit(Todo)

    var id: String {
        switch self {
        case .add: "add"
        case .edit(let todo): todo.id.uuidString
        }
    }
}

struct TodoFormSheet: View {
    @Environment(\.dismiss) private var dismiss

    let mode: TodoFormMode
    var onSave: (_ title: String, _ description: String, _ isDone: Bool) -> Void
    var onDelete: () -> Void

    @State private var title: String
    @State private var descriptionText: String
    @State private var isDone: Bool
    @State private var isConfirmingDelete = false
    @FocusState private var titleFocused: Bool

    init(mode: TodoFormMode,
         onSave: @escaping (_ title: String, _ description: String, _ isDone: Bool) -> Void,
         onDelete: @escaping () -> Void = {}) {
        self.mode = mode
        self.onSave = onSave
        self.onDelete = onDelete

        switch mode {
        case .add:
            _title = State(initialValue: "")
            _descriptionText = State(initialValue: "")
            _isDone = State(initialValue: false)
        case .edit(let todo):
            _title = State(initialValue: todo.title)
            _descriptionText = State(initialValue: todo.description ?? "")
            _isDone = State(initialValue: todo.isDone)
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                        .focused($titleFocused)
                    TextField("Description", text: $descriptionText, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Toggle("Completed", isOn: $isDone)
                }

                if isEditing {
                    Section {
                        Button("Delete Todo", role: .destructive) {
                            isConfirmingDelete = true
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Todo" : "New Todo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add", action: save)
                        .disabled(trimmedTitle.isEmpty)
                }
            }
            .alert("Delete this todo?", isPresented: $isConfirmingDelete) {
                Button("Delete", role: .destructive) {
                    onDelete()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This can't be undone.")
            }
            .onAppear {
                if !isEditing { titleFocused = true }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func save() {
        guard !trimmedTitle.isEmpty else { return }
        onSave(trimmedTitle, descriptionText, isDone)
        dismiss()
    }
}
