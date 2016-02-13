//
//  ZoneGroupHeaderState.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-02-11.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import Foundation
import XCGLogger
import RxSwift

protocol ZoneGroupHeaderView {
    func setState(newState:ZoneGroupHeaderState) -> Void
    func setButtonImage(img:UIImage?, forState:UIControlState) -> Void
    func getDisposeBag() -> DisposeBag

}

protocol ZoneGroupHeaderState {
    func advance(view:ZoneGroupHeaderView) -> Void
}


struct Playing: ZoneGroupHeaderState {
    let location:String
    init(_ view: ZoneGroupHeaderView, location:String) {
        view.setButtonImage(UIImage(named:"Pause"), forState: UIControlState.Normal)
        self.location = location
    }
    func advance(view:ZoneGroupHeaderView) -> Void {
        SonosApiClient.pause(location)
            .observeOn(MainScheduler.instance)
            .subscribeCompleted({ () -> Void in
                logger.debug("playing transitioning to paused")
                view.setState(Paused(view, location:self.location))
                view.setButtonImage(UIImage(named:"Play"), forState: UIControlState.Normal)
            }).addDisposableTo(view.getDisposeBag())
    }
}

struct Paused: ZoneGroupHeaderState {
    let location:String
    init(_ view: ZoneGroupHeaderView, location:String) {
        view.setButtonImage(UIImage(named:"Play"), forState: UIControlState.Normal)
        self.location = location
    }
    func advance(view:ZoneGroupHeaderView) -> Void {
        SonosApiClient.play(location)
            .observeOn(MainScheduler.instance)
            .subscribeCompleted({ () -> Void in
                logger.debug("paused transitioning to playng")
                view.setState(Playing(view, location:self.location))
                view.setButtonImage(UIImage(named:"Pause"), forState: UIControlState.Normal)
            }).addDisposableTo(view.getDisposeBag())
    }
}

struct Stopped: ZoneGroupHeaderState {
    let location:String
    init(_ view: ZoneGroupHeaderView, location:String) {
        view.setButtonImage(UIImage(named:"Play"), forState: UIControlState.Normal)
        self.location = location        
    }
    func advance(view:ZoneGroupHeaderView) -> Void {
        SonosApiClient.play(location)
            .observeOn(MainScheduler.instance)
            .subscribeCompleted({ () -> Void in
                logger.debug("stopped transitioning to playng")
                view.setState(Playing(view, location: self.location))
                view.setButtonImage(UIImage(named:"Pause"), forState: UIControlState.Normal)
            }).addDisposableTo(view.getDisposeBag())

        
    }
}