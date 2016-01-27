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
    
    static func fromXml(xmlString:String) -> ZoneGroupMember? {
        return xmlString
            .dataUsingEncoding(NSUTF8StringEncoding)
            .map({(data:NSData) -> AEXMLDocument? in
                do {
                    return try AEXMLDocument(xmlData: data)
                } catch {
                    return .None
                }
            })
            .flatMap({(xml:AEXMLDocument?) -> AEXMLElement? in
                return xml?["ZoneGroupMember"].first
            })
            .flatMap({(element:AEXMLElement) -> ZoneGroupMember? in
                if  let zoneName = element.attributes["ZoneName"],
                    let uuid = element.attributes["UUID"],
                    let location = element.attributes["Location"] {
                        return ZoneGroupMember(zoneName: zoneName, uuid: uuid, location: location)
                } else {
                    return .None
                }
            })
    }
}