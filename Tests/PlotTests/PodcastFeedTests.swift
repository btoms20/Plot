/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Plot

final class PodcastFeedTests: XCTestCase {
    func testEmptyFeed() async {
        let feed = await PodcastFeed()
        await assertEqualPodcastFeedContent(feed, "")
    }

    func testNewFeedURL() async {
        let feed = await PodcastFeed(.newFeedURL("url.com"))
        await assertEqualPodcastFeedContent(feed, "<itunes:new-feed-url>url.com</itunes:new-feed-url>")
    }

    func testPodcastTitle() async {
        let feed = await PodcastFeed(.title("MyPodcast"))
        await assertEqualPodcastFeedContent(feed, "<title>MyPodcast</title>")
    }

    func testPodcastSubtitle() async {
        let feed = await PodcastFeed(.subtitle("Subtitle"))
        await assertEqualPodcastFeedContent(feed, "<itunes:subtitle>Subtitle</itunes:subtitle>")
    }

//    func testPodcastDescription() async {
//        let feed = await PodcastFeed(.description("Description"))
//        await assertEqualPodcastFeedContent(feed, "<description>Description</description>")
//    }

    func testPodcastSummary() async {
        let feed = await PodcastFeed(.summary("Summary"))
        await assertEqualPodcastFeedContent(feed, "<itunes:summary>Summary</itunes:summary>")
    }

    func testPodcastURL() async {
        let feed = await PodcastFeed(.link("url.com"))
        await assertEqualPodcastFeedContent(feed, "<link>url.com</link>")
    }

    func testPodcastAtomLink() async {
        let feed = await PodcastFeed(.atomLink("url.com"))
        await assertEqualPodcastFeedContent(feed, """
        <atom:link href="url.com" rel="self" type="application/rss+xml"/>
        """)
    }

    func testPodcastLanguage() async {
        let feed = await PodcastFeed(.language(.usEnglish))
        await assertEqualPodcastFeedContent(feed, "<language>en-us</language>")
    }

    func testPodcastTTL() async {
        let feed = await PodcastFeed(.ttl(200))
        await assertEqualPodcastFeedContent(feed, "<ttl>200</ttl>")
    }

    func testPodcastCopyright() async {
        let feed = await PodcastFeed(.copyright("Copyright"))
        await assertEqualPodcastFeedContent(feed, "<copyright>Copyright</copyright>")
    }

    func testPodcastAuthor() async {
        let feed = await PodcastFeed(.author("Author"))
        await assertEqualPodcastFeedContent(feed, "<itunes:author>Author</itunes:author>")
    }

    func testPodcastExplicitFlag() async {
        let explicitFeed = await PodcastFeed(.explicit(true))
        await assertEqualPodcastFeedContent(explicitFeed, "<itunes:explicit>yes</itunes:explicit>")

        let nonExplicitFeed = await PodcastFeed(.explicit(false))
        await assertEqualPodcastFeedContent(nonExplicitFeed, "<itunes:explicit>no</itunes:explicit>")
    }

    func testPodcastOwner() async {
        let feed = await PodcastFeed(.owner(.name("Name"), .email("Email")))
        await assertEqualPodcastFeedContent(feed, """
        <itunes:owner><itunes:name>Name</itunes:name><itunes:email>Email</itunes:email></itunes:owner>
        """)
    }

    func testPodcastCategory() async {
        let feed = await PodcastFeed(.category("News"))
        await assertEqualPodcastFeedContent(feed, #"<itunes:category text="News"/>"#)
    }

    func testPodcastSubcategory() async {
        let feed = await PodcastFeed(.category("News", .category("Tech News")))
        await assertEqualPodcastFeedContent(feed, """
        <itunes:category text="News"><itunes:category text="Tech News"/></itunes:category>
        """)
    }

    func testPodcastType() async {
        let episodicFeed = await PodcastFeed(.type(.episodic))
        await assertEqualPodcastFeedContent(episodicFeed, "<itunes:type>episodic</itunes:type>")

        let serialFeed = await PodcastFeed(.type(.serial))
        await assertEqualPodcastFeedContent(serialFeed, "<itunes:type>serial</itunes:type>")
    }

    func testPodcastImage() async {
        let feed = await PodcastFeed(.image("image.png"))
        await assertEqualPodcastFeedContent(feed, #"<itunes:image href="image.png"/>"#)
    }

    func testPodcastPublicationDate() async throws {
        let stubs = try Date.makeStubs(withFormattingStyle: .rss)
        let feed = await PodcastFeed(.pubDate(stubs.date, timeZone: stubs.timeZone))
        await assertEqualPodcastFeedContent(feed, "<pubDate>\(stubs.expectedString)</pubDate>")
    }

    func testPodcastLastBuildDate() async throws {
        let stubs = try Date.makeStubs(withFormattingStyle: .rss)
        let feed = await PodcastFeed(.lastBuildDate(stubs.date, timeZone: stubs.timeZone))
        await assertEqualPodcastFeedContent(feed, "<lastBuildDate>\(stubs.expectedString)</lastBuildDate>")
    }

    func testEpisodeGUID() async {
        let guidFeed = await PodcastFeed(.item(.guid("123")))
        await assertEqualPodcastFeedContent(guidFeed, "<item><guid>123</guid></item>")

        let permaLinkFeed = await PodcastFeed(.item(.guid("url.com", .isPermaLink(true))))
        await assertEqualPodcastFeedContent(permaLinkFeed, """
        <item><guid isPermaLink="true">url.com</guid></item>
        """)

        let nonPermaLinkFeed = await PodcastFeed(.item(.guid("123", .isPermaLink(false))))
        await assertEqualPodcastFeedContent(nonPermaLinkFeed, """
        <item><guid isPermaLink="false">123</guid></item>
        """)
    }

    func testEpisodeTitle() async {
        let feed = await PodcastFeed(.item(.title("Title")))
        await assertEqualPodcastFeedContent(feed, """
        <item><title>Title</title><itunes:title>Title</itunes:title></item>
        """)
    }

//    func testEpisodeDescription() async {
//        let feed = await PodcastFeed(.item(.description("Description")))
//        await assertEqualPodcastFeedContent(feed, """
//        <item><description>Description</description></item>
//        """)
//    }

    func testEpisodeURL() async {
        let feed = await PodcastFeed(.item(.link("url.com")))
        await assertEqualPodcastFeedContent(feed, "<item><link>url.com</link></item>")
    }

    func testEpisodePublicationDate() async throws {
        let stubs = try Date.makeStubs(withFormattingStyle: .rss)
        let feed = await PodcastFeed(.item(.pubDate(stubs.date, timeZone: stubs.timeZone)))
        await assertEqualPodcastFeedContent(feed, """
        <item><pubDate>\(stubs.expectedString)</pubDate></item>
        """)
    }

    func testEpisodeDuration() async {
        let feed = await PodcastFeed(.item(
            .duration("00:15:12"),
            .duration(hours: 0, minutes: 15, seconds: 12),
            .duration(hours: 1, minutes: 2, seconds: 3)
        ))

        await assertEqualPodcastFeedContent(feed, """
        <item>\
        <itunes:duration>00:15:12</itunes:duration>\
        <itunes:duration>00:15:12</itunes:duration>\
        <itunes:duration>01:02:03</itunes:duration>\
        </item>
        """)
    }

    func testSeasonNumber() async {
        let feed = await PodcastFeed(.item(.seasonNumber(3)))
        await assertEqualPodcastFeedContent(feed, """
        <item><itunes:season>3</itunes:season></item>
        """)
    }

    func testEpisodeNumber() async {
        let feed = await PodcastFeed(.item(.episodeNumber(42)))
        await assertEqualPodcastFeedContent(feed, """
        <item><itunes:episode>42</itunes:episode></item>
        """)
    }

    func testEpisodeType() async {
        let feed = await PodcastFeed(
            .item(.episodeType(.full)),
            .item(.episodeType(.trailer)),
            .item(.episodeType(.bonus))
        )

        await assertEqualPodcastFeedContent(feed, """
        <item><itunes:episodeType>full</itunes:episodeType></item>\
        <item><itunes:episodeType>trailer</itunes:episodeType></item>\
        <item><itunes:episodeType>bonus</itunes:episodeType></item>
        """)
    }

    func testEpisodeAudio() async {
        let feed = await PodcastFeed(.item(.audio(
            url: "episode.mp3",
            byteSize: 69121733,
            title: "Episode"
        )))

        let expectedComponents = [
            "<item>",
            #"<enclosure url="episode.mp3" length="69121733" type="audio/mpeg"/>"#,
            #"<media:content url="episode.mp3" length="69121733" type="audio/mpeg" isDefault="true" medium="audio">"#,
            #"<media:title type="plain">Episode</media:title>"#,
            "</media:content>",
            "</item>"
        ]

        await assertEqualPodcastFeedContent(feed, expectedComponents.joined())
    }

    func testEpisodeHTMLContent() async {
        let feed = await PodcastFeed(.item(.content(
            "<p>Hello</p><p>World &amp; Everyone!</p>"
        )))

        let expectedComponents = [
            "<item>",
            "<content:encoded>",
            "<![CDATA[<p>Hello</p><p>World &amp; Everyone!</p>]]>",
            "</content:encoded>",
            "</item>"
        ]

        await assertEqualPodcastFeedContent(feed, expectedComponents.joined())
    }
}
