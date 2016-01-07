//
//  ViewController.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2015-12-26.
//  Copyright © 2015 Ho Yan Leung. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class ViewController: UIViewController {

    
    @IBOutlet weak var myLabel: UILabel?
    var discoveryClient:SonosDiscoveryClient?

    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let l = myLabel {
            l.text = "bar"
        }
        discoveryClient = SonosDiscoveryClient()
        discoveryClient?.performDiscovery({ (s:String) -> () in
            print(s)
            }, onFailure: { (err: NSError) -> () in
                print(err)
        })

    }

    override func viewWillDisappear(animated: Bool) {
        discoveryClient?.unbind()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


