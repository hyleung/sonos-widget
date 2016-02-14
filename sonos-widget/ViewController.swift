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
class ViewController: UIViewController, UITableViewDelegate {

    
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    private var disposeBag = DisposeBag()
    private let datasource = ZoneGroupDataSource()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self.datasource
        self.tableView.delegate = self
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

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = self.tableView?.dequeueReusableCellWithIdentifier("ZoneGroupCell") as! ZoneGroupHeaderCell
        if let zoneGroup = datasource.data?[section] {
            if let coordinator = zoneGroup.members?.filter({ member in
                return member.uuid == zoneGroup.groupCoordinator
            }).first {
                let locationUrl = "http://\(coordinator.location.host!):\(coordinator.location.port!)"
                logger.info("Group coordinator: \(locationUrl)")
                SonosApiClient.rx_getTransportInfo(locationUrl)
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { (element) -> Void in
                            logger.info(element.xmlString)
                            if let state = element["CurrentTransportState"].value {
                                logger.info("Group state: \(state)")
                                headerCell.headerLabel.text = "\(coordinator.uuid)"
                                ViewController.updateHeaderCell(headerCell, groupState: state, location: locationUrl)
                            }
                        }, onError: { err -> Void in
                            logger.error("Error: \(err)")
                        }, onCompleted: nil, onDisposed: nil)
                //hack
                SonosApiClient.getPositionInfo(locationUrl)
                    .map({(data:NSData) -> AEXMLDocument in
                        return data.asXmlDocument()!
                    })
                    .map({ (document:AEXMLDocument) -> AEXMLDocument in
                        let trackMetaData:String = (document["s:Envelope"]["s:Body"]["u:GetPositionInfoResponse"]["TrackMetaData"].value?.unescapeXml())!
                        return try AEXMLDocument(xmlData: trackMetaData.dataUsingEncoding(NSUTF8StringEncoding)!)
                    })
                    .subscribeNext({ (doc:AEXMLDocument) -> Void in
                        logger.debug(doc.xmlString)
                    })
                
            }
        }
        return headerCell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    static func updateHeaderCell(cell:ZoneGroupHeaderCell, groupState:String, location:String) -> Void {
        cell.initialize(groupState, location:location)
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
        .flatMap(SonosApiClient.rx_getZoneGroupState)

}