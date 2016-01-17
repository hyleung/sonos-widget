//
//  SonosCommandTest.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-01-16.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import XCTest
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
        let s = SonosCommand(serviceType: "ZoneGroupTopology", version: 1, action: "GetZoneGroupState", arguments: .None)
        print("xml: \(s.asXml()!)")
        XCTAssertNotNil(s.asXml())
    }


}
