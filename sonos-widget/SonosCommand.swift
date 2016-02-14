//
//  SonosCommand.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-01-16.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import Foundation
import AEXML
struct SonosCommand {
    let serviceType:String
    let version:Int
    let action:String
    let arguments:Dictionary<String,String>?

    func serviceNamespace() -> String {
        return "urn:schemas-upnp-org:service:\(serviceType):\(version)"
    }
    func actionHeader() -> String {
        return "\(serviceNamespace())#\(action)"
    }
    
    func asXml()  -> String? {
        let soapRequest = AEXMLDocument()
        let attributes = ["xmlns:s":"http://schemas.xmlsoap.org/soap/envelope/",
        "s:encodingStyle": "http://schemas.xmlsoap.org/soap/encoding/"]
        let envelope = soapRequest.addChild(name: "s:Envelope", attributes: attributes)
        let body = envelope.addChild(name:"s:Body")
        let actionElement = body.addChild(name: "u:\(action)", attributes: ["xmlns:u": serviceNamespace()])
        
        arguments?.forEach({ (k,v) -> Void in
            actionElement.addChild(name: k, value: v, attributes: nil)
        })
        
        return soapRequest.xmlString
    }

}

struct SonosService {
    static let ZoneGroupTopologyService = "ZoneGroupTopology"
    static let GetZoneGroupStateAction = "GetZoneGroupState"
    static let AVTransportService = "AVTransport"
    static let GetTransportInfoAction = "GetTransportInfo"
    static let PlayAction = "Play"
    static let PauseAction = "Pause"
    static let GetPositionInfoAction = "GetPositionInfo"
}