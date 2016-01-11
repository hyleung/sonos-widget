//
//  SonosDiscovery.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-01-04.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//
import CocoaAsyncSocket
import RxSwift
import RxCocoa
import XCGLogger

class SonosDiscoveryClient {
 
    var socket:GCDAsyncUdpSocket?

    func performDiscovery(onSuccess:(String) -> (), onFailure:(NSError) -> ()) {
        
        socket = GCDAsyncUdpSocket(delegate:nil, delegateQueue:dispatch_get_main_queue())
        do {
            let _ = socket?.rx_data.subscribeNext({ (data:NSData) -> Void in
                let s = String(data:data, encoding: NSUTF8StringEncoding)
                    if (s!.containsString("Sonos")) {
                        onSuccess(s!)
                    } else {
                        log.debug("received")
                }

            })
            try socket?.bindToPort(1900)
            try socket?.joinMulticastGroup("239.255.255.250")
            log.debug("joined multi-cast group")
            let message = "M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: \"ssdp:discover\"\r\nMX: 1\r\nST: urn:schemas-upnp-org:device:ZonePlayer:1"
            let data = message.dataUsingEncoding(NSUTF8StringEncoding)
            try socket?.beginReceiving()
            socket?.sendData(data, toHost: "239.255.255.250" , port: 1900, withTimeout: 100, tag: 0)
            
            log.debug("sent")
            
        } catch let error as NSError {
            onFailure(error)
        }
    }
    

    
    func unbind() {
        do {
            try socket?.leaveMulticastGroup("239.255.255.250")
            log.debug("left multi-cast group")
        } catch let error as NSError {
            log.error("failed \(error)")
        }
    }
    

}



