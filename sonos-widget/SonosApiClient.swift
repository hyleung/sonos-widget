//
//  SonosApiClient.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-01-19.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import Foundation
import SwiftClient
import RxSwift
import AEXML
class SonosApiClient {
    static func executeAction(client:() -> Client, baseUrl:String, path:String, command: SonosCommand) -> Observable<NSData> {

        return Observable.create({ subscriber in
            Client()
                .baseUrl(baseUrl)
                .post(path)
                .set("SOAPACTION", command.actionHeader())
                .type("text/xml")
                .send(command.asXml()!)
                .end({resp in
                    if let data = resp.data {
                        subscriber.onNext(data)
                    } else {
                        logger.debug("No data returned from POST call to \(baseUrl)\(path)")
                    }
                    subscriber.onCompleted()
                }, onError: { err in
                    logger.error("error occurred: \(err)")
                    subscriber.onError(err)
                })
            return NopDisposable.instance
        })
    }
    
    static func getZoneGroupState(location:String) -> Observable<NSData> {
        let s = SonosCommand(serviceType: SonosService.ZoneGroupTopologyService, version: 1, action: SonosService.GetZoneGroupStateAction, arguments: .None)
        return SonosApiClient.executeAction({ () in return Client() }, baseUrl: location, path: "/ZoneGroupTopology/Control", command: s)
    }

    static func rx_getZoneGroupState(location:String) -> Observable<[ZoneGroup]> {
        return getZoneGroupState(location)
            .flatMap(toXmlDocument)
            .map({ xml -> String in
                return xml["s:Envelope"]["s:Body"]["u:GetZoneGroupStateResponse"]["ZoneGroupState"]
                .xmlString.unescapeXml()
            })
            .map({ zoneGroupState -> [AEXMLElement] in
                //logger.info(zoneGroupState)
                let xml = try AEXMLDocument(xmlData: zoneGroupState.dataUsingEncoding(NSUTF8StringEncoding)!)
                return xml["ZoneGroupState"]["ZoneGroups"]["ZoneGroup"].all!
            })
            .map({(elems:[AEXMLElement]) in
                return ZoneGroup.groupsFromElementArray(elems)!.sort({ (g1, g2) -> Bool in
                    g1.members?.count > g2.members?.count
                })
            })
    }

    static func getTransportInfo(location:String) -> Observable<NSData> {
        let s = SonosCommand(serviceType: SonosService.AVTransportService, version: 1, action: SonosService.GetTransportInfoAction, arguments: ["InstanceID":"0"])
        return SonosApiClient.executeAction({ () in return Client() }, baseUrl: location, path: "/MediaRenderer/AVTransport/Control", command: s)
    }

    static func rx_getTransportInfo(location:String) -> Observable<AEXMLElement> {
        return getTransportInfo(location)
            .flatMap(toXmlDocument)
            .map({ xml -> AEXMLElement in
                    return xml["s:Envelope"]["s:Body"]["u:GetTransportInfoResponse"]
            })
    }

    static func play(location:String) -> Observable<NSData> {
        let s = SonosCommand(serviceType: SonosService.AVTransportService, version: 1, action: SonosService.PlayAction, arguments: ["InstanceID":"0", "Speed":"1"])
        return executeAction({() in return Client()}, baseUrl: location, path: "/MediaRenderer/AVTransport/Control", command: s)
    }

    static func pause(location:String) -> Observable<NSData> {
        let s = SonosCommand(serviceType: SonosService.AVTransportService, version: 1, action: SonosService.PauseAction, arguments: ["InstanceID":"0", "Speed":"1"])
        return executeAction({() in return Client()}, baseUrl: location, path: "/MediaRenderer/AVTransport/Control", command: s)
    }

    
    static func getPositionInfo(location:String) -> Observable<NSData> {
        let s = SonosCommand(serviceType: SonosService.AVTransportService, version: 1, action: SonosService.GetPositionInfoAction, arguments: ["InstanceID":"0"])
        return executeAction({() in return Client()}, baseUrl: location, path: "/MediaRenderer/AVTransport/Control", command: s)
    }
    
    static func getCurrentTrackMetaData(location:String) -> Observable<AEXMLDocument> {
        return getPositionInfo(location)
            .flatMap(toXmlDocument)
            .flatMap({ (document) -> Observable<AEXMLDocument> in
                if let trackMetaData = document["s:Envelope"]["s:Body"]["u:GetPositionInfoResponse"]["TrackMetaData"].value?.unescapeXml(),
                    let trackNSData = trackMetaData.dataUsingEncoding(NSUTF8StringEncoding) {
                    do {
                        let result = try AEXMLDocument(xmlData:trackNSData)
                        logger.debug(result.xmlString)
                        return Observable.just(result)
                    }
                    catch let err as NSError {
                        return Observable.error(err)
                    }
                }
                //empty document
                return Observable.just(AEXMLDocument())
            })
    }
    
    static func toXmlDocument(data:NSData) -> Observable<AEXMLDocument> {
        do {
            // logger.debug(data.asXmlDocument()?.xmlString)
            return Observable.just(try AEXMLDocument(xmlData: data))
        } catch let err as NSError {
            return Observable.error(err)
        }
    }
}
