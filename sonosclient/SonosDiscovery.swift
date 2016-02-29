//
//  SonosDiscovery.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-01-04.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//
import CocoaAsyncSocket
import RxSwift
import XCGLogger

public class SonosDiscoveryClient {
    static let multicast_port:UInt16 = 1900
    public static func performDiscovery() -> Observable<String> {
        let msg = "M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:\(multicast_port)\r\nMAN: \"ssdp:discover\"\r\nMX: 1\r\nST: urn:schemas-upnp-org:device:ZonePlayer:1"
        return rxSendMulticast("239.255.255.250", port:multicast_port, message: msg)
    }
    
    public static func performZoneQuery() -> Observable<String> {
        return SonosDiscoveryClient.parseDiscoveryResponse(SonosDiscoveryClient
            .performDiscovery())
            .flatMap({resp -> Observable<String> in
                if let location = resp["LOCATION"] {
                    if let url = NSURL(string: location) {
                        let baseUrl = "http://\(url.host!):\(url.port!)"
                        return Observable.just(baseUrl)
                    }
                }
                return Observable.empty()
            })
    }
    
    public static func parseDiscoveryResponse(response:Observable<String>) -> Observable<Dictionary<String,String>> {
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
    
    
    static private func rxSendMulticast(host:String, port:UInt16, message:String) -> Observable<String> {
        return Observable.create{ observer -> Disposable in {
            logger.debug("creating observable")

            do {
                let socket = GCDAsyncUdpSocket(delegate:nil, delegateQueue:dispatch_get_main_queue())
                func cleanUp() {
                    do {
                        logger.debug("leaving multicast group")
                        try socket?.leaveMulticastGroup("239.255.255.250")
                    } catch let err as NSError {
                        logger.error("Error cleaning up: \(err)")
                    }
                    socket.close()
                }
                socket.rx_data
                    .map{ data in
                        return String(data:data, encoding: NSUTF8StringEncoding)!
                    }
                    .filter{ s in
                        return s.containsString("Sonos")
                    }.take(1)
                    . doOn(onNext: nil,
                        onError: { (err) -> Void in
                            logger.error("Error: \(err)")
                            cleanUp()
                        }, onCompleted: { () -> Void in
                            logger.debug("completed")
                            cleanUp()
                    })
                    .subscribe(observer)
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



