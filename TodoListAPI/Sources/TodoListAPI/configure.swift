import Vapor
import Fluent
import FluentSQLiteDriver

/// configures your application
func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // register routes
    app.databases.use(
        .sqlite(
            .file("db.sqlite")),
        as: .sqlite)
    
    app.migrations.add(CreateTodoMigration())
    try await app.autoMigrate()
    
    try routes(app)
}
