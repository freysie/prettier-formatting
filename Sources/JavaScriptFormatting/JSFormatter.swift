import JavaScriptCore

public class JSFormatter {
  private static let prettier = Bundle.module.path(forResource: "node_modules/prettier/standalone", ofType: "js")!
  private static let babelParser = Bundle.module.path(forResource: "node_modules/prettier/parser-babel", ofType: "js")!
  
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
  
  public static var prettierVersion: String {
    let context = JSContext()!
    context.evaluateScript(try! String(contentsOfFile: Self.prettier))
    return context.evaluateScript("globalThis.prettier.version")!.toString()
  }
  
  public static func formattedString(from string: String) -> String {
    let context = JSContext()!
    context.evaluateScript(try! String(contentsOfFile: Self.prettier))
    context.evaluateScript(try! String(contentsOfFile: Self.babelParser))
    return context
      .evaluateScript("globalThis.prettier.format")!
      .call(withArguments: [string, [
        "parser": "babel",
        "plugins": context.objectForKeyedSubscript("prettierPlugins")!,
        "semi": false,
      ]])
      .toString()
  }
}
