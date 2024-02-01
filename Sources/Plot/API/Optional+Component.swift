/**
*  Plot
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE file for details
*/

import Foundation

extension Optional: Renderable, Component where Wrapped: Component {
    public func body() async -> Component {
        await self?.body() ?? EmptyComponent()
    }
}
