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
import TMCache
class TodayViewController: UITableViewController, NCWidgetProviding {
    private let datasource = TodayViewDataSource()
    private var disposeBag = DisposeBag()
    var cachedViewModels:[SonosGroupCellViewModel]? {
        get {
            return TMCache.sharedCache().objectForKey("viewModels") as? [SonosGroupCellViewModel]
        }
        set(newItems) {
            TMCache.sharedCache().setObject(newItems, forKey: "viewModels")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self.datasource
        self.tableView.delegate = self
        self.tableView.rowHeight = 75.0
        self.tableView.sectionFooterHeight = 5.0
        updateTableData(self.cachedViewModels)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.disposeBag = DisposeBag()
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
                let title = group.members?
                    .filter{ member in
                        !member.isInvisible
                    }
                    .map{ (member:ZoneGroupMember) -> String in
                        member.zoneName.unescapeXml()
                    }
                    .sort()
                    .joinWithSeparator(", ")
                let coordinator =  group.members?.filter{ (element:ZoneGroupMember) -> Bool in
                    element.uuid == group.groupCoordinator
                    }.first
                let locationUrl = "http://\(coordinator!.location.host!):\(coordinator!.location.port!)"
                return
                    Observable.zip(SonosApiClient.rx_getTransportInfo(locationUrl),
                        SonosApiClient.getCurrentTrackMetaData(locationUrl),
                        resultSelector: {(transportInfo:TransportInfo, trackInfo:TrackInfo) -> SonosGroupCellViewModel in
                            return SonosGroupCellViewModel(title:title!, trackTitle:trackInfo.title, locationUrl:locationUrl, groupState: transportInfo.transportState)
                        })
            }
            .toArray()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (groups:[SonosGroupCellViewModel]?) -> Void in
                    self.updateTableData(groups)
                }, onError: { (err) -> Void in
                    logger.error("Error: \(err)")
                    self.updatePreferredContentSize(1)
                    self.displayTableBackground("Unable to connect to your Sonos system")
                    completionHandler(.NoData)
                }, onCompleted: { () in
                    completionHandler(.NewData)
                    self.hideTableBackground()
                }, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
    }

    func updateTableData(data:[SonosGroupCellViewModel]?) {
        self.datasource.data = data
        self.tableView.reloadData()
        self.updatePreferredContentSize(data?.count ?? 0)
    }
    func updatePreferredContentSize(rowCount:Int) {
        preferredContentSize = CGSizeMake(CGFloat(0), CGFloat(rowCount) * CGFloat(tableView.rowHeight) + tableView.sectionFooterHeight)
        logger.info("preferred size \(preferredContentSize) for \(rowCount) rows")
    }
    
    private let discoveryObservable = SonosDiscoveryClient
        .performZoneQuery()
        .flatMap(SonosApiClient.rx_getZoneGroupState)


    private func displayTableBackground(message:String) {
        let label = UILabel(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
        label.text = message
        label.font = UIFont.systemFontOfSize(14)
        label.textColor = UIColor.whiteColor()
        label.textAlignment = NSTextAlignment.Center
        self.tableView.backgroundView = label
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }


    private func hideTableBackground() {
        self.tableView.backgroundView = .None
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
    }
}

