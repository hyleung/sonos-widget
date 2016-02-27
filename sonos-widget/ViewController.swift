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
                    .flatMap{ (element:AEXMLElement) -> Observable<String> in
                        if let state = element["CurrentTransportState"].value {
                            return Observable.just(state)
                        } else {
                            return Observable.empty()
                        }
                    }.subscribeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: DispatchQueueSchedulerQOS.Background))

                let rxCurrentTrack = SonosApiClient
                    .getCurrentTrackMetaData(locationUrl)
                    .flatMap{(doc:AEXMLDocument) -> Observable<TrackInfo> in
                        if let title = doc["DIDL-Lite"]["item"]["dc:title"].value,
                            let creator = doc["DIDL-Lite"]["item"]["dc:creator"].value {
                                if (title.containsString("not found") && creator.containsString("not found")) {
                                    return Observable.just(TrackInfo(title: "No track", artist:.None))
                                }
                                return Observable.just(TrackInfo(title: title, artist: creator))
                        }
                        return Observable.empty()
                    }.subscribeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: DispatchQueueSchedulerQOS.Background))

                let zipped = Observable.zip(rxTransportState, rxCurrentTrack, resultSelector: { (state:String, trackInfo:TrackInfo) -> (String, TrackInfo) in
                    return (state, trackInfo)
                })

                zipped
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { (element:(String, TrackInfo)) -> Void in
                            let state = element.0
                            let trackInfo = element.1
                            logger.info("Group state: \(state)")
                            headerCell.headerLabel.text = trackInfo.title
                            headerCell.artistLabel.text = trackInfo.artist
                            ViewController.updateHeaderCell(headerCell, groupState: state, location: locationUrl)
                        
                        }, onError: { err -> Void in
                            logger.error("Error: \(err)")
                        }, onCompleted: nil, onDisposed: nil)


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