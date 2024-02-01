/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

/// A representation of an element within a document, such as an HTML or XML tag.
/// You normally don't construct `Element` values manually, but rather use Plot's
/// various DSL APIs to create them, for example by creating a `<body>` tag using
/// `.body()`, or a `<p>` tag using `.p()`.
public struct Element<Context>: AnyElement {
    /// The name of the element
    public var name: String
    /// How the element is closed, for example if it's self-closing or if it can
    /// contain child elements.
    public var closingMode: ClosingMode = .standard

    internal var nodes: [AnyNode]
    internal var paddingCharacter: Character? = nil
}

public extension Element {
    /// Convenience shorthand for `ElementClosingMode`.
    typealias ClosingMode = ElementClosingMode

    /// Create a custom element with a given name and array of child nodes.
    /// - parameter name: The name of the element to create.
    /// - parameter nodes: The nodes (child elements + attributes) to add to the element.
    static func named(_ name: String, nodes: [Node<Any>]) -> Element {
        Element(name: name, nodes: nodes)
    }

    /// Create a custom self-closed element with a given name and array of attributes.
    /// - parameter name: The name of the element to create.
    /// - parameter attributes The attributes to add to the element.
    static func selfClosed(named name: String,
                           attributes: [Attribute<Any>]) async -> Element {
        await Element(name: name, closingMode: .selfClosing, nodes: attributes.asyncMap { await $0.node() })
    }
}

extension Element: NodeConvertible {
    public func node() async -> Node<Context> { .element(self) }
}

extension Element: Component where Context == Any {
    //public var body: Component { node }
    public func body() async -> Component { await node() }

    public init(
        name: String,
        @ComponentBuilder content: @escaping ContentProvider
    ) async {
        await self.init(name: name, nodes: [Node<Any>.component(await content())])
    }
}
