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
    let members:[ZoneGroupMember]?
    
    static func fromZoneGroupElement(e:AEXMLElement) -> ZoneGroup? {
        if  let id = e.attributes["ID"],
            let coordindator = e.attributes["Coordinator"] {
                let groupMembers:[ZoneGroupMember]? = e["ZoneGroupMember"]
                    .all
                    .flatMap(groupMembersFromElementArray)
                return ZoneGroup(groupCoordinator: coordindator, id: id, members: groupMembers)
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
            .flatMap(groupsFromElementArray)
    }
    
    private static func groupMembersFromElementArray(elements:[AEXMLElement]) -> [ZoneGroupMember]? {
        return elements.flatMap({(element:AEXMLElement) in
            return ZoneGroupMember.fromZoneGroupMemberElement(element)
        })
    }
    
    private static func groupsFromElementArray(elements:[AEXMLElement]) -> [ZoneGroup]? {
        return elements.flatMap(fromZoneGroupElement)
    }
}