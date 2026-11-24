# TodoList

A simple todo app: a SwiftUI iOS client and a Vapor backend it talks to.

## Repository layout

```
TodoList.xcodeproj     Xcode project for the iOS app
TodoList/              App source
TodoListTests/         Unit test target
TodoListUITests/       UI test target
TodoListAPI/           Vapor backend (Swift package)
```

## Running it

Start the API first, then the app.

1. Start the backend:
   ```bash
   cd TodoListAPI
   swift run
   ```
   It listens on `http://localhost:8080`. On first launch it creates `db.sqlite` in the folder you ran it from.
2. Open `TodoList.xcodeproj` in Xcode and run the `TodoList` scheme on an iPhone simulator.

The app calls `http://localhost:8080` (set in `TodoList/TodoService.swift`). That works from the simulator. On a physical device, point it at your Mac's address instead.

## iOS app (`TodoList/`)

SwiftUI with an MVVM layout. Requires iOS 26.2 or later.

- Todos show as cards in a `LazyVStack`.
- The plus button opens a sheet to add a todo: title, description and a completed toggle.
- Tapping a card opens the same sheet in edit mode, with a Delete button that asks for confirmation.

| Path | Role |
| --- | --- |
| `Model/Todo.swift` | `Todo` and the `CreateTodo` request body |
| `TodoService.swift` | Networking against the API (fetch, create, update, delete) |
| `ViewModel/TodoViewModel.swift` | Holds the list of todos and the actions the views call |
| `View/ContentView.swift` | The list screen and the todo card |
| `View/TodoFormSheet.swift` | The add/edit sheet (`TodoFormMode`: `.add` or `.edit`) |
| `View/TodoListApp.swift` | App entry point |

## API (`TodoListAPI/`)

A [Vapor](https://vapor.codes) service using Fluent with SQLite. Swift 6.2 toolchain, macOS 13 or later.

```bash
swift build      # build
swift run        # run on port 8080
swift test       # run tests
```

Docker files are included for a production-like run:

```bash
docker compose build
docker compose up app
```

### Endpoints

| Method | Path | Body | Response |
| --- | --- | --- | --- |
| GET | `/todos` | | `200` list of todos |
| GET | `/todos/:id` | | `200` one todo, `404` if missing |
| POST | `/todos` | `title`, `isDone`, optional `description` | `200` the saved todo |
| PUT | `/todos/:id` | `title`, `isDone`, optional `description` | `204`, `404` if missing |
| DELETE | `/todos/:id` | | `204`, `404` if missing |

`:id` is a UUID. On PUT, `description` is only changed when it's included in the body.

A todo looks like this (`description` may be missing):

```json
{
  "id": "6F1C0E52-3B7A-4C1D-9E0A-5D2B8A4F7C13",
  "title": "Buy groceries",
  "description": "Milk and eggs",
  "isDone": false
}
```

### Database

The schema is created by `CreateTodoMigration` when the server starts. `db.sqlite` is not committed. During early development it's safe to delete it. If you change the migration, delete it so the server rebuilds the table.
