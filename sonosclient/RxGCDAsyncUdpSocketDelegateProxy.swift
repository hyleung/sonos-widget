//
//  RxGCDAsyncUdpSocketDelegateProxy.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-01-07.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import CocoaAsyncSocket
import RxSwift
import RxCocoa

class RxGCDAsyncUdpSocketDelegateProxy:DelegateProxy, GCDAsyncUdpSocketDelegate, DelegateProxyType {
    
    
    class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let socket:GCDAsyncUdpSocket = object as! GCDAsyncUdpSocket
        return socket.delegate()
    }
    class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let socket:GCDAsyncUdpSocket = object as! GCDAsyncUdpSocket
        socket.setDelegate(delegate)
    }
    
}