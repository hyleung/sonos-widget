//
//  GCDAsyncUdpSocket+Rx.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-01-07.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import CocoaAsyncSocket
import RxSwift
import RxCocoa
extension GCDAsyncUdpSocket {
    public var rx_delegate:DelegateProxy {
        return proxyForObject(RxGCDAsyncUdpSocketDelegateProxy.self,self)
    }
    public var rx_data:Observable<NSData> {
        return rx_delegate.observe("udpSocket:didReceiveData:fromAddress:withFilterContext:")
            .map{ a in return a[1] as! NSData }
    }
    
}