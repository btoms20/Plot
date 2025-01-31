/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Plot

final class DocumentTests: XCTestCase {
    func testEmptyDocument() async {
        let document = Document<FormatStub>.custom()
        let rendered = await document.render()
        XCTAssertEqual(rendered, "")
    }

    func testEmptyIndentedDocument() async {
        let document = Document<FormatStub>.custom()
        let rendered = await document.render(indentedBy: .spaces(4))
        XCTAssertEqual(rendered, "")
    }

    func testIndentationWithSpaces() async {
        let document = await Document.custom(
            withFormat: FormatStub.self,
            elements: [
                .named("one", nodes: [
                    .element(named: "two", nodes: [
                        .selfClosedElement(named: "three")
                    ]),
                    .text("four "),
                    .component(Text("five")),
                    .component(Element.named("six", nodes: [
                        .text("seven")
                    ])),
                    .element(named: "eight", nodes: [
                        .text("nine")
                    ])
                ]),
                .selfClosed(named: "ten", attributes: [
                    Attribute(name: "key", value: "value")
                ])
            ]
        )

        let rendered = await document.render(indentedBy: .spaces(4))
        XCTAssertEqual(rendered, """
        <one>
            <two>
                <three/>
            </two>four five
            <six>seven</six>
            <eight>nine</eight>
        </one>
        <ten key="value"/>
        """)
    }

    func testIndentationWithTabs() async {
        let document = await Document.custom(
            withFormat: FormatStub.self,
            elements: [
                .named("one", nodes: [
                    .element(named: "two", nodes: [
                        .selfClosedElement(named: "three")
                    ]),
                    .element(named: "four")
                ]),
                .selfClosed(named: "five", attributes: [
                    Attribute(name: "key", value: "value")
                ])
            ]
        )

        let rendered = await document.render(indentedBy: .tabs(1))
        XCTAssertEqual(rendered, """
        <one>
        \t<two>
        \t\t<three/>
        \t</two>
        \t<four></four>
        </one>
        <five key="value"/>
        """)
    }
}

private extension DocumentTests {
    struct FormatStub: DocumentFormat {
        enum RootContext {}
    }
}
