/**
*  Plot
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE file for details
*/

import Foundation

internal struct ElementWrapper {
    var wrappingElementName: String
    var deferredAttributes = [AnyAttribute]()
    var body: (Component) async -> Component
}

extension ElementWrapper {
    init(wrappingElementName: String) {
        self.wrappingElementName = wrappingElementName
        self.body = {
            Element(name: wrappingElementName, nodes: [
                await Node<Any>.component($0)
            ])
        }
    }
}
