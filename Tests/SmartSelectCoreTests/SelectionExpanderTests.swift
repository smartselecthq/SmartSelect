import XCTest
@testable import SmartSelectCore

final class SelectionExpanderTests: XCTestCase {
    private let expander = SelectionExpander.default

    /// Simulates a double-click by selecting the first "word-ish" run at `hitIndex`,
    /// then asserts the expander widens it to `expected`.
    private func assertExpands(
        _ text: String,
        clickWord word: String,
        to expected: String,
        kind: EntityKind,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let ns = text as NSString
        let wordRange = ns.range(of: word)
        XCTAssertNotEqual(wordRange.location, NSNotFound, "test word not found", file: file, line: line)
        let result = expander.expandedSelection(in: text, around: TextSpan(wordRange))
        guard let result else {
            XCTFail("expected expansion to \(expected), got nil", file: file, line: line)
            return
        }
        XCTAssertEqual(result.text, expected, file: file, line: line)
        XCTAssertEqual(result.kind, kind, file: file, line: line)
    }

    func testEmailExpansion() {
        assertExpands("Contact jane at jane.doe@acme.co today", clickWord: "jane.doe", to: "jane.doe@acme.co", kind: .email)
        assertExpands("mail: a_b+tag@sub.example.com!", clickWord: "tag", to: "a_b+tag@sub.example.com", kind: .email)
    }

    func testNumberExpansion() {
        assertExpands("Total is $1,299.00 due", clickWord: "1", to: "$1,299.00", kind: .number)
        assertExpands("grew 12.5% last year", clickWord: "12", to: "12.5%", kind: .number)
        assertExpands("id 1_000_000 processed", clickWord: "1", to: "1_000_000", kind: .number)
        assertExpands("value -42.7 here", clickWord: "42", to: "-42.7", kind: .number)
    }

    func testURLExpansion() {
        assertExpands("see https://example.com/pricing?ref=hn now", clickWord: "example", to: "https://example.com/pricing?ref=hn", kind: .url)
        assertExpands("go to www.example.com please", clickWord: "example", to: "www.example.com", kind: .url)
    }

    func testIPAddressBeatsNumber() {
        assertExpands("host 192.168.1.1 online", clickWord: "168", to: "192.168.1.1", kind: .ipAddress)
    }

    func testDateExpansion() {
        assertExpands("due 2026-09-19 sharp", clickWord: "2026", to: "2026-09-19", kind: .dateTime)
        assertExpands("on 09/19/2026 ok", clickWord: "19", to: "09/19/2026", kind: .dateTime)
    }

    func testHexColorBeatsHandle() {
        assertExpands("bg #1E90FF here", clickWord: "1E90FF", to: "#1E90FF", kind: .hexColor)
    }

    func testHandleExpansion() {
        assertExpands("thanks @typesafeai for this", clickWord: "typesafeai", to: "@typesafeai", kind: .handle)
        assertExpands("tag #SmartSelect please", clickWord: "SmartSelect", to: "#SmartSelect", kind: .handle)
    }

    func testFilePathExpansion() {
        assertExpands("open ~/Projects/app/main.swift now", clickWord: "main", to: "~/Projects/app/main.swift", kind: .filePath)
        assertExpands("cd /usr/local/bin then", clickWord: "local", to: "/usr/local/bin", kind: .filePath)
    }

    func testReturnsNilWhenNoEntity() {
        let text = "just some plain words here"
        let range = (text as NSString).range(of: "plain")
        XCTAssertNil(expander.expandedSelection(in: text, around: TextSpan(range)))
    }

    func testReturnsNilWhenSelectionAlreadyWholeEntity() {
        let text = "jane.doe@acme.co"
        let whole = TextSpan(location: 0, length: (text as NSString).length)
        XCTAssertNil(expander.expandedSelection(in: text, around: whole))
    }

    func testOutOfBoundsSelectionIsSafe() {
        let text = "short"
        let bogus = TextSpan(location: 100, length: 5)
        XCTAssertNil(expander.expandedSelection(in: text, around: bogus))
    }

    func testEmptyCaretInsideEntityStillExpands() {
        // A zero-length caret sitting inside an email should still expand.
        let text = "ping jane.doe@acme.co ok"
        let caret = TextSpan(location: (text as NSString).range(of: "doe").location, length: 0)
        let result = expander.expandedSelection(in: text, around: caret)
        XCTAssertEqual(result?.text, "jane.doe@acme.co")
    }

    func testDisabledKindIsNotDetected() {
        let onlyNumbers = SelectionExpander(enabledKinds: [.number])
        let text = "mail jane.doe@acme.co here"
        let range = (text as NSString).range(of: "jane.doe")
        XCTAssertNil(onlyNumbers.expandedSelection(in: text, around: TextSpan(range)))
    }
}
