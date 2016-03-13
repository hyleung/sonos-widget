//
//  AEXMLElement+Optional.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-03-12.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import Foundation
import AEXML
public extension AEXMLElement {
    func optional() -> String? {
        if self.name == AEXMLElement.errorElementName {
            return .None
        }
        return self.value
    }
}