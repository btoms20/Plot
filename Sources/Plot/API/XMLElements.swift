/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

public extension Element where Context: XMLRootContext {
    /// Add an XML declaration node within the current context.
    /// - parameter attributes: The declaration's attributes.
    static func xml(_ attributes: Attribute<XML.DeclarationContext>...) async -> Element {
        await Element(name: "xml",
                closingMode: .neverClosed,
                nodes: attributes.asyncMap { await $0.node() },
                paddingCharacter: "?")
    }
}
