import XCTest
@testable import JavaScriptFormatting

final class JSFormatterTests: XCTestCase {
  func testPrettierVersion() throws {
    XCTAssertEqual(JSFormatter.prettierVersion, "2.4.1")
  }

  func testFormattedString() throws {
    XCTAssertEqual(
      JSFormatter.formattedString(from: "db .test.find( { id:{$gt :    200} } )"),
      "db.test.find({ id: { $gt: 200 } })\n"
    )
  }
}
