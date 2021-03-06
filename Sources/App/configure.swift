import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
///
/// https://docs.vapor.codes/3.0/getting-started/structure/#configureswift
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(DateMiddleware.self) // Adds `Date` header to responses
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    
    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
    
    let postgresDbConfig = PostgreSQLDatabaseConfig(hostname: hostname, username: username, database: databaseName, password: password)
    let database = PostgreSQLDatabase(config: postgresDbConfig)
    databases.add(database: database, as: .psql)
    
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Acronym.self, database: .psql)
    services.register(migrations)

}
