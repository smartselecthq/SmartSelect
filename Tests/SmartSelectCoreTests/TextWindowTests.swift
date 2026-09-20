import XCTest
@testable import SmartSelectCore

final class TextWindowTests: XCTestCase {
    func testEnclosingLineIsolatesTheClickedLine() {
        let text = "first line\nmail jane.doe@acme.co here\nthird line"
        let hit = (text as NSString).range(of: "jane.doe")
        let (window, offset) = TextWindow.enclosingLine(in: text, around: TextSpan(hit))
        XCTAssertEqual(window, "mail jane.doe@acme.co here")
        XCTAssertEqual(offset, ("first line\n" as NSString).length)
    }

    func testEnclosingLineExcludesTrailingNewline() {
        let text = "alpha\nbeta\ngamma"
        let hit = (text as NSString).range(of: "beta")
        let (window, _) = TextWindow.enclosingLine(in: text, around: TextSpan(hit))
        XCTAssertEqual(window, "beta")
    }

    func testExpansionThroughEnclosingLineMapsBackToGlobalOffsets() {
        let text = "row one\ntotal $1,299.00 due\nrow three"
        let hit = (text as NSString).range(of: "1")
        let expander = SelectionExpander.default
        let result = expander.expandedSelectionInEnclosingLine(in: text, around: TextSpan(hit))
        XCTAssertEqual(result?.text, "$1,299.00")
        // The returned span must index back into the ORIGINAL text, not the window.
        let ns = text as NSString
        XCTAssertEqual(ns.substring(with: result!.span.nsRange), "$1,299.00")
    }

    func testEmptyTextIsSafe() {
        let (window, offset) = TextWindow.enclosingLine(in: "", around: TextSpan(location: 0, length: 0))
        XCTAssertEqual(window, "")
        XCTAssertEqual(offset, 0)
    }
}
