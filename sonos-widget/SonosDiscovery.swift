//
//  SonosDiscovery.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-01-04.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import CocoaAsyncSocket

class SonosDiscoveryClient {
 
    var socket:GCDAsyncUdpSocket?
    var socketDelegate:SocketDelegate?
    
    func performDiscovery(onSuccess:(String) -> (), onFailure:(NSError) -> ()) {

        socketDelegate = SocketDelegate(onSuccess: onSuccess, onFailure: onFailure)
        socket = GCDAsyncUdpSocket(delegate:socketDelegate, delegateQueue:dispatch_get_main_queue())
        do {
            try socket?.bindToPort(1900)
            try socket?.joinMulticastGroup("239.255.255.250")
            print("joined multi-cast group")
            let message = "M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: \"ssdp:discover\"\r\nMX: 1\r\nST: urn:schemas-upnp-org:device:ZonePlayer:1"
            let data = message.dataUsingEncoding(NSUTF8StringEncoding)
            try socket?.beginReceiving()
            
            socket?.sendData(data, toHost: "239.255.255.250" , port: 1900, withTimeout: 100, tag: 0)
            print("sent")
            
        } catch let error as NSError {
            onFailure(error)
        }
    }
    

    
    func unbind() {
        do {
            try socket?.leaveMulticastGroup("239.255.255.250")
            print("left multi-cast group")
        } catch let error as NSError {
            print("failed \(error)")
        }
    }
}

class SocketDelegate:GCDAsyncUdpSocketDelegate {
    var onSuccess:(String) -> ()
    var onFailure:(NSError) -> ()
    init(onSuccess:(String) -> (), onFailure:(NSError) -> ()) {
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }
    @objc func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        let s = String(data:data, encoding: NSUTF8StringEncoding)
        if (s!.containsString("Sonos")) {
            print("Received")
            onSuccess(s!)
        }
    }
}
