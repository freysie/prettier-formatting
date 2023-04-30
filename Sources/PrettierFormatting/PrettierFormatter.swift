import JavaScriptCore

@available(macOS 10.10, iOS 9, tvOS 9, *)
/// A formatter that pretty prints source code in various languages.
public class PrettierFormatter {
  static let prettier = Bundle.module.path(forResource: "standalone", ofType: "js")!
  static let babelParser = Bundle.module.path(forResource: "parser-babel", ofType: "js")!
  
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
    let context = JSContext()!
    context.evaluateScript(try! String(contentsOfFile: Self.prettier))
    return context.evaluateScript("globalThis.prettier.version")!.toString()
  }
  
  /// Returns a formatted string.
  /// - Parameters:
  ///   - from: The string to format.
  /// - Returns: The formatted string.
  public static func formattedString(from string: String, parser: Parser = .babel) -> String {
    let context = JSContext()!
    context.evaluateScript(try! String(contentsOfFile: Self.prettier))
    context.evaluateScript(try! String(contentsOfFile: Self.babelParser))
    return context
      .evaluateScript("globalThis.prettier.format")!
      .call(withArguments: [string, [
        "parser": parser.rawValue,
        "plugins": context.objectForKeyedSubscript("prettierPlugins")!,
        "semi": false,
      ] as [String: Any]])
      .toString()
  }
}
