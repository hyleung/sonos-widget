//
//  SonosDiscoveryTest.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-01-14.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
@testable import sonos_widget


class SonosDiscoveryTest: XCTestCase {

    let data:String = " HTTP/1.1 200 OK\r\n" +
        "CACHE-CONTROL: max-age = 1800\r\n" +
        "EXT:\r\n" +
        "LOCATION: http://192.168.1.65:1400/xml/device_description.xml\r\n" +
        "SERVER: Linux UPnP/1.0 Sonos/31.8-24090 (ZPS1)\r\n" +
        "ST: urn:schemas-upnp-org:device:ZonePlayer:1\r\n" +
        "USN: uuid:RINCON_B8E93781D11001400::urn:schemas-upnp-org:device:ZonePlayer:1\r\n" +
        "X-RINCON-HOUSEHOLD: Sonos_iROH6kmkXYSpfYZTTyCYZMC6jH\r\n" +
        "X-RINCON-BOOTSEQ: 40\r\n" +
    "X-RINCON-WIFIMODE: 0\r\n"
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testShouldParseDictionary()  {

        
        let observable = Observable.just(data)
        do {
            let result = try SonosDiscoveryClient.parseDiscoveryResponse(observable).toBlocking().single()
            assert(result!.count > 0)
        } catch let err as NSError {
            XCTFail("parsing failed: \(err.domain)")
        }
    }
    
    func testShouldParseDictionaryWithKey()  {
        
        let observable = Observable.just(data)
        do {
            let result = try SonosDiscoveryClient.parseDiscoveryResponse(observable).toBlocking().single()
            assert(result!["LOCATION"] != nil)
            assert(result!["LOCATION"] == "http://192.168.1.65:1400/xml/device_description.xml")
            
        } catch let err as NSError {
            XCTFail("parsing failed: \(err.domain)")
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
