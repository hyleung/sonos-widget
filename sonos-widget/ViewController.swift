//
//  ViewController.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2015-12-26.
//  Copyright © 2015 Ho Yan Leung. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import XCGLogger
import RxSwift
import RxCocoa

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
        discoveryClient?
            .performDiscovery()
            .subscribe(onNext: { (s) -> Void in
                logger.info("Success: \(s)")
                }, onError: { (e) -> Void in
                    logger.error("Error: \(e)")
                }, onCompleted: { () -> Void in
                    logger.verbose("completed")
                }, onDisposed: { () -> Void in
                    logger.verbose("disposed")
            })
        
    
    }

    override func viewWillDisappear(animated: Bool) {

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


