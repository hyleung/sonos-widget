//
//  SonosCommand.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-01-16.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import Foundation
import AEXML
public struct SonosCommand {
    let serviceType:String
    let version:Int
    let action:String
    let arguments:Dictionary<String,String>?

    public init(serviceType:String, version:Int, action:String, arguments:Dictionary<String, String>?) {
        self.serviceType = serviceType
        self.version = version
        self.action = action
        self.arguments = arguments
    }
    public func serviceNamespace() -> String {
        return "urn:schemas-upnp-org:service:\(serviceType):\(version)"
    }
    public func actionHeader() -> String {
        return "\(serviceNamespace())#\(action)"
    }
    
    public func asXml()  -> String? {
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

public struct SonosService {
    public static let ZoneGroupTopologyService = "ZoneGroupTopology"
    public static let GetZoneGroupStateAction = "GetZoneGroupState"
    public static let AVTransportService = "AVTransport"
    public static let GetTransportInfoAction = "GetTransportInfo"
    public static let PlayAction = "Play"
    public static let PauseAction = "Pause"
    public static let GetPositionInfoAction = "GetPositionInfo"
}