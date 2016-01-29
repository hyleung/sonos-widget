//
//  ZoneGroup.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-01-25.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import Foundation
import AEXML

struct ZoneGroup {
    let groupCoordinator:String
    let id:String
    
    static func fromZoneGroupElement(e:AEXMLElement) -> ZoneGroup? {
        if  let id = e.attributes["ID"],
            let coordindator = e.attributes["Coordinator"] {                
                return ZoneGroup(groupCoordinator: coordindator, id: id)
        }
        return .None
    }
    
    static func fromXml(xmlString:String) -> [ZoneGroup]? {
        return xmlString
            .dataUsingEncoding(NSUTF8StringEncoding)?
            .asXmlDocument()
            .flatMap({(xml:AEXMLDocument?) -> [AEXMLElement]? in
                return xml?["ZoneGroups"]["ZoneGroup"].all
            })
            .flatMap({ (elements:[AEXMLElement]?) -> [ZoneGroup]? in
                return elements?.flatMap(fromZoneGroupElement)
            })
    }
}