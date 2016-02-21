//
//  SonosClient.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-02-20.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import Foundation
import XCGLogger

//Logger
let logger:XCGLogger = {
    let log = XCGLogger.defaultInstance()
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy hh:mm:sss"
    dateFormatter.locale = NSLocale.currentLocale()
    log.dateFormatter = dateFormatter
    return log
}()