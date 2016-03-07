//
//  SonosGroupCellViewModel.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-02-25.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//
import Foundation

class SonosGroupCellViewModel:NSObject {
    let title:String
    let locationUrl:String
    let groupState:String
    
    init(title:String, locationUrl:String, groupState:String) {
        self.title = title
        self.locationUrl = locationUrl
        self.groupState = groupState
    }
}