/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Plot

final class SiteMapTests: XCTestCase {
    func testEmptyMap() async {
        let map = await SiteMap()
        await assertEqualSiteMapContent(map, "")
    }

    func testDailyUpdatedLocation() async throws {
        let dateStubs = try Date.makeStubs(withFormattingStyle: .siteMap)

        let map = await SiteMap(.url(
            .loc("url.com"),
            .changefreq(.daily),
            .priority(1.0),
            .lastmod(dateStubs.date, timeZone: dateStubs.timeZone)
        ))

        await assertEqualSiteMapContent(map, """
        <url>\
        <loc>url.com</loc>\
        <changefreq>daily</changefreq>\
        <priority>1.0</priority>\
        <lastmod>\(dateStubs.expectedString)</lastmod>\
        </url>
        """)
    }

    func testMonthlyUpdatedLocation() async throws {
        let dateStubs = try Date.makeStubs(withFormattingStyle: .siteMap)

        let map = await SiteMap(.url(
            .loc("url.com"),
            .changefreq(.monthly),
            .priority(1.0),
            .lastmod(dateStubs.date, timeZone: dateStubs.timeZone)
        ))

        await assertEqualSiteMapContent(map, """
        <url>\
        <loc>url.com</loc>\
        <changefreq>monthly</changefreq>\
        <priority>1.0</priority>\
        <lastmod>\(dateStubs.expectedString)</lastmod>\
        </url>
        """)
    }
}
