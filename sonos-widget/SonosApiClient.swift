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
                    subscriber.onError(err)
                })
            return NopDisposable.instance
        })
    }
    
    static func getZoneGroupState(location:String) -> Observable<NSData> {
        let s = SonosCommand(serviceType: SonosService.ZoneGroupTopologyService, version: 1, action: SonosService.GetZoneGroupStateAction, arguments: .None)
        return SonosApiClient.executeAction({ () in return Client() }, baseUrl: location, path: "/ZoneGroupTopology/Control", command: s)
    }
    
    static func getTransportInfo(location:String) -> Observable<NSData> {
        let s = SonosCommand(serviceType: SonosService.AVTransportService, version: 1, action: SonosService.GetTransportInfoAction, arguments: ["InstanceID":"0"])
        return SonosApiClient.executeAction({ () in return Client() }, baseUrl: location, path: "/MediaRenderer/AVTransport/Control", command: s)
    }
    
    static func toXmlDocument(data:NSData) -> Observable<AEXMLDocument> {
        do {
            return Observable.just(try AEXMLDocument(xmlData: data))
        } catch let err as NSError {
            return Observable.error(err)
        }

    }
}
