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

    
    @IBOutlet weak var tableView: UITableView!
    var discoveryClient:SonosDiscoveryClient?

    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.

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
        
        let items = Observable.just([
                "One",
                "Two",
                "Three"
            ])

        items.bindTo(tableView.rx_itemsWithCellIdentifier("Cell", cellType: UITableViewCell.self)){ (row, element, cell) in
                cell.textLabel?.text = "\(element) @ row \(row)"
        }.addDisposableTo(disposeBag)
    }

    override func viewWillDisappear(animated: Bool) {

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


