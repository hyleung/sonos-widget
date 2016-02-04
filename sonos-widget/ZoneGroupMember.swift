//
//  ZoneGroupMember.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-01-26.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import Foundation
import AEXML

struct ZoneGroupMember {
    let zoneName:String
    let uuid:String
    let location:String
    
    static func fromZoneGroupMemberElement(element:AEXMLElement) -> ZoneGroupMember? {
        if  let zoneName = element.attributes["ZoneName"],
            let uuid = element.attributes["UUID"],
            let location = element.attributes["Location"] {
                return ZoneGroupMember(zoneName: zoneName, uuid: uuid, location: location)
        } else {
            return .None
        }
    }
    static func fromXml(xmlString:String) -> ZoneGroupMember? {
        return xmlString
            .dataUsingEncoding(NSUTF8StringEncoding)?
            .asXmlDocument()
            .flatMap({(xml:AEXMLDocument?) -> AEXMLElement? in
                return xml?["ZoneGroupMember"].first
            })
            .flatMap(fromZoneGroupMemberElement)
    }
}