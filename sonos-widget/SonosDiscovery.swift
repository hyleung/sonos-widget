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
        let msg = "M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: \"ssdp:discover\"\r\nMX: 1\r\nST: urn:schemas-upnp-org:device:ZonePlayer:1"
        return rxSendMulticast(socket!, host:"239.255.255.250", port:1900, message: msg)
            .map{ data in
                return String(data:data, encoding: NSUTF8StringEncoding)!
            }.filter{ s in
                return s.containsString("Sonos")
            }.take(1)
            . doOn(onNext: { (s:String) -> Void in

                }, onError: { (err) -> Void in
                    logger.error("Error: \(err)")
                    logger.debug("leaving multicast group")
                    try self.socket?.leaveMulticastGroup("239.255.255.250")
                }, onCompleted: { () -> Void in
                    logger.debug("completed")
                    logger.debug("leaving multicast group")
                    try self.socket?.leaveMulticastGroup("239.255.255.250")
            })
    }
    
    static func performZoneQuery() -> Observable<String> {
        return Observable.empty()
    }
    
    static func parseDiscoveryResponse(response:Observable<String>) -> Observable<Dictionary<String,String>> {
        return response.map{ s in self.lines(s) }
            .map{ line in self.parseMap(line) }
    }
    
    static private func lines(s:String) -> [String] {
        return s.characters.split{$0 == "\r\n"}.map{String($0)}
    }
    
    static private func parseMap(lines:[String]) -> Dictionary<String,String> {
        var result:Dictionary<String,String> = Dictionary()
        for line in lines {
            if let idx = line.characters.indexOf(":") {
                let k = line.substringToIndex(idx)
                let v = String(line.substringFromIndex(idx.advancedBy(1)).characters.dropFirst())
                result[k] = v
            }
        }
        return result
    }
    
    
    private func rxSendMulticast(socket:GCDAsyncUdpSocket, host:String, port:UInt16, message:String) -> Observable<NSData> {
        return Observable.create{ observer -> Disposable in {
            logger.debug("creating observable")
            
            do {
                socket.rx_data.subscribe(observer)
                try socket.bindToPort(port)
                try socket.joinMulticastGroup(host)
                logger.debug("joined multi-cast group")
                let data = message.dataUsingEncoding(NSUTF8StringEncoding)
                try socket.beginReceiving()
                socket.sendData(data, toHost: host , port: port, withTimeout: 100, tag: 0)
                logger.debug("sent")
                
            } catch let err as NSError {
                observer.onError(err)
            }
                return NopDisposable.instance
            }()
        }
    }    

}



