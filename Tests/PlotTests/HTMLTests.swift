/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Plot

final class HTMLTests: XCTestCase {
    func testEmptyHTML() async {
        await assertEqualHTMLContent(HTML(), "")
    }

    func testPageLanguage() async {
        let html = HTML(.lang(.english))
        let rendered = await html.render()
        XCTAssertEqual(rendered, #"<!DOCTYPE html><html lang="en"></html>"#)
    }

    func testPageDirectionalityLeftToRight() async {
        let html = HTML(.dir(.leftToRight))
        let rendered = await html.render()
        XCTAssertEqual(rendered, #"<!DOCTYPE html><html dir="ltr"></html>"#)
    }

    func testPageDirectionalityRightToLeft() async {
        let html = HTML(.dir(.rightToLeft))
        let rendered = await html.render()
        XCTAssertEqual(rendered, #"<!DOCTYPE html><html dir="rtl"></html>"#)
    }

    func testPageDirectionalityAuto() async {
        let html = HTML(.dir(.auto))
        let rendered = await html.render()
        XCTAssertEqual(rendered, #"<!DOCTYPE html><html dir="auto"></html>"#)
    }

    func testHeadAndBody() async {
        let html = HTML(.head(), .body())
        await assertEqualHTMLContent(html, "<head></head><body></body>")
    }

    func testDocumentEncoding() async {
        let html = await HTML(.head(.encoding(.utf8)))
        await assertEqualHTMLContent(html, #"<head><meta charset="UTF-8"/></head>"#)
    }

    func testCSSStylesheet() async {
        let html = await HTML(.head(.stylesheet("styles.css")))
        await assertEqualHTMLContent(html, """
        <head><link rel="stylesheet" href="styles.css" type="text/css"/></head>
        """)
    }

    func testInlineCSS() async {
        let html = await HTML(
            .head(.style("body { color: #000; }")),
            .body(.style("color: #fff;"))
        )

        await assertEqualHTMLContent(html, """
        <head><style>body { color: #000; }</style></head><body style="color: #fff;"></body>
        """)
    }

    func testSiteName() async {
        let html = await HTML(.head(.siteName("MySite")))
        await assertEqualHTMLContent(html, """
        <head><meta property="og:site_name" content="MySite"/></head>
        """)
    }

    func testPageURL() async {
        let html = await HTML(.head(.url("url.com")))
        await assertEqualHTMLContent(html, """
        <head>\
        <link rel="canonical" href="url.com"/>\
        <meta name="twitter:url" content="url.com"/>\
        <meta property="og:url" content="url.com"/>\
        </head>
        """)
    }

    func testPageTitle() async {
        let html = await HTML(.head(.title("Title")))
        await assertEqualHTMLContent(html, """
        <head>\
        <title>Title</title>\
        <meta name="twitter:title" content="Title"/>\
        <meta property="og:title" content="Title"/>\
        </head>
        """)
    }

    func testPageDescription() async {
        let html = await HTML(.head(.description("Description")))
        await assertEqualHTMLContent(html, """
        <head>\
        <meta name="description" content="Description"/>\
        <meta name="twitter:description" content="Description"/>\
        <meta property="og:description" content="Description"/>\
        </head>
        """)
    }

    func testSocialImageMetadata() async {
        let html = await HTML(.head(
            .socialImageLink("url.png"),
            .twitterCardType(.summaryLargeImage),
            .twitterUsername("@CreatorHandle")
        ))

        await assertEqualHTMLContent(html, """
        <head>\
        <meta name="twitter:image" content="url.png"/>\
        <meta property="og:image" content="url.png"/>\
        <meta name="twitter:card" content="summary_large_image"/>\
        <meta name="twitter:site" content="@CreatorHandle"/>\
        </head>
        """)
    }

    func testResponsiveViewport() async {
        let html = await HTML(.head(.viewport(.accordingToDevice)))
        await assertEqualHTMLContent(html, """
        <head><meta name="viewport" content="width=device-width, initial-scale=1.0"/></head>
        """)
    }

    func testStaticViewport() async {
        let html = await HTML(.head(.viewport(.constant(500))))
        await assertEqualHTMLContent(html, """
        <head><meta name="viewport" content="width=500, initial-scale=1.0"/></head>
        """)
    }
    
    func testViewportFit() async {
        let html = await HTML(.head(.viewport(.accordingToDevice, fit: .cover)))
        await assertEqualHTMLContent(html, """
        <head><meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover"/></head>
        """)
    }

    func testFavicon() async {
        let html = await HTML(.head(.favicon("icon.png")))
        await assertEqualHTMLContent(html, """
        <head><link rel="shortcut icon" href="icon.png" type="image/png"/></head>
        """)
    }

    func testRSSFeedLink() async {
        let html = await HTML(.head(.rssFeedLink("feed.rss", title: "RSS")))
        await assertEqualHTMLContent(html, """
        <head><link rel="alternate" href="feed.rss" type="application/rss+xml" title="RSS"/></head>
        """)
    }

    func testLinkWithHrefLang() async {
        let html = await HTML(.head(.link(
            .rel(.alternate),
            .href("http://site/"),
            .hreflang(.english)
        )))

        await assertEqualHTMLContent(html, """
        <head><link rel="alternate" href="http://site/" hreflang="en"/></head>
        """)
    }

    func testAppleTouchIconLink() async {
        let html = await HTML(.head(.link(
            .rel(.appleTouchIcon),
            .sizes("180x180"),
            .href("apple-touch-icon.png")
        )))

        await assertEqualHTMLContent(html, """
        <head><link rel="apple-touch-icon" sizes="180x180" href="apple-touch-icon.png"/></head>
        """)
    }

    func testCrossoriginLinkEnabled() async {
        let html = await HTML(.head(.link(
            .rel(.preconnect),
            .href("https://foo.com"),
            .crossorigin(true)
        )))

        await assertEqualHTMLContent(html, """
        <head><link rel="preconnect" href="https://foo.com" crossorigin/></head>
        """)
    }

    func testCrossoriginLinkDisabled() async {
        let html = await HTML(.head(.link(
            .rel(.preconnect),
            .href("https://foo.com"),
            .crossorigin(false)
        )))

        await assertEqualHTMLContent(html, """
        <head><link rel="preconnect" href="https://foo.com"/></head>
        """)
    }

    func testManifestLink() async {
        let html = await HTML(.head(.link(
            .rel(.manifest),
            .href("site.webmanifest")
        )))

        await assertEqualHTMLContent(html, """
        <head><link rel="manifest" href="site.webmanifest"/></head>
        """)
    }

    func testMaskIconLink() async {
        let html = await HTML(.head(.link(
            .rel(.maskIcon),
            .href("safari-pinned-tab.svg"),
            .color("#000000")
        )))

        await assertEqualHTMLContent(html, """
        <head><link rel="mask-icon" href="safari-pinned-tab.svg" color="#000000"/></head>
        """)
    }

    func testBodyWithID() async {
        let html = HTML(.body(.id("anID")))
        await assertEqualHTMLContent(html, #"<body id="anID"></body>"#)
    }

    func testBodyWithCSSClass() async {
        let html = HTML(.body(.class("myClass")))
        await assertEqualHTMLContent(html, #"<body class="myClass"></body>"#)
    }

    func testOverridingBodyCSSClass() async {
        let html = HTML(.body(.class("a"), .class("b")))
        await assertEqualHTMLContent(html, #"<body class="b"></body>"#)
    }

    func testHiddenElements() async {
        let html = HTML(.body(
            .div(.hidden(false)),
            .div(.hidden(true))
        ))
        await assertEqualHTMLContent(html, "<body><div></div><div hidden></div></body>")
    }

    func testTitleAttribute() async {
        let html = await HTML(
            .head(
                .link(
                    .rel(.alternate),
                    .title("Alternative representation")
                )
            ),
            .body(
                .div(
                    .title("Division title"),
                    .p(.title("Paragraph title"), "Paragraph"),
                    .a(.href("#"), .title("Link title"), "Link")
                )
            )
        )
        
        await assertEqualHTMLContent(html, """
        <head>\
        <link rel="alternate" title="Alternative representation"/>\
        </head>\
        <body>\
        <div title="Division title">\
        <p title="Paragraph title">Paragraph</p>\
        <a href="#" title="Link title">Link</a>\
        </div>\
        </body>
        """)
    }

    func testUnorderedList() async {
        let html = HTML(.body(.ul(.li("Text"))))
        await assertEqualHTMLContent(html, "<body><ul><li>Text</li></ul></body>")
    }

    func testOrderedList() async {
        let html = HTML(.body(.ol(.li(.span("Text")))))
        await assertEqualHTMLContent(html, "<body><ol><li><span>Text</span></li></ol></body>")
    }

    func testDescriptionList() async {
        let html = HTML(.body(.dl(
            .dt("Term"),
            .dd("Description")
        )))

        await assertEqualHTMLContent(html, """
        <body><dl><dt>Term</dt><dd>Description</dd></dl></body>
        """)
    }
    
    func testDescriptionListWithDiv() async {
        let html = HTML(.body(.dl(
            .div(
                .dt("Last modified time"),
                .dd("2004-12-23T23:33Z")
            ),
            .div(
                .dt("Recommended update interval"),
                .dd("60s")
            ),
            .div(
                .dt("Authors"),
                .dt("Editors"),
                .dd("Robert Rothman"),
                .dd("Daniel Jackson")
            )
        )))

        await assertEqualHTMLContent(html, """
        <body><dl><div><dt>Last modified time</dt><dd>2004-12-23T23:33Z</dd></div><div><dt>Recommended update interval</dt><dd>60s</dd></div><div><dt>Authors</dt><dt>Editors</dt><dd>Robert Rothman</dd><dd>Daniel Jackson</dd></div></dl></body>
        """)
    }

    func testTextDirectionalityLeftToRight() async {
        let html = HTML(.body(
            .h1(.dir(.leftToRight), "Text")
        ))

        await assertEqualHTMLContent(html, #"<body><h1 dir="ltr">Text</h1></body>"#)
    }

    func testTextDirectionalityRightToLeft() async {
        let html = HTML(.body(
            .h1(.dir(.rightToLeft), "Text")
        ))

        await assertEqualHTMLContent(html, #"<body><h1 dir="rtl">Text</h1></body>"#)
    }

    func testTextDirectionalityAuto() async {
        let html = HTML(.body(
            .h1(.dir(.auto), "Text")
        ))

        await assertEqualHTMLContent(html, #"<body><h1 dir="auto">Text</h1></body>"#)
    }

    func testInputDirectionalityAuto() async {
        let html = await HTML(.body(
            .input(.dir(.auto))
        ))

        await assertEqualHTMLContent(html, #"<body><input dir="auto"/></body>"#)
    }

    func testTextAreaDirectionalityLeftToRight() async {
        let html = HTML(.body(
            .textarea(.dir(.auto))
        ))

        await assertEqualHTMLContent(html, #"<body><textarea dir="auto"></textarea></body>"#)
    }

    func testAnchors() async throws {
        let html = try HTML(.body(
            .a(.href("a.html"), .target(.blank), .text("A")),
            .a(.href("b.html"), .rel(.nofollow), .text("B")),
            .a(.href(require(URL(string: "c.html"))), .text("C"))
        ))

        await assertEqualHTMLContent(html, """
        <body>\
        <a href="a.html" target="_blank">A</a>\
        <a href="b.html" rel="nofollow">B</a>\
        <a href="c.html">C</a>\
        </body>
        """)
    }

    func testTable() async {
        let html = HTML(.body(
            .table(
                .caption("Caption"),
                .tr(.th("Hello")),
                .tr(.td("World"))
            )
        ))

        await assertEqualHTMLContent(html, """
        <body><table>\
        <caption>Caption</caption>\
        <tr><th>Hello</th></tr>\
        <tr><td>World</td></tr>\
        </table></body>
        """)
    }

    func testTableGroupingSemantics() async {
        let html = HTML(
            .body(
                .table(
                    .thead(
                        .tr(
                            .th("Column1"),
                            .th("Column2")
                        )
                    ),
                    .tbody(
                        .tr(
                            .td("Body1"),
                            .td("Body2")
                        ),
                        .tr(
                            .td("Body3"),
                            .td("Body4")
                        )
                    ),
                    .tfoot(
                        .tr(
                            .td("Foot1"),
                            .td("Foot2")
                        )
                    )
                )
            )
        )

        await assertEqualHTMLContent(html, """
        <body><table>\
        <thead><tr><th>Column1</th><th>Column2</th></tr></thead>\
        <tbody><tr><td>Body1</td><td>Body2</td></tr>\
        <tr><td>Body3</td><td>Body4</td></tr></tbody>\
        <tfoot><tr><td>Foot1</td><td>Foot2</td></tr></tfoot>\
        </table></body>
        """)
    }

    func testData() async {
        let html = HTML(.body(
            .data(.value("123"), .text("Hello"))
        ))

        await assertEqualHTMLContent(html, #"<body><data value="123">Hello</data></body>"#)
    }

    func testEmbeddedObject() async {
        let html = await HTML(.body(
            .embed(
                .src("url"),
                .type("some/type"),
                .width(500),
                .height(300)
            )
        ))

        await assertEqualHTMLContent(html, #"""
        <body><embed src="url" type="some/type" width="500" height="300"/></body>
        """#)
    }

    func testForm() async {
        let html = await HTML(.body(
            .form(
                .action("url.com"),
                .fieldset(
                    .label(.for("a"), "A label"),
                    .input(.name("a"), .type(.text))
                ),
                .input(.name("b"), .type(.search), .autocomplete(false), .autofocus(true)),
                .input(.name("c"), .type(.text), .autofocus(false), .readonly(false), .disabled(false)),
                .input(.name("d"), .type(.email), .placeholder("email address"), .autocomplete(true), .required(true)),
                .input(.name("e"), .type(.text), .readonly(true), .disabled(true)),
                .textarea(.name("f"), .cols(50), .rows(10), .required(true), .text("Test")),
                .textarea(.name("g"), .autofocus(true), .placeholder("Placeholder"), .readonly(false), .disabled(false)),
                .textarea(.name("h"), .readonly(true), .disabled(true), .text("Test")),
                .input(.name("i"), .type(.checkbox), .checked(true)),
                .input(.name("j"), .type(.file), .multiple(true)),
                .input(.type(.submit), .value("Send"))
            )
        ))

        await assertEqualHTMLContent(html, """
        <body><form action="url.com">\
        <fieldset>\
        <label for="a">A label</label>\
        <input name="a" type="text"/>\
        </fieldset>\
        <input name="b" type="search" autocomplete="off" autofocus/>\
        <input name="c" type="text"/>\
        <input name="d" type="email" placeholder="email address" autocomplete="on" required/>\
        <input name="e" type="text" readonly disabled/>\
        <textarea name="f" cols="50" rows="10" required>Test</textarea>\
        <textarea name="g" autofocus placeholder="Placeholder"></textarea>\
        <textarea name="h" readonly disabled>Test</textarea>\
        <input name="i" type="checkbox" checked/>\
        <input name="j" type="file" multiple/>\
        <input type="submit" value="Send"/>\
        </form></body>
        """)
    }
    
    func testFormContentType() async {
        let html = HTML(.body(
            .form(.enctype(.urlEncoded)),
            .form(.enctype(.multipartData)),
            .form(.enctype(.plainText))
        ))
        
        await assertEqualHTMLContent(html, """
        <body>\
        <form enctype="application/x-www-form-urlencoded"></form>\
        <form enctype="multipart/form-data"></form>\
        <form enctype="text/plain"></form>\
        </body>
        """)
    }
    
    func testFormMethod() async {
        let html = HTML(.body(
            .form(.method(.get)),
            .form(.method(.post))
        ))

        await assertEqualHTMLContent(html, """
        <body>\
        <form method="get"></form>\
        <form method="post"></form>\
        </body>
        """)
    }
    
    func testFormNoValidate() async {
        let html = HTML(.body(
            .form(.novalidate())
        ))
        
        await assertEqualHTMLContent(html, """
        <body>\
        <form novalidate></form>\
        </body>
        """)
    }

    func testFormWithBodyNodes() async {
        let html = await HTML(.body(
            .form(
                .method(.post),
                .div(
                    .class("wrapper"),
                    .p("Text"),
                    .input(
                        .type(.submit),
                        .value("Action")
                    )
                )
            )
        ))

        await assertEqualHTMLContent(html, """
        <body><form method="post"><div class="wrapper">\
        <p>Text</p><input type="submit" value="Action"/>\
        </div></form></body>
        """)
    }
    
    func testHeadings() async {
        let html = HTML(.body(
            .h1("One"),
            .h2("Two"),
            .h3("Three"),
            .h4("Four"),
            .h5("Five"),
            .h6("Six")
        ))

        await assertEqualHTMLContent(html, """
        <body>\
        <h1>One</h1>\
        <h2>Two</h2>\
        <h3>Three</h3>\
        <h4>Four</h4>\
        <h5>Five</h5>\
        <h6>Six</h6>\
        </body>
        """)
    }

    func testParagraph() async {
        let html = HTML(.body(.p("Text")))
        await assertEqualHTMLContent(html, "<body><p>Text</p></body>")
    }

    func testImage() async {
        let html = await HTML(.body(
            .img(
                .id("id"),
                .class("image"),
                .src("image.png"),
                .alt("Text"),
                .width(44),
                .height(44)
            )
        ))

        await assertEqualHTMLContent(html, """
        <body><img id="id" class="image" src="image.png" alt="Text" width="44" height="44"/></body>
        """)
    }

    func testAudioPlayer() async {
        let html = await HTML(.body(
            .audio(.source(.src("a.mp3"), .type(.mp3))),
            .audio(.controls(true), .source(.src("b.wav"), .type(.wav))),
            .audio(.controls(false), .source(.src("c.ogg"), .type(.ogg)))
        ))

        await assertEqualHTMLContent(html, """
        <body>\
        <audio><source src="a.mp3" type="audio/mpeg"/></audio>\
        <audio controls><source src="b.wav" type="audio/wav"/></audio>\
        <audio><source src="c.ogg" type="audio/ogg"/></audio>\
        </body>
        """)
    }

    func testVideoPlayer() async {
        let html = await HTML(.body(
            .video(.source(.src("a.mp4"), .type(.mp4))),
            .video(.controls(true), .source(.src("b.webm"), .type(.webM))),
            .video(.controls(false), .source(.src("c.ogg"), .type(.ogg)))
        ))

        await assertEqualHTMLContent(html, """
        <body>\
        <video><source src="a.mp4" type="video/mp4"/></video>\
        <video controls><source src="b.webm" type="video/webm"/></video>\
        <video><source src="c.ogg" type="video/ogg"/></video>\
        </body>
        """)
    }

    func testArticle() async {
        let html = HTML(.body(
            .article(
                .header(.h1("Title")),
                .p("Body"),
                .footer(.span("Footer"))
            )
        ))

        await assertEqualHTMLContent(html, """
        <body><article>\
        <header><h1>Title</h1></header>\
        <p>Body</p>\
        <footer><span>Footer</span></footer>\
        </article></body>
        """)
    }

    func testCode() async {
        let html = HTML(.body(
            .p(.code("hello()")),
            .pre(.code("world()"))
        ))

        await assertEqualHTMLContent(html, """
        <body>\
        <p><code>hello()</code></p>\
        <pre><code>world()</code></pre>\
        </body>
        """)
    }

    func testTextStyling() async {
        let html = HTML(.body(
            .b("Bold"),
            .strong("Bold"),
            .i("Italic"),
            .em("Italic"),
            .u("Underlined"),
            .s("Strikethrough"),
            .ins("Inserted"),
            .del("Deleted"),
            .small("Small")
        ))

        await assertEqualHTMLContent(html, """
        <body>\
        <b>Bold</b>\
        <strong>Bold</strong>\
        <i>Italic</i>\
        <em>Italic</em>\
        <u>Underlined</u>\
        <s>Strikethrough</s>\
        <ins>Inserted</ins>\
        <del>Deleted</del>\
        <small>Small</small>\
        </body>
        """)
    }

    func testIFrame() async {
        let html = await HTML(.body(
            .iframe(
                .src("url.com"),
                .frameborder(false),
                .allow("gyroscope"),
                .allowfullscreen(false)
            ),
            .iframe(
                .allowfullscreen(true)
            )
        ))

        await assertEqualHTMLContent(html, """
        <body>\
        <iframe src="url.com" frameborder="0" allow="gyroscope"></iframe>\
        <iframe allowfullscreen></iframe>\
        </body>
        """)
    }

    func testJavaScript() async {
        let html = HTML(
            .head(
                .script(.src("script.js")),
                .script(.async(), .src("async.js")),
                .script(.defer(), .src("deferred.js"))
            ),
            .body(.script(#"console.log("Consider going JS-free :)")"#))
        )

        await assertEqualHTMLContent(html, """
        <head><script src="script.js"></script>\
        <script async src="async.js"></script>\
        <script defer src="deferred.js"></script></head>\
        <body><script>console.log("Consider going JS-free :)")</script></body>
        """)
    }

    func testButton() async {
        let html = HTML(.body(
            .button(.type(.button), .name("Name"), .value("Value"), .text("Text")),
            .button(.type(.submit), .text("Submit"))
        ))

        await assertEqualHTMLContent(html, """
        <body>\
        <button type="button" name="Name" value="Value">Text</button>\
        <button type="submit">Submit</button>\
        </body>
        """)
    }

    func testAbbreviation() async {
        let html = HTML(.body(
            .abbr(.title("HyperText Markup Language"), "HTML")
        ))

        await assertEqualHTMLContent(html, """
        <body><abbr title="HyperText Markup Language">HTML</abbr></body>
        """)
    }

    func testBlockquote() async {
        let html = HTML(.body(.blockquote("Quote")))
        await assertEqualHTMLContent(html, "<body><blockquote>Quote</blockquote></body>")
    }

    func testListsOfOptions() async {
        let html = await HTML(.body(
            .datalist(
                .option(.value("A")),
                .option(.value("B"))
            ),
            .select(
                .option(.value("C"), .isSelected(true)),
                .option(.value("D"), .label("Dee"), .isSelected(false))
            )
        ))

        await assertEqualHTMLContent(html, """
        <body>\
        <datalist><option value="A"/><option value="B"/></datalist>\
        <select><option value="C" selected/><option value="D" label="Dee"/></select>\
        </body>
        """)
    }

    func testDetails() async {
        let html = HTML(.body(
            .details(.open(true), .summary("Open Summary"), .p("Text")),
            .details(.open(false), .summary("Closed Summary"), .p("Text"))
        ))

        await assertEqualHTMLContent(html, """
        <body>\
        <details open><summary>Open Summary</summary><p>Text</p></details>\
        <details><summary>Closed Summary</summary><p>Text</p></details>\
        </body>
        """)
    }

    func testLineBreak() async {
        let html = HTML(.body("One", .br(), "Two"))
        await assertEqualHTMLContent(html, "<body>One<br/>Two</body>")
    }

    func testHorizontalLine() async {
        let html = await HTML(.body("One", .hr(), "Two"))
        await assertEqualHTMLContent(html, "<body>One<hr/>Two</body>")
    }

    func testHorizontalLineAttributes() async {
        let html = await HTML(.body("One", .hr(.class("alternate")), "Two"))
        await assertEqualHTMLContent(html, #"<body>One<hr class="alternate"/>Two</body>"#)
    }

    func testNoScript() async {
        let html = HTML(.body(.noscript("NoScript")))
        await assertEqualHTMLContent(html, "<body><noscript>NoScript</noscript></body>")
    }

    func testNavigation() async {
        let html = HTML(.body(.nav("Navigation")))
        await assertEqualHTMLContent(html, "<body><nav>Navigation</nav></body>")
    }

    func testSection() async {
        let html = HTML(.body(.section("Section")))
        await assertEqualHTMLContent(html, "<body><section>Section</section></body>")
    }

    func testAside() async {
        let html = HTML(.body(.aside("Aside")))
        await assertEqualHTMLContent(html, "<body><aside>Aside</aside></body>")
    }

    func testMain() async {
        let html = HTML(.body(.main("Main")))
        await assertEqualHTMLContent(html, "<body><main>Main</main></body>")
    }

    func testAccessibilityLabel() async {
        let html = HTML(.body(.button(.text("X"), .ariaLabel("Close"))))
        await assertEqualHTMLContent(html, #"<body><button aria-label="Close">X</button></body>"#)
    }
    
    func testAccessibilityControls() async {
        let html = HTML(.body(.ul(.li(.id("list"), .ariaControls("div"))), .div(.id("div"))))
        await assertEqualHTMLContent(html, """
        <body>\
        <ul><li id="list" aria-controls="div"></li></ul><div id="div"></div>\
        </body>
        """)
    }
    
    func testAccessibilityExpanded() async {
        let html = HTML(.body(.a(.ariaExpanded(true))))
        await assertEqualHTMLContent(html, #"<body><a aria-expanded="true"></a></body>"#)
    }
    
    func testAccessibilityHidden() async {
        let html = HTML(.body(.a(.ariaHidden(true))))
        await assertEqualHTMLContent(html, #"<body><a aria-hidden="true"></a></body>"#)
    }

    func testDataAttributes() async {
        let html = await HTML(.body(
            .data(named: "user-name", value: "John"),
            .img(.data(named: "icon", value: "User"))
        ))

        await assertEqualHTMLContent(html, """
        <body data-user-name="John"><img data-icon="User"/></body>
        """)
    }

    func testSpellcheckAttribute() async {
        let html = await HTML(
            .body(
                .spellcheck(true),
                .form(
                    .input(.type(.text), .spellcheck(false)),
                    .textarea(.spellcheck(false))
                )
            )
        )
        await assertEqualHTMLContent(html, """
            <body spellcheck="true">\
            <form>\
            <input type="text" spellcheck="false"/>\
            <textarea spellcheck="false"></textarea>\
            </form>\
            </body>
            """)
    }
    
    func testSubresourceIntegrity() async {
        let html = await HTML(.head(
            .script(.src("file.js"), .integrity("sha384-fakeHash")),
            .link(.rel(.stylesheet), .href("styles.css"), .type("text/css"), .integrity("sha512-fakeHash")),
            .stylesheet("styles2.css", integrity: "sha256-fakeHash")
        ))

        await assertEqualHTMLContent(html, """
        <head><script src="file.js" integrity="sha384-fakeHash"></script>\
        <link rel="stylesheet" href="styles.css" type="text/css" integrity="sha512-fakeHash"/>\
        <link rel="stylesheet" href="styles2.css" type="text/css" integrity="sha256-fakeHash"/>\
        </head>
        """)
    }

    func testComments() async {
        let html = await HTML(.comment("Hello"), .body(.comment("World")))
        await assertEqualHTMLContent(html, "<!--Hello--><body><!--World--></body>")
    }

    func testPicture() async {
        let html = await HTML(.body(.picture(
            .source(
                .srcset("dark.jpg"),
                .media("(prefers-color-scheme: dark)")
            ),
            .img(.src("default.jpg"))
        )))

        await assertEqualHTMLContent(html, """
        <body><picture>\
        <source srcset="dark.jpg" media="(prefers-color-scheme: dark)"/>\
        <img src="default.jpg"/>\
        </picture></body>
        """)
    }
    
    func testTime() async {
        let html = HTML(.body(.time(
            .text("Hello World!"),
            .datetime("2011-11-18T14:54:39Z")
        )))
        
        await assertEqualHTMLContent(html, """
        <body><time datetime="2011-11-18T14:54:39Z">\
        Hello World!\
        </time></body>
        """)
    }
                               
    func testObject() async {
        let html = HTML(.body(.object(
            .data("vector.svg"),
            .attribute(.type("image/svg+xml")),
            .attribute(.width(200)),
            .attribute(.height(100))
        )))
        
        await assertEqualHTMLContent(html, """
        <body><object data="vector.svg" type="image/svg+xml" width="200" height="100"></object></body>
        """)
    }

    func testOnClick() async {
        let html = HTML(
            .body(
                .div(
                    .onclick("javascript:alert('Hello World')")
                )
            )
        )
        await assertEqualHTMLContent(html, """
        <body><div onclick="javascript:alert('Hello World')"></div></body>
        """)
    }
}
