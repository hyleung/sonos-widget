//
//  SonosGroupCell.swift
//  sonos-widget
//
//  Created by Ho Yan Leung on 2016-02-24.
//  Copyright © 2016 Ho Yan Leung. All rights reserved.
//

import Foundation
import UIKit
import XCGLogger
import RxSwift
import RxCocoa
import sonosclient

class SonosGroupCell: UITableViewCell, SonosGroupView {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    var state:SonosGroupState?
    var disposeBag = DisposeBag()
    
    func initialize(groupState:String, location:String) -> Void {
        if ("PAUSED_PLAYBACK" == groupState) {
            self.state = Paused(self, location:location)
        } else if ("STOPPED" == groupState) {
            self.state = Stopped(self, location:location)
        } else {
            self.state = Playing(self, location:location)
        }
    }
    
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        button.rx_tap.subscribeNext { () -> Void in
            self.state?.advance(self)
            }.addDisposableTo(disposeBag)
    }
    
    override func willRemoveSubview(subview: UIView) {
        self.disposeBag = DisposeBag()
    }
    
    func setState(newState:SonosGroupState) -> Void {
        self.state = newState
    }
    func setButtonText(txt:String) -> Void {
        self.button.setTitle(txt, forState: UIControlState.Normal)
    }
    func getDisposeBag() -> DisposeBag {
        return self.disposeBag
    }
}

protocol SonosGroupView {
    func setState(newState:SonosGroupState) -> Void
    func setButtonText(txt:String) -> Void
    func getDisposeBag() -> DisposeBag
    
}

protocol SonosGroupState {
    func advance(view:SonosGroupView) -> Void
}

struct Playing: SonosGroupState {
    let location:String
    init(_ view: SonosGroupView, location:String) {
        view.setButtonText("Pause")
        self.location = location
    }
    func advance(view:SonosGroupView) -> Void {
        SonosApiClient.pause(location)
            .observeOn(MainScheduler.instance)
            .subscribeCompleted({ () -> Void in
                logger.debug("playing transitioning to paused")
                view.setState(Paused(view, location:self.location))
                view.setButtonText("Play")
            }).addDisposableTo(view.getDisposeBag())
    }
}

struct Paused: SonosGroupState {
    let location:String
    init(_ view: SonosGroupView, location:String) {
        view.setButtonText("Play")
        self.location = location
    }
    func advance(view:SonosGroupView) -> Void {
        SonosApiClient.play(location)
            .observeOn(MainScheduler.instance)
            .subscribeCompleted({ () -> Void in
                logger.debug("paused transitioning to playng")
                view.setState(Playing(view, location:self.location))
                view.setButtonText("Pause")
            }).addDisposableTo(view.getDisposeBag())
    }
}

struct Stopped: SonosGroupState {
    let location:String
    init(_ view: SonosGroupView, location:String) {
        view.setButtonText("Play")
        self.location = location
    }
    func advance(view:SonosGroupView) -> Void {
        SonosApiClient.play(location)
            .observeOn(MainScheduler.instance)
            .subscribeCompleted({ () -> Void in
                logger.debug("stopped transitioning to playng")
                view.setState(Playing(view, location: self.location))
                view.setButtonText("Pause")
            }).addDisposableTo(view.getDisposeBag())
        
        
    }
}