//
//  ZoneGroupHeaderState.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-02-11.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import Foundation
import XCGLogger

protocol ZoneGroupHeaderView {
    func setState(newState:ZoneGroupHeaderState) -> Void
    func setButtonImage(img:UIImage?, forState:UIControlState) -> Void
}

protocol ZoneGroupHeaderState {
    func advance(view:ZoneGroupHeaderView) -> Void
}


struct Playing: ZoneGroupHeaderState {
    init(_ view: ZoneGroupHeaderView) {
        view.setButtonImage(UIImage(named:"Pause"), forState: UIControlState.Normal)
    }
    func advance(view:ZoneGroupHeaderView) -> Void {
        logger.debug("playing transitioning to paused")
        view.setState(Paused(view))
        view.setButtonImage(UIImage(named:"Play"), forState: UIControlState.Normal)
    }
}

struct Paused: ZoneGroupHeaderState {
    init(_ view: ZoneGroupHeaderView) {
        view.setButtonImage(UIImage(named:"Play"), forState: UIControlState.Normal)
    }
    func advance(view:ZoneGroupHeaderView) -> Void {
        logger.debug("paused transitioning to playng")
        view.setState(Playing(view))
        view.setButtonImage(UIImage(named:"Pause"), forState: UIControlState.Normal)
    }
}

struct Stopped: ZoneGroupHeaderState {
    init(_ view: ZoneGroupHeaderView) {
        view.setButtonImage(UIImage(named:"Play"), forState: UIControlState.Normal)
    }
    func advance(view:ZoneGroupHeaderView) -> Void {
        logger.debug("stopped transitioning to playng")
        view.setState(Playing(view))
        view.setButtonImage(UIImage(named:"Pause"), forState: UIControlState.Normal)
    }
}