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
import SwiftClient
import AEXML
class ViewController: UIViewController {

    
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    private var disposeBag = DisposeBag()
    private let datasource = ZoneGroupDataSource()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self.datasource
     
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
        refreshButton.rx_tap.subscribeNext { () -> Void in
            self.refresh()
        }.addDisposableTo(disposeBag)
        refresh()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func refresh() -> Void {
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
        self.tableView.reloadData()
        self.discoveryObservable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (data:[ZoneGroup]?) -> Void in
                    self.datasource.data = data
                }, onError: { (err) -> Void in
                    logger.error("Error: \(err)")
                    self.activityIndicator.hidden = true
                    self.activityIndicator.stopAnimating()
                }, onCompleted: { () -> Void in
                    self.tableView.reloadData()
                    self.activityIndicator.hidden = true
                    self.activityIndicator.stopAnimating()
                }, onDisposed: nil )
            .addDisposableTo(disposeBag)
    } 

    private let discoveryObservable = SonosDiscoveryClient
        .performZoneQuery()
        .flatMap(SonosApiClient.getZoneGroupState)
        .flatMap(SonosApiClient.toXmlDocument)
        .map({ xml -> String in
            return xml["s:Envelope"]["s:Body"]["u:GetZoneGroupStateResponse"]["ZoneGroupState"]
                .xmlString.unescapeXml()
        })
        .map({ zoneGroupState -> [AEXMLElement] in
            logger.info(zoneGroupState)
            let xml = try AEXMLDocument(xmlData: zoneGroupState.dataUsingEncoding(NSUTF8StringEncoding)!)
            return xml["ZoneGroupState"]["ZoneGroups"]["ZoneGroup"].all!
        })
        .map(ZoneGroup.groupsFromElementArray)
    
}