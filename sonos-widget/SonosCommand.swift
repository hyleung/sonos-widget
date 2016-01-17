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

    func asXml()  -> String? {
        let soapRequest = AEXMLDocument()
        let attributes = ["xmlns:s":"http://schemas.xmlsoap.org/soap/envelope/",
        "s:encodingStyle": "http://schemas.xmlsoap.org/soap/encoding/"]
        let envelope = soapRequest.addChild(name: "s:Envelope", attributes: attributes)
        let body = envelope.addChild(name:"s:Body")
        body.addChild(name: "u:actionName", attributes: ["xmlns:u": "urn:schemas-upnp-org:service:serviceType:v"])
        return soapRequest.xmlString
    }
}