//
//  TodayViewDataSource.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-02-22.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import Foundation
import UIKit
import XCGLogger
import sonosclient
import AEXML

class TodayViewDataSource:NSObject, UITableViewDataSource {
    var data:[SonosGroupCellViewModel]?
    
    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.data?.count) ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SonosGroupCell", forIndexPath: indexPath) as! SonosGroupCell
        if  let viewModel = data?[indexPath.row] {
            logger.info("tablecell for \(viewModel)")
            cell.initialize( viewModel.groupState, location: viewModel.locationUrl)
            cell.zoneLabel.text = viewModel.title
            cell.trackLabel.text = "Track title"
        } else {
            cell.zoneLabel.text = "Ruh-roh"
        }
        return cell
    }

}