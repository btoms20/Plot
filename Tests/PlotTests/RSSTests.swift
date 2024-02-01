/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Plot

final class RSSTests: XCTestCase {
    func testEmptyFeed() async {
        let feed = await RSS()
        await assertEqualRSSFeedContent(feed, "")
    }

    func testFeedTitle() async {
        let feed = await RSS(.title("MyPodcast"))
        await assertEqualRSSFeedContent(feed, "<title>MyPodcast</title>")
    }

//    func testFeedDescription() async {
//        let feed = await RSS(.description("Description"))
//        await assertEqualRSSFeedContent(feed, "<description>Description</description>")
//    }

    func testFeedDescriptionWithHTMLContent() async {
        let feed = await RSS(
            .description(
                .p(
                    .text("Description with "),
                    .em("emphasis"),
                    .text(".")
                )
            )
        )
        await assertEqualRSSFeedContent(feed, "<description><![CDATA[<p>Description with <em>emphasis</em>.</p>]]></description>")
    }

    func testFeedURL() async {
        let feed = await RSS(.link("url.com"))
        await assertEqualRSSFeedContent(feed, "<link>url.com</link>")
    }

    func testFeedAtomLink() async {
        let feed = await RSS(.atomLink("url.com"))
        await assertEqualRSSFeedContent(feed, """
        <atom:link href="url.com" rel="self" type="application/rss+xml"/>
        """)
    }

    func testFeedLanguage() async {
        let feed = await RSS(.language(.usEnglish))
        await assertEqualRSSFeedContent(feed, "<language>en-us</language>")
    }

    func testFeedTTL() async {
        let feed = await RSS(.ttl(200))
        await assertEqualRSSFeedContent(feed, "<ttl>200</ttl>")
    }

    func testFeedPublicationDate() async throws {
        let stubs = try Date.makeStubs(withFormattingStyle: .rss)
        let feed = await RSS(.pubDate(stubs.date, timeZone: stubs.timeZone))
        await assertEqualRSSFeedContent(feed, "<pubDate>\(stubs.expectedString)</pubDate>")
    }

    func testFeedLastBuildDate() async throws {
        let stubs = try Date.makeStubs(withFormattingStyle: .rss)
        let feed = await RSS(.lastBuildDate(stubs.date, timeZone: stubs.timeZone))
        await assertEqualRSSFeedContent(feed, "<lastBuildDate>\(stubs.expectedString)</lastBuildDate>")
    }

    func testItemGUID() async {
        let feed = await RSS(
            .item(.guid("123")),
            .item(.guid("url.com", .isPermaLink(true))),
            .item(.guid("123", .isPermaLink(false)))
        )

        await assertEqualRSSFeedContent(feed, """
        <item><guid>123</guid></item>\
        <item><guid isPermaLink="true">url.com</guid></item>\
        <item><guid isPermaLink="false">123</guid></item>
        """)
    }

    func testItemTitle() async {
        let feed = await RSS(.item(.title("Title")))
        await assertEqualRSSFeedContent(feed, "<item><title>Title</title></item>")
    }

//    func testItemDescription() async {
//        let feed = await RSS(.item(.description("Description")))
//        await assertEqualRSSFeedContent(feed, """
//        <item><description>Description</description></item>
//        """)
//    }

    func testItemURL() async {
        let feed = await RSS(.item(.link("url.com")))
        await assertEqualRSSFeedContent(feed, "<item><link>url.com</link></item>")
    }

    func testItemPublicationDate() async throws {
        let stubs = try Date.makeStubs(withFormattingStyle: .rss)
        let feed = await RSS(.item(.pubDate(stubs.date, timeZone: stubs.timeZone)))
        await assertEqualRSSFeedContent(feed, """
        <item><pubDate>\(stubs.expectedString)</pubDate></item>
        """)
    }

    func testItemHTMLStringContent() async {
        let feed = await RSS(.item(.content(
            "<p>Hello</p><p>World &amp; Everyone!</p>"
        )))

        await assertEqualRSSFeedContent(feed, """
        <item>\
        <content:encoded>\
        <![CDATA[<p>Hello</p><p>World &amp; Everyone!</p>]]>\
        </content:encoded>\
        </item>
        """)
    }

    func testItemHTMLDSLContent() async {
        let feed = await RSS(.item(
            .content(.h1("Title"))
        ))

        await assertEqualRSSFeedContent(feed, """
        <item>\
        <content:encoded>\
        <![CDATA[<h1>Title</h1>]]>\
        </content:encoded>\
        </item>
        """)
    }
}
