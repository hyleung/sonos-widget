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
            .observeOn(MainScheduler.instance)
            .map{ (groups:[ZoneGroup]?) -> [SonosGroupCellViewModel]? in
                groups?.map{ (group:ZoneGroup) -> SonosGroupCellViewModel in
                    let title = group.members?.map({ (member:ZoneGroupMember) -> String in
                        member.zoneName.unescapeXml()
                    }).joinWithSeparator(", ")
                    let coordinator =  group.members?.filter{ (element:ZoneGroupMember) -> Bool in
                        element.uuid == group.groupCoordinator
                        }.first
                    let locationUrl = "http://\(coordinator!.location.host!):\(coordinator!.location.port!)"
                    return SonosGroupCellViewModel(title:title!, locationUrl:locationUrl)
                }
            }
            .subscribe(onNext: { (groups:[SonosGroupCellViewModel]?) -> Void in
                    self.datasource.data = groups
                    self.tableView.reloadData()
                    self.updatePreferredContentSize()
                    completionHandler(.NewData)
                }, onError: { (err) -> Void in
                    logger.error("Error: \(err)")
                    completionHandler(.NoData)
                }, onCompleted: nil, onDisposed: nil)
    }
    
    func updatePreferredContentSize() {
            preferredContentSize = CGSizeMake(CGFloat(0), CGFloat(tableView(tableView, numberOfRowsInSection: 0)) * CGFloat(tableView.rowHeight) + tableView.sectionFooterHeight)
    }

    private let discoveryObservable = SonosDiscoveryClient
        .performZoneQuery()
        .flatMap(SonosApiClient.rx_getZoneGroupState)
    
}
