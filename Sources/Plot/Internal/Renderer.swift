/**
*  Plot
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE file for details
*/

internal struct Renderer {
    private(set) var result = ""
    private(set) var deferredAttributes = [AnyAttribute]()

    private let indentation: Indentation?
    private var environment: Environment
    private var elementWrapper: ElementWrapper?
    private var elementBuffer: ElementRenderingBuffer?
    private var containsElement = false
}

extension Renderer {
    static func render(
        _ node: AnyNode,
        indentedBy indentationKind: Indentation.Kind?
    ) async -> String {
        var renderer = Renderer(indentationKind: indentationKind)
        await node.render(into: &renderer)
        return renderer.result
    }

    init(indentationKind: Indentation.Kind?) {
        self.indentation = indentationKind.map(Indentation.init)
        self.environment = Environment()
    }

    mutating func renderRawText(_ text: String) async {
        await renderRawText(text, isPlainText: true, wrapIfNeeded: true)
    }

    mutating func renderText(_ text: String) async {
        await renderRawText(text.escaped())
    }

    mutating func renderElement<T>(_ element: Element<T>) async {
        if let wrapper = elementWrapper {
            guard element.name == wrapper.wrappingElementName else {
                if deferredAttributes.isEmpty {
                    return await renderComponent(
                        wrapper.body(Node.element(element)),
                        deferredAttributes: wrapper.deferredAttributes
                    )
                } else {
                    return await renderComponent(
                        wrapper.body(ModifiedComponent(
                            base: Node.element(element),
                            deferredAttributes: deferredAttributes
                        ))
                    )
                }
            }
        }

        let buffer = ElementRenderingBuffer(
            element: element,
            indentation: indentation
        )

        var renderer = Renderer(
            indentation: indentation?.indented(),
            environment: environment,
            elementBuffer: buffer
        )
        
        for node in element.nodes {
            await node.render(into: &renderer)
        }

        deferredAttributes.forEach(buffer.add)
        elementBuffer?.containsChildElements = true
        containsElement = true

        await renderRawText(buffer.flush(),
            isPlainText: false,
            wrapIfNeeded: false
        )
    }

    mutating func renderAttribute<T>(_ attribute: Attribute<T>) {
        if let elementBuffer = elementBuffer {
            elementBuffer.add(attribute)
        } else {
            result.append(attribute.render())
        }
    }

    mutating func renderComponent(
        _ component: Component,
        deferredAttributes: [AnyAttribute] = [],
        environmentOverrides: [Environment.Override] = [],
        elementWrapper: ElementWrapper? = nil
    ) async {
        var environment = self.environment
        environmentOverrides.forEach { $0.apply(to: &environment) }

        if !(component is AnyNode || component is AnyElement) {
            let componentMirror = Mirror(reflecting: component)

            for property in componentMirror.children {
                if let environmentValue = property.value as? AnyEnvironmentValue {
                    environmentValue.environment.value = environment
                }
            }
        }

        var renderer = Renderer(
            deferredAttributes: deferredAttributes,
            indentation: indentation,
            environment: environment,
            elementWrapper: elementWrapper
        )

        if let node = component as? AnyNode {
            await node.render(into: &renderer)
        } else {
            await renderer.renderComponent(await component.body(),
                deferredAttributes: deferredAttributes,
                elementWrapper: elementWrapper ?? self.elementWrapper
            )
        }

        await renderRawText(renderer.result,
            isPlainText: !renderer.containsElement,
            wrapIfNeeded: false
        )

        containsElement = renderer.containsElement
    }
}

private extension Renderer {
    mutating func renderRawText(
        _ text: String,
        isPlainText: Bool,
        wrapIfNeeded: Bool
    ) async {
        if wrapIfNeeded {
            if let wrapper = elementWrapper {
                return await renderComponent(wrapper.body(Node<Any>.raw(text)))
            }
        }

        if let elementBuffer = elementBuffer {
            elementBuffer.add(text, isPlainText: isPlainText)
        } else {
            if indentation != nil && !result.isEmpty {
                result.append("\n")
            }

            result.append(text)
        }
    }
}
