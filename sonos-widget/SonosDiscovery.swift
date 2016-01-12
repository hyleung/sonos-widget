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

    
    func performDiscovery() -> Observable<String> {
        socket = GCDAsyncUdpSocket(delegate:nil, delegateQueue:dispatch_get_main_queue())
        return rxDiscovery(socket!)
            .map{ data in
                return String(data:data, encoding: NSUTF8StringEncoding)!
            }.filter{ s in
                return s.containsString("Sonos")
        }
    }
    
    
    func rxDiscovery(socket:GCDAsyncUdpSocket) -> Observable<NSData> {
        return Observable.create{ observer -> Disposable in {
            logger.debug("creating observable")
            
            do {
                socket.rx_data.subscribe(observer)
                try socket.bindToPort(1900)
                try socket.joinMulticastGroup("239.255.255.250")
                logger.debug("joined multi-cast group")
                let message = "M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: \"ssdp:discover\"\r\nMX: 1\r\nST: urn:schemas-upnp-org:device:ZonePlayer:1"
                let data = message.dataUsingEncoding(NSUTF8StringEncoding)
                try socket.beginReceiving()
                socket.sendData(data, toHost: "239.255.255.250" , port: 1900, withTimeout: 100, tag: 0)
                logger.debug("sent")
                
            } catch let err as NSError {
                observer.onError(err)
            }
                return NopDisposable.instance
            }()
        }
    }

    
    func unbind() {
        do {
            try socket?.leaveMulticastGroup("239.255.255.250")
            logger.debug("left multi-cast group")
        } catch let error as NSError {
            logger.error("failed \(error)")
        }
    }
    

}



