//
//  ZoneGroupMember.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-01-26.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import Foundation
import AEXML

public struct ZoneGroupMember {
    public let zoneName:String
    public let uuid:String
    public let location:NSURL
    
    public static func fromZoneGroupMemberElement(element:AEXMLElement) -> ZoneGroupMember? {
        if  let zoneName = element.attributes["ZoneName"],
            let uuid = element.attributes["UUID"],
            let location = element.attributes["Location"],
            let locationUrl = NSURL(string:location) {
                return ZoneGroupMember(zoneName: zoneName, uuid: uuid, location: locationUrl)
        } else {
            return .None
        }
    }
    public static func fromXml(xmlString:String) -> ZoneGroupMember? {
        return xmlString
            .dataUsingEncoding(NSUTF8StringEncoding)?
            .asXmlDocument()
            .flatMap({(xml:AEXMLDocument?) -> AEXMLElement? in
                return xml?["ZoneGroupMember"].first
            })
            .flatMap(fromZoneGroupMemberElement)
    }
}