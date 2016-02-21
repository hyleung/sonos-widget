//
//  String+Ext.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-01-22.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import Foundation

public extension String {
    func unescapeXml() -> String {
        return self.stringByReplacingOccurrencesOfString("&lt;", withString: "<")
            .stringByReplacingOccurrencesOfString("&gt;", withString: ">")
            .stringByReplacingOccurrencesOfString("&quot;", withString: "'")
            .stringByReplacingOccurrencesOfString("\t", withString: "")
            .stringByReplacingOccurrencesOfString("\r", withString: "")
            .stringByReplacingOccurrencesOfString("&apos;", withString: "'")
    }
}