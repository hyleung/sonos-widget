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
import sonosclient
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
        self.disposeBag = DisposeBag()
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
                let rxTransportState = SonosApiClient
                    .rx_getTransportInfo(locationUrl)
                    .subscribeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: DispatchQueueSchedulerQOS.Background))

                let rxCurrentTrack = SonosApiClient
                    .getCurrentTrackMetaData(locationUrl)
                    .subscribeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: DispatchQueueSchedulerQOS.Background))

                let zipped = Observable.zip(rxTransportState, rxCurrentTrack, resultSelector: { (state:TransportInfo, trackInfo:TrackInfo) -> (TransportInfo, TrackInfo) in
                    return (state, trackInfo)
                })

                zipped
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { (element:(TransportInfo, TrackInfo)) -> Void in
                            let state = element.0
                            let trackInfo = element.1
                            logger.info("Group state: \(state)")
                            if trackInfo.protocolInfo.containsString("radio") {
                                headerCell.headerLabel.text = "Radio"
                                headerCell.artistLabel.text = ""
                            } else {
                                headerCell.headerLabel.text = trackInfo.title
                                headerCell.artistLabel.text = trackInfo.artist
                            }

                            ViewController.updateHeaderCell(headerCell, groupState: state.transportState, location: locationUrl)
                        
                        }, onError: { err -> Void in
                            logger.error("Error: \(err)")
                        }, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(disposeBag)


            }
        }
        return headerCell
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75.0
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
                    self.displayTableBackground("Unable to connect to your Sonos system")
                }, onCompleted: { () -> Void in
                    self.tableView.reloadData()
                    self.activityIndicator.hidden = true
                    self.activityIndicator.stopAnimating()
                    self.hideTableBackground()
                }, onDisposed: nil )
            .addDisposableTo(disposeBag)
    } 

    private let discoveryObservable = SonosDiscoveryClient
        .performZoneQuery()
        .flatMap(SonosApiClient.rx_getZoneGroupState)
        .toArray()

    private func displayTableBackground(message:String) {
        let label = UILabel(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
        label.text = message
        label.textAlignment = NSTextAlignment.Center
        self.tableView.backgroundView = label
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }


    private func hideTableBackground() {
        self.tableView.backgroundView = .None
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
    }

}