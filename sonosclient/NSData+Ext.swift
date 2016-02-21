//
//  NSData+Ext.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-01-27.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import Foundation
import AEXML
public extension NSData {
    func asXmlDocument() -> AEXMLDocument? {
        do {
            return try AEXMLDocument(xmlData: self)
        } catch {
            return .None
        }
    }
}
