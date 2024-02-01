/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Plot

final class XMLTests: XCTestCase {
    func testEmptyXML() async {
        await assertEqualXMLContent(XML(), "")
    }

    func testSingleElement() async {
        let xml = await XML(.element(named: "hello", text: "world!"))
        await assertEqualXMLContent(xml, "<hello>world!</hello>")
    }

    func testSelfClosingElement() async {
        let xml = await XML(.selfClosedElement(named: "element"))
        await assertEqualXMLContent(xml, "<element/>")
    }

    func testElementWithAttribute() async {
        let xml = await XML(.element(
            named: "element",
            nodes: [
                .attribute(named: "attribute", value: "value")
            ]
        ))

        await assertEqualXMLContent(xml, #"<element attribute="value"></element>"#)
    }

    func testElementWithChildren() async {
        let xml = await XML(
            .element(named: "parent", nodes: [
                .selfClosedElement(named: "a"),
                .selfClosedElement(named: "b")
            ])
        )

        await assertEqualXMLContent(xml, "<parent><a/><b/></parent>")
    }
}
