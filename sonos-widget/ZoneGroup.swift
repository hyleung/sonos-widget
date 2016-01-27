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
    
    static func fromXml(xmlString:String) -> [ZoneGroup]? {
        return xmlString
            .dataUsingEncoding(NSUTF8StringEncoding)
            .map({(data:NSData) -> AEXMLDocument? in
                do {
                    return try AEXMLDocument(xmlData: data)
                } catch {
                    return .None
                }
            })
            .flatMap({(xml:AEXMLDocument?) -> [AEXMLElement]? in
                return xml?["ZoneGroups"]["ZoneGroup"].all
            })
            .flatMap({ (elements:[AEXMLElement]?) -> [ZoneGroup]? in
                return elements?.flatMap({(e:AEXMLElement) -> ZoneGroup? in
                    if  let id = e.attributes["ID"],
                        let coordindator = e.attributes["Coordinator"] {
                        
                        return ZoneGroup(groupCoordinator: coordindator, id: id)
                    }
                    return .None
                })
            })
    }
}