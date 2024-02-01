/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Plot

final class NodeTests: XCTestCase {
    func testEscapingText() async {
        let node = await Node<Any>.text("Hello & welcome to <Plot>!;").render()
        XCTAssertEqual(node, "Hello &amp; welcome to &lt;Plot&gt;!;")
    }

    func testEscapingDoubleAmpersands() async {
        let node = await Node<Any>.text("&&").render()
        XCTAssertEqual(node, "&amp;&amp;")
    }

    func testEscapingAmpersandFollowedByComparisonSymbols() async {
        let node = await Node<Any>.text("&< &>").render()
        XCTAssertEqual(node, "&amp;&lt; &amp;&gt;")
    }

    func testNotDoubleEscapingText() async {
        let node = await Node<Any>.text("Hello &amp; welcome&#160;to &lt;Plot&gt;!&text").render()
        XCTAssertEqual(node, "Hello &amp; welcome&#160;to &lt;Plot&gt;!&amp;text")
    }

    func testNotEscapingRawString() async {
        let node = await Node<Any>.raw("Hello & welcome to <Plot>!").render()
        XCTAssertEqual(node, "Hello & welcome to <Plot>!")
    }

    func testGroup() async {
        let node = await Node<Any>.group(.text("Hello"), .text("World")).render()
        XCTAssertEqual(node, "HelloWorld")
    }

    func testCustomElement() async {
        let node = await Node<Any>.element(named: "custom").render()
        XCTAssertEqual(node, "<custom></custom>")
    }

    func testCustomAttribute() async {
        let node = await Node<Any>.attribute(named: "key", value: "value").render()
        XCTAssertEqual(node, #"key="value""#)
    }

    func testCustomElementWithCustomAttribute() async {
        let node = await Node<Any>.element(named: "custom", attributes: [
            Attribute(name: "key", value: "value")
        ]).render()

        XCTAssertEqual(node, #"<custom key="value"></custom>"#)
    }

    func testCustomElementWithCustomAttributeWithSpecificContext() async {
        let node = await Node<Any>.element(named: "custom", attributes: [
            Attribute<String>(name: "key", value: "value")
        ]).render()

        XCTAssertEqual(node, #"<custom key="value"></custom>"#)
    }

    func testCustomSelfClosedElementWithCustomAttribute() async {
        let node = await Node<Any>.selfClosedElement(named: "custom", attributes: [
            Attribute(name: "key", value: "value")
        ]).render()

        XCTAssertEqual(node, #"<custom key="value"/>"#)
    }

    func testComponents() async {
        let node = await Node<Any>.components {
            await Paragraph("One")
            await Paragraph("Two")
        }.render()

        XCTAssertEqual(node, "<p>One</p><p>Two</p>")
    }

    func testNodeComponentBodyIsEqualToSelf() async {
        let node =  Node.p("Text")
        let rendered1 = await node.render()
        let rendered2 = await node.body().render()
        XCTAssertEqual(rendered1, rendered2)
    }
}
