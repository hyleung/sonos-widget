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
    public let protocolInfo:String
    public let albumArt:String?
    public init(title:String, artist:String?, protocolInfo:String, albumArt:String?) {
        self.title = title
        self.artist = artist
        self.protocolInfo = protocolInfo
        self.albumArt = albumArt
    }
}