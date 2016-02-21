//
//  TrackInfo.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-02-18.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

public struct TrackInfo {
    public let title:String
    public let artist:String?
    public init(title:String, artist:String?) {
        self.title = title;
        self.artist = artist
    }
}