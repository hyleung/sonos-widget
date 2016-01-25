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

    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
        refreshButton.rx_tap.subscribeNext { () -> Void in
            self.refresh()
        }
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
        SonosDiscoveryClient
            .performZoneQuery()
            .flatMap( {location -> Observable<NSData> in
                let s = SonosCommand(serviceType: SonosService.ZoneGroupTopologyService, version: 1, action: SonosService.GetZoneGroupStateAction, arguments: .None)
                return SonosApiClient.executeAction({ () in return Client() }, baseUrl: location, path: "/ZoneGroupTopology/Control", command: s)
            })
            .flatMap({ soapResponse -> Observable<AEXMLDocument> in
                do {
                    return Observable.just(try AEXMLDocument(xmlData: soapResponse))
                } catch let err as NSError {
                    return Observable.error(err)
                }
            })
            .map({ xml -> String in
                return xml["s:Envelope"]["s:Body"]["u:GetZoneGroupStateResponse"]["ZoneGroupState"]
                    .xmlString.unescapeXml()
            })
            .map({ zoneGroupState -> [AEXMLElement] in
                let xml = try AEXMLDocument(xmlData: zoneGroupState.dataUsingEncoding(NSUTF8StringEncoding)!)
                return xml["ZoneGroupState"]["ZoneGroups"]["ZoneGroup"].all!
            })
            .map({ elements -> [String] in
                return elements.map({element in element.attributes["ID"]!})
            })
            .observeOn(MainScheduler.instance)
            .doOn(onNext: nil,
                onError: { err -> Void in
                    self.activityIndicator.hidden = true
                    self.activityIndicator.stopAnimating()
                },
                onCompleted: { () -> Void in
                    self.activityIndicator.hidden = true
                    self.activityIndicator.stopAnimating()
                    self.disposeBag = DisposeBag()
                })
            .bindTo(tableView.rx_itemsWithCellIdentifier("Cell", cellType: UITableViewCell.self)){ (row, element, cell) in
                logger.info(element)
                cell.textLabel?.text = "\(element)"
            }.addDisposableTo(disposeBag)
    }


}


