import JavaScriptCore

@available(macOS 10.15, iOS 13, tvOS 13, *)
/// A formatter that pretty prints source code in various languages.
public class PrettierFormatter {
  static let prettier = Bundle.module.path(forResource: "standalone", ofType: "js")!
  static let babel = Bundle.module.path(forResource: "babel", ofType: "js")!
  static let estree = Bundle.module.path(forResource: "estree", ofType: "js")!
  static let sqlPlugin = Bundle.module.path(forResource: "sql-plugin-standalone", ofType: "js")!

  private static let jsQueue = DispatchQueue(label: "PrettierFormatting.JS", qos: .userInitiated)
  private static var sharedContext: JSContext?
  private static var isCorePrepared = false
  private static var isSQLPrepared = false

  @discardableResult
  private static func ensurePrepared(loadSQL: Bool) -> Bool {
    if !isCorePrepared {
      let context = JSContext()!
      context.exceptionHandler = { _, value in
        print("js error:", value ?? "unknown")
      }
      do {
        context.evaluateScript(try String(contentsOfFile: Self.prettier))
        context.evaluateScript(try String(contentsOfFile: Self.babel))
        context.evaluateScript(try String(contentsOfFile: Self.estree))
      } catch {
        print("failed preparing core prettier scripts")
        return false
      }
      Self.sharedContext = context
      Self.isCorePrepared = true
    }

    if loadSQL && !isSQLPrepared {
      guard let context = Self.sharedContext else { return false }
      do {
        context.evaluateScript(try String(contentsOfFile: Self.sqlPlugin))
      } catch {
        print("failed preparing sql plugin script")
        return false
      }
      Self.isSQLPrepared = true
    }

    return true
  }

  #if DEBUG
    /// Test-only helper to reset internal JS state for cold-start measurements.
    @discardableResult
    internal static func _resetForTests() -> Bool {
      sharedContext = nil
      isCorePrepared = false
      isSQLPrepared = false
      return true
    }
  #endif

  // MARK: - Prewarm APIs

  /// Prepares Prettier core (standalone, babel, estree). Safe to call multiple times.
  @discardableResult
  public static func prepareFormatter() -> Bool {
    ensurePrepared(loadSQL: false)
  }

  /// Prepares Prettier SQL plugin in addition to core. Safe to call multiple times.
  @discardableResult
  public static func prepareSQLFormatter() -> Bool {
    ensurePrepared(loadSQL: true)
  }

  /// The parser to user for formatting.
  public enum Parser: String {
    /// Babel.
    case babel
    /// Babel with Flow.
    case babelFlow = "babel-flow"
    /// Babel with TypeScript.
    case babelTS = "babel-ts"
    /// Flow.
    case flow
    /// TypeScript.
    case typescript
    /// CSS.
    case css
    /// SCSS.
    case scss
    /// SQL.
    case sql
    /// LESS.
    case less
    /// JSON.
    case json
    /// JSON5.
    case json5
    /// GraphQL.
    case graphql
    /// Markdown.
    case markdown
    /// MDX.
    case mdx
    /// HTML.
    case html
    /// Vue.
    case vue
    /// Angular.
    case angular
    /// YAML.
    case yaml
  }

  // MARK: - SQL typed options

  public struct SQLFormatOptions {
    public enum Language: String {
      case sql
      case bigquery
      case db2
      case db2i
      case hive
      case mariadb
      case mysql
      case n1ql
      case postgresql
      case plsql
      case redshift
      case singlestoredb
      case snowflake
      case spark
      case sqlite
      case transactsql
      case tsql
      case trino
    }

    public enum LetterCase: String {
      case preserve
      case upper
      case lower
    }

    public enum IndentStyle: String {
      case standard
      case tabularLeft
      case tabularRight
    }

    public enum LogicalOperatorNewline: String {
      case before
      case after
    }

    public var language: Language
    public var dialect: String?
    public var keywordCase: LetterCase
    public var dataTypeCase: LetterCase
    public var functionCase: LetterCase
    public var identifierCase: LetterCase
    public var indentStyle: IndentStyle
    public var logicalOperatorNewline: LogicalOperatorNewline
    public var expressionWidth: Int
    public var linesBetweenQueries: Int
    public var denseOperators: Bool
    public var newlineBeforeSemicolon: Bool
    public var params: String?
    public var paramTypes: String?

    public init(
      language: Language = .sql,
      dialect: String? = nil,
      keywordCase: LetterCase = .preserve,
      dataTypeCase: LetterCase = .preserve,
      functionCase: LetterCase = .preserve,
      identifierCase: LetterCase = .preserve,
      indentStyle: IndentStyle = .standard,
      logicalOperatorNewline: LogicalOperatorNewline = .before,
      expressionWidth: Int = 50,
      linesBetweenQueries: Int = 1,
      denseOperators: Bool = false,
      newlineBeforeSemicolon: Bool = false,
      params: String? = nil,
      paramTypes: String? = nil
    ) {
      self.language = language
      self.dialect = dialect
      self.keywordCase = keywordCase
      self.dataTypeCase = dataTypeCase
      self.functionCase = functionCase
      self.identifierCase = identifierCase
      self.indentStyle = indentStyle
      self.logicalOperatorNewline = logicalOperatorNewline
      self.expressionWidth = expressionWidth
      self.linesBetweenQueries = linesBetweenQueries
      self.denseOperators = denseOperators
      self.newlineBeforeSemicolon = newlineBeforeSemicolon
      self.params = params
      self.paramTypes = paramTypes
    }
  }

  //  private static func makeContext() -> JSContext {
  //    let context = JSContext()!
  //    context.exceptionHandler = { (ctx: JSContext!, value: JSValue!) in
  //      let stacktrace = value.objectForKeyedSubscript("stack").toString()
  //      let lineNumber = value.objectForKeyedSubscript("line")
  //      let column = value.objectForKeyedSubscript("column")
  //      let moreInfo = "in method \(String(describing: stacktrace))Line number in file: \(String(describing: lineNumber)), column: \(String(describing: column))"
  //      print("Error: \(String(describing: value)) \(moreInfo)")
  //    }
  //    context.evaluateScript(
  //      """
  //      var console = {
  //        log: function(message) { _consoleLog(message) },
  //        error: function(message) { _consoleLog(message) },
  //        warning: function(message) { _consoleLog(message) },
  //      }
  //      """
  //    )
  //    let log: @convention(block) (String) -> Void = { message in print(message) }
  //    context.setObject(unsafeBitCast(log, to: AnyObject.self), forKeyedSubscript: "_consoleLog" as (NSCopying & NSObjectProtocol))
  //    return context
  //  }

  /// The current Prettier library version.
  public static var prettierVersion: String {
    _ = ensurePrepared(loadSQL: false)
    guard let context = Self.sharedContext else { return "" }
    return context.evaluateScript("globalThis.prettier.version")!.toString()
  }

  //  /// Returns a formatted string.
  //  /// - Parameters:
  //  ///   - from: The string to format.
  //  /// - Returns: The formatted string.
  //  public static func formattedString(from string: String, parser: Parser = .babel) -> String {
  //    let context = JSContext()!
  //    context.evaluateScript(try! String(contentsOfFile: Self.prettier))
  //    //    context.evaluateScript(try! String(contentsOfFile: Self.babelParser))
  //
  //    let options: [String: Any] = [
  //      "parser": parser.rawValue,
  //      "plugins": context.objectForKeyedSubscript("prettierPlugins")!,
  //      "semi": false,
  //    ]
  //
  //    return context
  //      .evaluateScript("globalThis.prettier.format")!
  //      .call(withArguments: [string, options])
  //      .toString()
  //  }

  public static func formattedString(
    from string: String,
    parser: Parser = .babel,
    options userOptions: [String: Any]? = nil
  ) async -> String? {
    guard ensurePrepared(loadSQL: parser == .sql), let context = Self.sharedContext else {
      return nil
    }

    var options: [String: Any] = [
      "parser": parser.rawValue,
      "plugins": context.objectForKeyedSubscript("prettierPlugins") ?? NSNull(),
      "semi": false,
      "language": "postgresql",
      "keywordCase": "upper",
    ]

    if let userOptions = userOptions {
      options.merge(userOptions) { _, new in new }
    }

    guard
      let formatPromise = context.evaluateScript("globalThis.prettier.format")
        .call(withArguments: [string, options])
    else {
      return nil
    }

    return await withCheckedContinuation { continuation in
      let thenBlock: @convention(block) (JSValue) -> Void = { result in
        continuation.resume(returning: result.toString())
      }
      let catchBlock: @convention(block) (JSValue) -> Void = { error in
        print("prettier format error:", error)
        continuation.resume(returning: nil)
      }

      formatPromise.invokeMethod("then", withArguments: [thenBlock])
      formatPromise.invokeMethod("catch", withArguments: [catchBlock])
    }
  }

  /// Synchronous version of `formattedString`. Blocks the calling thread until formatting completes.
  public static func formattedString(
    from string: String,
    parser: Parser = .babel,
    options userOptions: [String: Any]? = nil
  ) -> String? {
    guard ensurePrepared(loadSQL: parser == .sql), let context = Self.sharedContext else {
      return nil
    }

    var options: [String: Any] = [
      "parser": parser.rawValue,
      "plugins": context.objectForKeyedSubscript("prettierPlugins") ?? NSNull(),
      "semi": false,
      "language": "postgresql",
      "keywordCase": "upper",
    ]

    if let userOptions = userOptions {
      options.merge(userOptions) { _, new in new }
    }

    guard
      let formatPromise = context.evaluateScript("globalThis.prettier.format")
        .call(withArguments: [string, options])
    else {
      return nil
    }

    var result: String?
    let semaphore = DispatchSemaphore(value: 0)

    let thenBlock: @convention(block) (JSValue) -> Void = { value in
      result = value.toString()
      semaphore.signal()
    }

    let catchBlock: @convention(block) (JSValue) -> Void = { error in
      print("prettier format error:", error)
      semaphore.signal()
    }

    formatPromise.invokeMethod("then", withArguments: [thenBlock])
    formatPromise.invokeMethod("catch", withArguments: [catchBlock])

    semaphore.wait()
    return result
  }

  /// Formats SQL using type-safe options. Convenience wrapper around `formattedString`.
  /// - Parameters:
  ///   - from: The SQL source to format
  ///   - options: Type-safe SQL formatting options (defaults mirror plugin defaults)
  /// - Returns: The formatted SQL, or nil on error
  public static func formattedSQLString(
    from string: String,
    options: SQLFormatOptions = SQLFormatOptions()
  ) async -> String? {
    var sqlOptions: [String: Any] = [
      "language": options.language.rawValue,
      "keywordCase": options.keywordCase.rawValue,
      "dataTypeCase": options.dataTypeCase.rawValue,
      "functionCase": options.functionCase.rawValue,
      "identifierCase": options.identifierCase.rawValue,
      "indentStyle": options.indentStyle.rawValue,
      "logicalOperatorNewline": options.logicalOperatorNewline.rawValue,
      "expressionWidth": options.expressionWidth,
      "linesBetweenQueries": options.linesBetweenQueries,
      "denseOperators": options.denseOperators,
      "newlineBeforeSemicolon": options.newlineBeforeSemicolon,
    ]

    if let dialect = options.dialect { sqlOptions["dialect"] = dialect }
    if let params = options.params { sqlOptions["params"] = params }
    if let paramTypes = options.paramTypes { sqlOptions["paramTypes"] = paramTypes }

    return await formattedString(from: string, parser: .sql, options: sqlOptions)
  }

  /// Synchronous version of `formattedSQLString`. Blocks until complete.
  public static func formattedSQLString(
    from string: String,
    options: SQLFormatOptions = SQLFormatOptions()
  ) -> String? {
    var sqlOptions: [String: Any] = [
      "language": options.language.rawValue,
      "keywordCase": options.keywordCase.rawValue,
      "dataTypeCase": options.dataTypeCase.rawValue,
      "functionCase": options.functionCase.rawValue,
      "identifierCase": options.identifierCase.rawValue,
      "indentStyle": options.indentStyle.rawValue,
      "logicalOperatorNewline": options.logicalOperatorNewline.rawValue,
      "expressionWidth": options.expressionWidth,
      "linesBetweenQueries": options.linesBetweenQueries,
      "denseOperators": options.denseOperators,
      "newlineBeforeSemicolon": options.newlineBeforeSemicolon,
    ]

    if let dialect = options.dialect { sqlOptions["dialect"] = dialect }
    if let params = options.params { sqlOptions["params"] = params }
    if let paramTypes = options.paramTypes { sqlOptions["paramTypes"] = paramTypes }

    return formattedString(from: string, parser: .sql, options: sqlOptions)
  }
}
