//
//  SonosCommandTest.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-01-16.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import XCTest
import SwiftClient
import AEXML
import RxSwift
@testable import sonos_widget
class SonosCommandTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testShouldSerializeToSoapRequest() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let s = SonosCommand(serviceType: SonosService.ZoneGroupTopologyService, version: 1, action: SonosService.GetZoneGroupStateAction, arguments: .None)
        logger.debug("xml: \(s.asXml()!)")
        XCTAssertNotNil(s.asXml())
    }

    func testSoapRequestShouldContain() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let s = SonosCommand(serviceType: SonosService.ZoneGroupTopologyService, version: 1, action: SonosService.GetZoneGroupStateAction, arguments: .None)
        XCTAssertTrue(s.asXml()!.containsString(s.actionHeader()))
        XCTAssertNotNil(s.asXml())
    }
    
    func testShouldReturnActionHeader() {
        let s = SonosCommand(serviceType: SonosService.ZoneGroupTopologyService, version: 1, action: SonosService.GetZoneGroupStateAction, arguments: .None)
        XCTAssertEqual("urn:schemas-upnp-org:service:serviceType:ZoneGroupTopology:1#GetZoneGroupState", s.actionHeader())
    }
    
    func testShouldSerializeArgs() {
        let s = SonosCommand(serviceType: SonosService.AVTransportService, version: 1, action: SonosService.GetTransportInfoAction, arguments: ["InstanceId":"1"])
        let xml = s.asXml()?.dataUsingEncoding(NSUTF8StringEncoding)?.asXmlDocument()
        print(xml!.xmlString)
        let body = xml!["s:Envelope"]["s:Body"]
        XCTAssertNotNil(body)
        let content = body["u:GetTransportInfo"]
        XCTAssertNotNil(content)
        let params = content["InstanceId"]
        XCTAssertEqual("1", params.value)
    }
    
    func testZoneGroupToplogyRequest() {
        let s = SonosCommand(serviceType: SonosService.ZoneGroupTopologyService, version: 1, action: SonosService.GetZoneGroupStateAction, arguments: .None)

        let observable = SonosApiClient.executeAction({ () in return Client()}, baseUrl: "http://192.168.1.73:1400", path: "/ZoneGroupTopology/Control", command: s)
        do {
            let result = try observable.toBlocking().first()
            logger.debug(closure: { () in
                return (NSString(data:result!, encoding:NSUTF8StringEncoding)! as String)
            })
            XCTAssertNotNil(result)
        } catch let err as NSError {
            XCTFail("failed: \(err.domain)")
        }
    }
    
    func testGetTransportInfo() {
        SonosApiClient.getTransportInfo("http://192.168.1.73:1400")
            .flatMap(SonosApiClient.toXmlDocument)
            .doOn(onNext: { (doc:AEXMLDocument) -> Void in
                print(doc.xmlString)
                },
                onError: { (err) -> Void in
                    print(err)
                },
                onCompleted:nil )
            .subscribe()
            .dispose()
    }
    
}
