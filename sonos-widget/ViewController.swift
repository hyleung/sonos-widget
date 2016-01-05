//
//  ViewController.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2015-12-26.
//  Copyright © 2015 Ho Yan Leung. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class ViewController: UIViewController, GCDAsyncUdpSocketDelegate {

    
    @IBOutlet weak var myLabel: UILabel?
    var socket:GCDAsyncUdpSocket?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let l = myLabel {
            l.text = "bar"
        }
    
        socket = GCDAsyncUdpSocket(delegate:self, delegateQueue:dispatch_get_main_queue())
        do {
            try socket?.bindToPort(1900)
            try socket?.joinMulticastGroup("239.255.255.250")
            print("joined")
            let message = "M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: \"ssdp:discover\"\r\nMX: 1\r\nST: urn:schemas-upnp-org:device:ZonePlayer:1"
            let data = message.dataUsingEncoding(NSUTF8StringEncoding)
            try socket?.beginReceiving()

            socket?.sendData(data, toHost: "239.255.255.250" , port: 1900, withTimeout: 100, tag: 0)
            print("sent")

        } catch let error as NSError {
            print("failed \(error)")
        }
        


    }
    override func viewWillDisappear(animated: Bool) {
        do {
            try socket?.leaveMulticastGroup("239.255.255.250")
        } catch let error as NSError {
            print("failed \(error)")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        let s = String(data:data, encoding: NSUTF8StringEncoding)
        if (s!.containsString("Sonos")) {
            print("Received")
            print(s!)
        }

    }

}


