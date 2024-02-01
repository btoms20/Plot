/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Plot

final class ControlFlowTests: XCTestCase {
    func testIfCondition() async {
        let rendered = await Node<Any>.if(true, .text("True")).render()
        XCTAssertEqual(rendered, "True")
        let rendered2 = await Node<Any>.if(false, .text("True")).render()
        XCTAssertEqual(rendered2, "")
    }

    func testIfElseCondition() async {
        let rendered = await Node<Any>.if(true, .text("If"), else: .text("Else")).render()
        XCTAssertEqual(
            rendered,
            "If"
        )

        let rendered2 = await Node<Any>.if(false, .text("If"), else: .text("Else")).render()
        XCTAssertEqual(
            rendered2,
            "Else"
        )
    }

    func testUnwrappingOptional() async {
        var optional: String? = "Hello"
        let rendered = await Node<Any>.unwrap(optional, Node.text).render()
        XCTAssertEqual(rendered, "Hello")

        optional = nil
        let rendered2 = await Node<Any>.unwrap(optional, Node.text).render()
        XCTAssertEqual(rendered2, "")
        let rendered3 = await Node<Any>.unwrap(optional, Node.text, else: .text("Is nil") ).render()
        XCTAssertEqual(rendered3, "Is nil")
    }

    func testForEach() async {
        let array = ["A", "B", "C"]
        let rendered = await Node<Any>.forEach(array, Node.text).render()
        XCTAssertEqual(rendered, "ABC")
        let rendered2 = await Node<Any>.forEach([], Node.text).render()
        XCTAssertEqual(rendered2, "")
    }
}
