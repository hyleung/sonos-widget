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
    let playImage = UIImage(named:"Play")
    let pauseImage = UIImage(named:"Pause")
    func initialize(groupState:String, location:String) -> Void {
        if ("PAUSED_PLAYBACK" == groupState) {
            self.state = Paused(self, location:location)
        } else if ("STOPPED" == groupState) {
            self.state = Stopped(self, location:location)
        } else {
            self.state = Playing(self, location:location)
        }
        updateButtonState()
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
        updateButtonState()
    }

    func getDisposeBag() -> DisposeBag {
        return self.disposeBag
    }
    
    func updateButtonState() {
        if (self.state is Paused) {
//            self.button.setTitle("Play", forState: UIControlState.Normal)
            self.button.setImage(playImage,  forState: UIControlState.Normal)
        } else if (self.state is Stopped) {
//            self.button.setTitle("Pause", forState: UIControlState.Normal)
            self.button.setImage(pauseImage, forState: UIControlState.Normal)
        } else {
//            self.button.setTitle("Pause", forState: UIControlState.Normal)
            self.button.setImage(pauseImage, forState: UIControlState.Normal)
        }
    }
}

protocol SonosGroupView {
    func setState(newState:SonosGroupState) -> Void
    func getDisposeBag() -> DisposeBag
    
}

protocol SonosGroupState {
    func advance(view:SonosGroupView) -> Void
}

struct Playing: SonosGroupState {
    let location:String
    init(_ view: SonosGroupView, location:String) {
        self.location = location
    }
    func advance(view:SonosGroupView) -> Void {
        SonosApiClient.pause(location)
            .observeOn(MainScheduler.instance)
            .subscribeCompleted({ () -> Void in
                logger.debug("playing transitioning to paused")
                view.setState(Paused(view, location:self.location))
            }).addDisposableTo(view.getDisposeBag())
    }
}

struct Paused: SonosGroupState {
    let location:String
    init(_ view: SonosGroupView, location:String) {
        self.location = location
    }
    func advance(view:SonosGroupView) -> Void {
        SonosApiClient.play(location)
            .observeOn(MainScheduler.instance)
            .subscribeCompleted({ () -> Void in
                logger.debug("paused transitioning to playng")
                view.setState(Playing(view, location:self.location))
            }).addDisposableTo(view.getDisposeBag())
    }
}

struct Stopped: SonosGroupState {
    let location:String
    init(_ view: SonosGroupView, location:String) {
        self.location = location
    }
    func advance(view:SonosGroupView) -> Void {
        SonosApiClient.play(location)
            .observeOn(MainScheduler.instance)
            .subscribeCompleted({ () -> Void in
                logger.debug("stopped transitioning to playng")
                view.setState(Playing(view, location: self.location))
            }).addDisposableTo(view.getDisposeBag())
        
        
    }
}