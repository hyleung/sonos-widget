//
//  DomainDeserializationTests.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-01-25.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import Foundation
import XCTest
@testable import sonos_widget

class DomainSerializationTests: XCTestCase {
    let zoneGroupsData =
"    <ZoneGroups>" +
"   <ZoneGroup Coordinator='RINCON_B8E9373F6D2A01400'" +
"    ID='RINCON_B8E9373F6D2A01400:3'><ZoneGroupMember" +
"    UUID='RINCON_B8E9373F6D2A01400'" +
"    Location='http://192.168.1.73:1400/xml/device_description.xml'" +
"    ZoneName='Dining Room' Icon='x-rincon-roomicon:dining'" +
"    Configuration='1' SoftwareVersion='31.8-24090'" +
"    MinCompatibleVersion='29.0-00000'" +
"    LegacyCompatibleVersion='24.0-00000' BootSeq='17'" +
"    WirelessMode='0' HasConfiguredSSID='1' ChannelFreq='2412'" +
"    BehindWifiExtender='0' WifiEnabled='1' Orientation='3' " +
"    SonarState='4'/><ZoneGroupMember" +
"    UUID='RINCON_B8E937E1FCB401400'" +
"    Location='http://192.168.1.75:1400/xml/device_description.xml'" +
"    ZoneName='Living Room' Icon='x-rincon-roomicon:living'" +
"    Configuration='1' SoftwareVersion='31.8-24090'" +
"    MinCompatibleVersion='29.0-00000'" +
"    LegacyCompatibleVersion='24.0-00000' BootSeq='38'" +
"    WirelessMode='0' HasConfiguredSSID='1' ChannelFreq='2412'" +
"    BehindWifiExtender='0' WifiEnabled='1' Orientation='0'" +
"    SonarState='4'/><ZoneGroupMember" +
"    UUID='RINCON_B8E93781D11001400'" +
"    Location='http://192.168.1.65:1400/xml/device_description.xml' " +
"    ZoneName='Bedroom' Icon='x-rincon-roomicon:bedroom'" +
"    Configuration='1' SoftwareVersion='31.8-24090'" +
"    MinCompatibleVersion='29.0-00000' " +
"    LegacyCompatibleVersion='24.0-00000' BootSeq='40'" +
"    WirelessMode='0' HasConfiguredSSID='1' ChannelFreq='2412'" +
"    BehindWifiExtender='0' WifiEnabled='1' Orientation='0'" +
"    SonarState='4'/></ZoneGroup>" +
"    <ZoneGroup" +
"    Coordinator='RINCON_B8E937E2002801400'" +
"    ID='RINCON_B8E937E2002801400:7'><ZoneGroupMember" +
"    UUID='RINCON_B8E937E2002801400'" +
"    Location='http://192.168.1.74:1400/xml/device_description.xml'" +
"   ZoneName='Olivia&amp;apos;s Room'" +
"    Icon='x-rincon-roomicon:living' Configuration='1'" +
"    SoftwareVersion='31.8-24090' MinCompatibleVersion='29.0-00000'" +
"    LegacyCompatibleVersion='24.0-00000' BootSeq='17'" +
"    WirelessMode='0' HasConfiguredSSID='1' ChannelFreq='2412'" +
"    BehindWifiExtender='0' WifiEnabled='1' Orientation='0'" +
"    SonarState='1'/></ZoneGroup>" +
"    </ZoneGroups>"
    
    
    let zoneGroupMemberData =
    "   <ZoneGroupMember" +
    "    UUID='RINCON_B8E9373F6D2A01400'" +
    "    Location='http://192.168.1.73:1400/xml/device_description.xml'" +
    "    ZoneName='Dining Room' Icon='x-rincon-roomicon:dining'" +
    "    Configuration='1' SoftwareVersion='31.8-24090'" +
    "    MinCompatibleVersion='29.0-00000'" +
    "    LegacyCompatibleVersion='24.0-00000' BootSeq='17'" +
    "    WirelessMode='0' HasConfiguredSSID='1' ChannelFreq='2412'" +
    "    BehindWifiExtender='0' WifiEnabled='1' Orientation='3' " +
    "    SonarState='4'/>"
    
    
    func testZoneGroupDeserialization() {
        let zoneGroups = ZoneGroup.fromXml(zoneGroupsData)
        XCTAssertNotNil(zoneGroups)
        XCTAssertEqual(2, zoneGroups?.count)
        let groupOne = zoneGroups?[0]
        XCTAssertEqual("RINCON_B8E9373F6D2A01400", groupOne?.groupCoordinator)
        XCTAssertEqual("RINCON_B8E9373F6D2A01400:3", groupOne?.id)
    }
    
    func testZoneGroupMemberDeserialization() {
        let zoneGroupMember = ZoneGroupMember.fromXml(zoneGroupMemberData)
        XCTAssertNotNil(zoneGroupMember)
        
    }
}



