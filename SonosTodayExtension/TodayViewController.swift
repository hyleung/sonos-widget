//
//  TodayViewController.swift
//  SonosTodayExtension
//
//  Created by Ho Yan Leung on 2016-02-21.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import UIKit
import NotificationCenter
import RxSwift
import XCGLogger
import AEXML
import sonosclient
import ReachabilitySwift

class TodayViewController: UITableViewController, NCWidgetProviding {
    private let datasource = TodayViewDataSource()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self.datasource
        self.tableView.delegate = self
        self.tableView.rowHeight = 50.0
        self.tableView.sectionFooterHeight = 5.0
        logger.info("viewDidLoad")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        logger.info("performing update")
        discoveryObservable
            .flatMap{ (group:ZoneGroup) -> Observable<SonosGroupCellViewModel> in
                let title = group.members?.map({ (member:ZoneGroupMember) -> String in
                    member.zoneName.unescapeXml()
                }).joinWithSeparator(", ")
                let coordinator =  group.members?.filter{ (element:ZoneGroupMember) -> Bool in
                    element.uuid == group.groupCoordinator
                    }.first
                let locationUrl = "http://\(coordinator!.location.host!):\(coordinator!.location.port!)"
                return SonosApiClient
                    .rx_getTransportInfo(locationUrl)
                    .map{ (transportInfo:TransportInfo) -> SonosGroupCellViewModel in
                        return SonosGroupCellViewModel(title:title!, locationUrl:locationUrl, groupState: transportInfo.transportState)
                }
            }
            .toArray()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (groups:[SonosGroupCellViewModel]?) -> Void in
                    self.datasource.data = groups
                    self.tableView.reloadData()
                    self.updatePreferredContentSize(groups!.count)
                }, onError: { (err) -> Void in
                    logger.error("Error: \(err)")
                    completionHandler(.NoData)
                }, onCompleted: { () in completionHandler(.NewData) }, onDisposed: nil)
        
    }

    func updatePreferredContentSize(rowCount:Int) {
        preferredContentSize = CGSizeMake(CGFloat(0), CGFloat(rowCount) * CGFloat(tableView.rowHeight) + tableView.sectionFooterHeight)
        logger.info("preferred size \(preferredContentSize) for \(rowCount) rows")
    }

    private let discoveryObservable = SonosDiscoveryClient
        .performZoneQuery()
        .flatMap(SonosApiClient.rx_getZoneGroupState)
    
}

