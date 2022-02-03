import XCTest
@testable import PrettierFormatting

final class PrettierFormatterTests: XCTestCase {
  func testPrettierVersion() throws {
    XCTAssertEqual(PrettierFormatter.prettierVersion, "2.4.1")
  }

  func testFormattedString() throws {
    XCTAssertEqual(
      PrettierFormatter.formattedString(from: "db .test.find( { id:{$gt :    200} } )"),
      "db.test.find({ id: { $gt: 200 } })\n"
    )
  }
}
