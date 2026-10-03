#if canImport(SQLite3)
import Foundation
import SQLite3

struct SQLiteError: Error, CustomStringConvertible {
    let code: Int32
    let message: String
    var description: String { "SQLite error \(code): \(message)" }
}

private func transientDestructor() -> sqlite3_destructor_type {
    unsafeBitCast(-1, to: sqlite3_destructor_type.self)
}

/// Thin wrapper over the system SQLite. Not thread-safe by itself: own it from one actor.
final class SQLiteConnection {
    private var handle: OpaquePointer?
    private var cache: [String: SQLiteStatement] = [:]

    init(path: String, readOnly: Bool) throws {
        var database: OpaquePointer?
        let access = readOnly ? SQLITE_OPEN_READONLY : (SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE)
        let code = sqlite3_open_v2(path, &database, access | SQLITE_OPEN_FULLMUTEX, nil)
        guard code == SQLITE_OK, let database else {
            let message = database.map { String(cString: sqlite3_errmsg($0)) } ?? "cannot open database"
            sqlite3_close_v2(database)
            throw SQLiteError(code: code, message: message)
        }
        handle = database
    }

    deinit { close() }

    /// `close_v2` lets the connection finish closing even if a statement is still alive.
    func close() {
        cache.removeAll()
        sqlite3_close_v2(handle)
        handle = nil
    }

    func execute(_ sql: String) throws {
        var errorPointer: UnsafeMutablePointer<CChar>?
        let code = sqlite3_exec(handle, sql, nil, nil, &errorPointer)
        guard code == SQLITE_OK else {
            let message = errorPointer.map { String(cString: $0) } ?? "unknown error"
            sqlite3_free(errorPointer)
            throw SQLiteError(code: code, message: message)
        }
    }

    func prepare(_ sql: String) throws -> SQLiteStatement {
        guard let handle else { throw SQLiteError(code: SQLITE_MISUSE, message: "database is closed") }
        return try SQLiteStatement(database: handle, sql: sql)
    }

    /// Reused across calls. Callers must `reset()` after use so no read lock is held.
    func cached(_ sql: String) throws -> SQLiteStatement {
        if let statement = cache[sql] { return statement }
        let statement = try prepare(sql)
        cache[sql] = statement
        return statement
    }

    func userVersion() throws -> Int {
        let statement = try prepare("PRAGMA user_version")
        return try statement.step() ? (statement.int(0) ?? 0) : 0
    }
}

final class SQLiteStatement {
    private var statement: OpaquePointer?
    private let database: OpaquePointer

    init(database: OpaquePointer, sql: String) throws {
        self.database = database
        let code = sqlite3_prepare_v2(database, sql, -1, &statement, nil)
        guard code == SQLITE_OK else {
            throw SQLiteError(code: code, message: String(cString: sqlite3_errmsg(database)))
        }
    }

    deinit { sqlite3_finalize(statement) }

    func bind(_ index: Int32, text: String) throws {
        try check(sqlite3_bind_text(statement, index, text, -1, transientDestructor()))
    }

    func bind(_ index: Int32, int value: Int?) throws {
        if let value {
            try check(sqlite3_bind_int64(statement, index, Int64(value)))
        } else {
            try check(sqlite3_bind_null(statement, index))
        }
    }

    func bind(_ index: Int32, blob: Data) throws {
        try blob.withUnsafeBytes { buffer in
            try check(sqlite3_bind_blob(statement, index, buffer.baseAddress, Int32(buffer.count), transientDestructor()))
        }
    }

    /// `true` while a row is available.
    func step() throws -> Bool {
        switch sqlite3_step(statement) {
        case SQLITE_ROW: return true
        case SQLITE_DONE: return false
        case let code: throw SQLiteError(code: code, message: String(cString: sqlite3_errmsg(database)))
        }
    }

    func text(_ column: Int32) -> String? {
        sqlite3_column_text(statement, column).map { String(cString: $0) }
    }

    func int(_ column: Int32) -> Int? {
        sqlite3_column_type(statement, column) == SQLITE_NULL ? nil : Int(sqlite3_column_int64(statement, column))
    }

    func data(_ column: Int32) -> Data? {
        guard let bytes = sqlite3_column_blob(statement, column) else { return nil }
        return Data(bytes: bytes, count: Int(sqlite3_column_bytes(statement, column)))
    }

    func reset() {
        sqlite3_reset(statement)
        sqlite3_clear_bindings(statement)
    }

    private func check(_ code: Int32) throws {
        guard code == SQLITE_OK else {
            throw SQLiteError(code: code, message: String(cString: sqlite3_errmsg(database)))
        }
    }
}
#endif
