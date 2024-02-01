/**
*  Plot
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE file for details
*/

import XCTest
@testable import Plot

final class HTMLComponentTests: XCTestCase {
    func testControlFlow() async {
        let string: String? = "String"
        let nilString: String? = nil
        let bool = true
        let int = 3

        let html = await Div {
            if let string = string {
                await Paragraph(string)
            }

            if let string = nilString {
                await Paragraph("Should not be rendered: \(string)")
            }

            if let string = nilString {
                await Paragraph("Should not be rendered: \(string)")
            } else {
                await Paragraph("Nil")
            }
            
            if let string { await Paragraph(string) }
//            string.map { await Paragraph($0) }
            if let nilString { await Paragraph(nilString) }
//            nilString.map { await Paragraph($0) }

            for string in ["One", "Two"] {
                await Paragraph(string)
            }

            if bool {
                await Paragraph("True")
            }

            switch int {
            case 3:
                await Paragraph("Switch")
            default:
                await Paragraph("Should not be rendered")
            }
        }
        .render()

        XCTAssertEqual(html, """
        <div><p>String</p><p>Nil</p><p>String</p><p>One</p><p>Two</p><p>True</p><p>Switch</p></div>
        """)
    }

    func testNodeInteroperability() async {
        let html = await Div {
            Node.p("One")
            await Node<Any>.component(Paragraph("Two"))
            await Paragraph("Three")
        }
        .render()

        XCTAssertEqual(html, "<div><p>One</p><p>Two</p><p>Three</p></div>")
    }

    func testIDAndClassModifiers() async {
        let html = await Link("Swift by Sundell",
            url: "https://swiftbysundell.com"
        )
        .id("sxs-link")
        .class("link")
        .render()

        XCTAssertEqual(html, """
        <a href="https://swiftbysundell.com" id="sxs-link" class="link">Swift by Sundell</a>
        """)
    }

    func testAssigningDirectionalityToElement() async {
        let html = await Paragraph("Hello")
            .directionality(.leftToRight)
            .render()

        XCTAssertEqual(html, #"<p dir="ltr">Hello</p>"#)
    }

    func testAppendingClasses() async {
        let html = await Paragraph("Hello")
            .class("one")
            .class("two")
            .class("three")
            .render()

        XCTAssertEqual(html, #"<p class="one two three">Hello</p>"#)
    }

    func testNotAppendingEmptyClasses() async {
        let html = await Paragraph("Hello")
            .class("")
            .class("one")
            .class("")
            .class("two")
            .render()

        XCTAssertEqual(html, #"<p class="one two">Hello</p>"#)
    }

    func testAppendingClassesToWrappingComponents() async {
        struct InnerWrapper: Component {
            func body() async -> Component {
                await Paragraph("Hello").class("one")
            }
        }

        struct OuterWrapper: Component {
            func body() async -> Component {
                InnerWrapper().class("two")
            }
        }

        let html = await OuterWrapper().class("three").render()
        XCTAssertEqual(html, #"<p class="one two three">Hello</p>"#)
    }

    func testAppendingClassToWrappingComponentContainingGroup() async {
        struct Wrapper: Component {
            func body() async -> Component {
                await ComponentGroup {
                    await Paragraph("One")
                    await Paragraph("Two")
                }
                .class("one")
            }
        }

        let html = await Wrapper().class("two").render()
        XCTAssertEqual(html, #"<p class="one two">One</p><p class="one two">Two</p>"#)
    }

    func testReplacingClass() async {
        let html = await Paragraph("Hello")
            .class("one")
            .class("two")
            .class("three", replaceExisting: true)
            .render()

        XCTAssertEqual(html, #"<p class="three">Hello</p>"#)
    }

    func testAddingClassToMultipleComponents() async {
        let html = await ComponentGroup {
            await Div()
            await Div()
        }
        .class("hello")
        .render()

        XCTAssertEqual(html, #"<div class="hello"></div><div class="hello"></div>"#)
    }

    func testAddingClassToNode() async {
        let html = await Node.div(.p()).class("hello").render()
        XCTAssertEqual(html, #"<div class="hello"><p></p></div>"#)
    }

    func testEnvironmentValuesDoNotApplyToSiblings() async {
        let html = await Div {
            Link("One", url: "/one")
                .linkTarget(.blank)
            Link("Two", url: "/two")
                .linkRelationship(.nofollow)
            Link("Three", url: "/three")
        }
        .render()

        XCTAssertEqual(html, """
        <div>\
        <a href="/one" target="_blank">One</a>\
        <a href="/two" rel="nofollow">Two</a>\
        <a href="/three">Three</a>\
        </div>
        """)
    }

    func testApplyingEnvironmentValuesToTopLevelHTML() async {
        let html = await HTML(
            .body {
                Link("One", url: "/one")
                Link("Two", url: "/two")
            }
        )
        .environmentValue(.nofollow, key: .linkRelationship)

        await assertEqualHTMLContent(html, """
        <body>\
        <a href="/one" rel="nofollow">One</a>\
        <a href="/two" rel="nofollow">Two</a>\
        </body>
        """)
    }

    func testUsingCustomEnvironmentKey() async {
        struct TestComponent: Component {
            @EnvironmentValue(.init(identifier: "key")) var value: String?

            func body() async -> Component {
                await Paragraph(value ?? "No value")
            }
        }

        let html = await TestComponent()
            .environmentValue("Value", key: .init(identifier: "key"))
            .render()

        XCTAssertEqual(html, "<p>Value</p>")
    }

    func testApplyingTextStyles() async {
        let html = await Div {
            Text("Bold")
                .bold()
                .addLineBreak()
            Text("Italic")
                .italic()
                .addLineBreak()
            Text("Underlined")
                .underlined()
                .addLineBreak()
            Text("Strikethrough")
                .strikethrough()
                .addLineBreak()
        }
        .render()

        XCTAssertEqual(html, """
        <div>\
        <b>Bold</b><br/>\
        <em>Italic</em><br/>\
        <u>Underlined</u><br/>\
        <s>Strikethrough</s><br/>\
        </div>
        """)
    }

    func testTextConcatenation() async {
        let text = Text("One") + Text(" ") + Text("Two").bold()
        let rendered = await text.render()
        XCTAssertEqual(rendered, "One <b>Two</b>")
    }

    func testApplyingAccessibilityLabel() async {
        let html = await Paragraph("Text")
            .accessibilityLabel("Label")
            .render()

        XCTAssertEqual(html, #"<p aria-label="Label">Text</p>"#)
    }

    func testApplyingDataAttribute() async {
        let html = await Paragraph("Text")
            .data(named: "test", value: "value")
            .render()

        XCTAssertEqual(html, #"<p data-test="value">Text</p>"#)
    }

    func testApplyingStyleAttribute() async {
        let html = await Paragraph("Text")
            .style("color: #000;")
            .render()

        XCTAssertEqual(html, #"<p style="color: #000;">Text</p>"#)
    }

    func testElementBasedComponents() async {
        let html = await HTML {
            await Article("Article")
            await Button("Button")
            await Details("Details")
            await Div("Div")
            await FieldSet("FieldSet")
            await Footer("Footer")
            await H1("H1")
            await H2("H2")
            await H3("H3")
            await H4("H4")
            await H5("H5")
            await H6("H6")
            await Header("Header")
            await ListItem("ListItem")
            await Main("Main")
            await Navigation("Navigation")
            await Paragraph("Paragraph")
            await Span("Span")
            await Summary("Summary")
            await TableCaption("TableCaption")
            await TableCell("TableCell")
            await TableHeaderCell("TableHeaderCell")
        }

        await assertEqualHTMLContent(html, """
        <body>\
        <article>Article</article>\
        <button>Button</button>\
        <details>Details</details>\
        <div>Div</div>\
        <fieldset>FieldSet</fieldset>\
        <footer>Footer</footer>\
        <h1>H1</h1>\
        <h2>H2</h2>\
        <h3>H3</h3>\
        <h4>H4</h4>\
        <h5>H5</h5>\
        <h6>H6</h6>\
        <header>Header</header>\
        <li>ListItem</li>\
        <main>Main</main>\
        <nav>Navigation</nav>\
        <p>Paragraph</p>\
        <span>Span</span>\
        <summary>Summary</summary>\
        <caption>TableCaption</caption>\
        <td>TableCell</td>\
        <th>TableHeaderCell</th>\
        </body>
        """)
    }

    func testAudioPlayer() async {
        let html = await HTML {
            AudioPlayer(source: .mp3(at: "a.mp3"), showControls: false)
            AudioPlayer(source: .wav(at: "b.wav"), showControls: true)
            AudioPlayer(source: .ogg(at: "c.ogg"), showControls: false)
        }

        await assertEqualHTMLContent(html, """
        <body>\
        <audio><source type="audio/mpeg" src="a.mp3"/></audio>\
        <audio controls><source type="audio/wav" src="b.wav"/></audio>\
        <audio><source type="audio/ogg" src="c.ogg"/></audio>\
        </body>
        """)
    }

    func testForm() async {
        let html = await Form(
            url: "url.com",
            method: .post,
            content: {
                FieldSet {
                    Label("Username") {
                        TextField(name: "username", isRequired: true)
                            .autoFocused()
                            .autoComplete(false)
                    }
                    Label("Password") {
                        Input(
                            type: .password,
                            name: "password"
                        )
                        .class("password-input")
                    }
                    .class("password-label")
                }
                TextArea(
                    text: "Enter a description",
                    name: "description",
                    numberOfRows: 3,
                    numberOfColumns: 2
                )
                SubmitButton("Submit")
            }
        )
        .render()

        XCTAssertEqual(html, """
        <form action="url.com" method="post">\
        <fieldset>\
        <label>Username\
        <input type="text" name="username" required autofocus autocomplete="off"/>\
        </label>\
        <label class="password-label">Password\
        <input type="password" name="password" class="password-input"/>\
        </label>\
        </fieldset>\
        <textarea name="description" rows="3" cols="2">Enter a description</textarea>\
        <input type="submit" value="Submit"/>\
        </form>
        """)
    }

    func testIFrame() async {
        let html = await IFrame(
            url: "url.com",
            addBorder: false,
            allowFullScreen: true,
            enabledFeatureNames: ["gyroscope"]
        )
        .render()

        XCTAssertEqual(html, """
        <iframe src="url.com" frameborder="0" allowfullscreen allow="gyroscope"></iframe>
        """)
    }

    func testImageWithDescription() async {
        let html = await Image(url: "image.png", description: "My image").render()
        XCTAssertEqual(html, #"<img src="image.png" alt="My image"/>"#)
    }

    func testImageWithoutDescription() async {
        let html = await Image("image.png").render()
        XCTAssertEqual(html, #"<img src="image.png"/>"#)
    }

    func testLinkRelationshipAndTarget() async {
        let html = await Div {
            Link("First", url: "/first")
            Link("Second", url: "/second")
                .linkRelationship(.noreferrer)
                .linkTarget(nil)
        }
        .linkRelationship(.nofollow)
        .linkTarget(.blank)
        .render()

        XCTAssertEqual(html, """
        <div>\
        <a href="/first" rel="nofollow" target="_blank">First</a>\
        <a href="/second" rel="noreferrer">Second</a>\
        </div>
        """)
    }

    func testOrderedList() async {
        let html = await List(["One", "Two"])
            .listStyle(.ordered)
            .render()

        XCTAssertEqual(html, "<ol><li>One</li><li>Two</li></ol>")
    }
    
    func testTime() async {
        let html = await Time(datetime: "2011-11-18T14:54:39Z") {
            await Paragraph("Hello World")
        }
        .render()
        
        XCTAssertEqual(html, #"<time datetime="2011-11-18T14:54:39Z"><p>Hello World</p></time>"#)
    }

    func testOrderedListWithExplicitItems() async {
        struct SeventhComponent: Component {
            func body() async -> Component { await ListItem("Seven") }
        }

        let bool = true

        let html = await List {
            await ListItem("One").number(1)
            Text("Two")

            if bool {
                await Paragraph("Three").class("three")
            }

            await ListItem("Four").class("four")

            for string in ["Five", "Six"] {
                await ListItem(string)
            }

            SeventhComponent()

            Node.li("Eight")

            Node.group(
                .li("Nine"),
                .li("Ten", .class("ten"))
            )
        }
        .listStyle(.ordered)
        .render()

        XCTAssertEqual(html, """
        <ol>\
        <li value="1">One</li>\
        <li>Two</li>\
        <li><p class="three">Three</p></li>\
        <li class="four">Four</li>\
        <li>Five</li>\
        <li>Six</li>\
        <li>Seven</li>\
        <li>Eight</li>\
        <li>Nine</li>\
        <li class="ten">Ten</li>\
        </ol>
        """)
    }

    func testOrderedListWithEmptyComponent() async {
        let html = await List {
            Text("Hello")
            EmptyComponent()
        }
        .listStyle(.ordered)
        .render()

        XCTAssertEqual(html, "<ol><li>Hello</li></ol>")
    }

    func testUnorderedList() async {
        let html = await List(["One", "Two"]).render()
        XCTAssertEqual(html, "<ul><li>One</li><li>Two</li></ul>")
    }

    func testUnorderedListWithCustomItemClass() async {
        let html = await List([1, 2]) { number in
            await Paragraph(String(number))
        }
        .listStyle(.unordered.withItemClass("item"))
        .render()

        XCTAssertEqual(html, """
        <ul>\
        <li class="item"><p>1</p></li>\
        <li class="item"><p>2</p></li>\
        </ul>
        """)
    }

    func testUngroupedTable() async {
        let html = await Table {
            Text("Row one")
            TableRow {
                await TableCell("Row two, cell one")
                await TableCell("Row two, cell two")
            }

            await ComponentGroup {
                TableRow {
                    Text("Row three, cell one")
                    Text("Row three, cell two")
                }
                await TableCell("Row four")
            }
        }
        .render()

        XCTAssertEqual(html, """
        <table>\
        <tr><td>Row one</td></tr>\
        <tr><td>Row two, cell one</td><td>Row two, cell two</td></tr>\
        <tr><td>Row three, cell one</td><td>Row three, cell two</td></tr>\
        <tr><td>Row four</td></tr>\
        </table>
        """)
    }

    func testGroupedTable() async {
        let html = await Table(
            caption: TableCaption("Caption"),
            header: TableRow { Text("Header") },
            footer: TableRow { Text("Footer") },
            rows: {
                Text("Row one")
                TableRow {
                    await TableCell("Row two, cell one")
                    await TableCell("Row two, cell two")
                }

                await ComponentGroup {
                    TableRow {
                        Text("Row three, cell one")
                        Text("Row three, cell two")
                    }
                    await TableCell("Row four")
                }
            }
        )
        .render()

        XCTAssertEqual(html, """
        <table>\
        <caption>Caption</caption>\
        <thead><tr><th>Header</th></tr></thead>\
        <tbody>\
        <tr><td>Row one</td></tr>\
        <tr><td>Row two, cell one</td><td>Row two, cell two</td></tr>\
        <tr><td>Row three, cell one</td><td>Row three, cell two</td></tr>\
        <tr><td>Row four</td></tr>\
        </tbody>\
        <tfoot><tr><td>Footer</td></tr></tfoot>\
        </table>
        """)
    }
}
