//
//  ZoneGroupHeaderCell.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-02-05.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import Foundation
import UIKit
import XCGLogger
import RxSwift
import RxCocoa
import XCGLogger

class ZoneGroupHeaderCell: UITableViewCell, ZoneGroupHeaderView {
    private var state:ZoneGroupHeaderState?
    private var disposeBag = DisposeBag()
    
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var zoneGroupStateButon: UIButton!
    override func willMoveToSuperview(newSuperview: UIView?) {
        zoneGroupStateButon.rx_tap.subscribeNext { () -> Void in
            self.state?.advance(self)
        }.addDisposableTo(disposeBag)
    }
    
    override func willRemoveSubview(subview: UIView) {
        self.disposeBag = DisposeBag()
    }
    func initialize(groupState:String, location:String) -> Void {
        if ("PAUSED_PLAYBACK" == groupState) {
            self.state = Paused(self, location:location)
        } else if ("STOPPED" == groupState) {
            self.state = Stopped(self, location:location)
        } else {
            self.state = Playing(self, location:location)
        }
    }
    
    func setState(newState:ZoneGroupHeaderState) -> Void {
        self.state = newState
    }
    
    func setButtonImage(img:UIImage?,forState:UIControlState) -> Void {
        self.zoneGroupStateButon.setImage(img, forState: forState)
    }
    
    func getDisposeBag() -> DisposeBag {
        return self.disposeBag
    }

}