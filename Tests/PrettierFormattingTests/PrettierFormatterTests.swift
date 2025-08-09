import XCTest

@testable import PrettierFormatting

final class PrettierFormatterTests: XCTestCase {
  func testPrettierVersion() {
    XCTAssertEqual(PrettierFormatter.prettierVersion, "3.6.2")
  }

  func testJSFormattingSync() throws {
    let formatted = PrettierFormatter.formattedString(
      from: "db .test.find( { id:{$gt :    200} } )")
    XCTAssertEqual(
      formatted,
      "db.test.find({ id: { $gt: 200 } })\n"
    )
  }

  func testSQLFormattingSync() throws {
    let formatted = PrettierFormatter.formattedString(
      from: """
        sELect  first_name,    species froM
           animals
                 WhERE
         id = $1
        """,
      parser: .sql
    )
    XCTAssertEqual(
      formatted,
      """
      SELECT
        first_name,
        species
      FROM
        animals
      WHERE
        id = $1

      """
    )
  }

  func testSQLFormattingWithOptionsSync() throws {
    let formatted = PrettierFormatter.formattedSQLString(
      from: """
          sELect  first_name,    species froM
             animals
                   WhERE
           id = $1
        """,
      options: .init(
        language: .postgresql,
        keywordCase: .lower
      )
    )

    XCTAssertEqual(
      formatted,
      """
      select
        first_name,
        species
      from
        animals
      where
        id = $1

      """
    )
  }

  func testJSFormatting() async throws {
    let formatted = await PrettierFormatter.formattedString(
      from: "db .test.find( { id:{$gt :    200} } )")
    XCTAssertEqual(
      formatted,
      "db.test.find({ id: { $gt: 200 } })\n"
    )
  }

  func testSQLFormatting() async throws {
    let formatted = await PrettierFormatter.formattedString(
      from: """
        sELect  first_name,    species froM
           animals
                 WhERE
         id = $1
        """,
      parser: .sql
    )
    //    print(formatted!)
    XCTAssertEqual(
      formatted,
      """
      SELECT
        first_name,
        species
      FROM
        animals
      WHERE
        id = $1

      """
    )
  }

  func testSQLFormattingWithOptions() async throws {
    let formatted = await PrettierFormatter.formattedSQLString(
      from: """
          sELect  first_name,    species froM
             animals
                   WhERE
           id = $1
        """,
      options: .init(
        language: .postgresql,
        keywordCase: .lower
      )
    )

    XCTAssertEqual(
      formatted,
      """
      select
        first_name,
        species
      from
        animals
      where
        id = $1

      """
    )
  }
}
