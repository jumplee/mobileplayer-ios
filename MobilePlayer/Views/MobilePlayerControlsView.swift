//
//  MobilePlayerControlsView.swift
//  MobilePlayer
//
//  Created by Baris Sencan on 12/02/15.
//  Copyright (c) 2015 MovieLaLa. All rights reserved.
//

import UIKit
import MediaPlayer

final class MobilePlayerControlsView: UIView {
  let config: MobilePlayerConfig
  let previewImageView = UIImageView(frame: .zero)
  let activityIndicatorView = UIActivityIndicatorView(style: .white)
  let overlayContainerView = UIView(frame: .zero)
  let topBar: Bar
  let bottomBar: Bar

  var controlsHidden: Bool = false {
    didSet {
      if oldValue != controlsHidden {
        UIView.animate(withDuration: 0.2) {
          self.layoutSubviews()
        }
      }
    }
  }

  init(config: MobilePlayerConfig) {
    self.config = config
    topBar = Bar(config: config.topBarConfig)

    bottomBar = Bar(config: config.bottomBarConfig)
    super.init(frame: .zero)
    previewImageView.contentMode = .scaleAspectFit
    addSubview(previewImageView)
    activityIndicatorView.startAnimating()
    addSubview(activityIndicatorView)
    addSubview(overlayContainerView)
    if topBar.elements.count == 0 {
      topBar.addElement(usingConfig: ButtonConfig(dictionary: ["type": "button", "identifier": "close"]))
      topBar.addElement(usingConfig: LabelConfig(dictionary: ["type": "label", "identifier": "title"]))
      topBar.addElement(usingConfig: ButtonConfig(dictionary: ["type": "button", "identifier": "action"]))
      topBar.addElement(usingConfig: ButtonConfig(dictionary: ["type": "button", "identifier": "rotate"]))
    }
    addSubview(topBar)
    if bottomBar.elements.count == 0 {
      bottomBar.addElement(usingConfig: ToggleButtonConfig(dictionary: ["type": "toggleButton", "identifier": "play"]))
      bottomBar.addElement(usingConfig: LabelConfig(dictionary: ["type": "label", "identifier": "currentTime"]))
      bottomBar.addElement(usingConfig: SliderConfig(dictionary: ["type": "slider", "identifier": "playback", "marginLeft": 8, "marginRight": 8]))
      bottomBar.addElement(usingConfig: LabelConfig(dictionary: ["type": "label", "identifier": "duration", "marginRight": 8]))
    }
    addSubview(bottomBar)

    NotificationCenter.default.addObserver(self, selector: #selector(self.onOrientationChanged), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
  }

  // remove observer when destroy
  deinit {
    print("removeObserver")
    NotificationCenter.default.removeObserver(self, name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
  }

  @objc fileprivate func onOrientationChanged(){
    // repaint subView on change orientation
    self.layoutSubviews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    let size = bounds.size
    previewImageView.frame = bounds
    activityIndicatorView.sizeToFit()
    activityIndicatorView.frame.origin = CGPoint(
      x: (size.width - activityIndicatorView.frame.size.width) / 2,
      y: (size.height - activityIndicatorView.frame.size.height) / 2)
    let boundWidth=size.width
    let boundHeight=size.height
    // Portrait
    if(boundHeight>boundWidth){
         var iphoneXHeightFix:CGFloat=0
        //iphoneX or iphoneX max
        // iphoneX iphoneX max 屏占比都大于2.16 iphone8以前的都大于1.7
        if(boundHeight/boundWidth>2.16){
            iphoneXHeightFix = 38
        }
        topBar.sizeToFit()
        topBar.frame = CGRect(
            x: 0,
            y: controlsHidden ? -topBar.frame.size.height : (0 + iphoneXHeightFix),
            width: boundWidth,
            height: topBar.frame.size.height)
        topBar.alpha = controlsHidden ? 0 : 1
        bottomBar.sizeToFit()
        bottomBar.frame = CGRect(
            x: 0,
            y: size.height - iphoneXHeightFix  - (controlsHidden ? 0 : bottomBar.frame.size.height),
            width: size.width,
            height: bottomBar.frame.size.height)
        bottomBar.alpha = controlsHidden ? 0 : 1
        overlayContainerView.frame = CGRect(
            x: 0,
            y: controlsHidden ? 0 + iphoneXHeightFix: topBar.frame.size.height + iphoneXHeightFix,
            width: size.width,
            height: size.height - (controlsHidden ? 0 : (topBar.frame.size.height + bottomBar.frame.size.height)) - iphoneXHeightFix)
        for overlay in overlayContainerView.subviews {
            overlay.frame = overlayContainerView.bounds
        }
    }else{
        //Landscape
        var iphoneXWidthFix:CGFloat=0
        var iphoneXHeightFix:CGFloat=0
        if(boundWidth/boundHeight>2.16 ){
            iphoneXWidthFix=80
            iphoneXHeightFix=44
            
        }
        topBar.sizeToFit()
        topBar.frame = CGRect(
            x: iphoneXWidthFix,
            y: controlsHidden ? -topBar.frame.size.height : (0 + iphoneXHeightFix),
            width: size.width - iphoneXWidthFix*2,
            height: topBar.frame.size.height)
        topBar.alpha = controlsHidden ? 0 : 1
        bottomBar.sizeToFit()
        bottomBar.frame = CGRect(
            x: iphoneXWidthFix,
            y: boundHeight - iphoneXHeightFix  - (controlsHidden ? 0 : bottomBar.frame.size.height),
            width: boundWidth - iphoneXWidthFix*2,
            height: bottomBar.frame.size.height)
        bottomBar.alpha = controlsHidden ? 0 : 1
        overlayContainerView.frame = CGRect(
            x: iphoneXWidthFix,
            y: controlsHidden ? 0 + iphoneXHeightFix: topBar.frame.size.height + iphoneXHeightFix,
            width: size.width - iphoneXWidthFix*2,
            height: size.height - (controlsHidden ? 0 : (topBar.frame.size.height + bottomBar.frame.size.height)) - iphoneXHeightFix)
        for overlay in overlayContainerView.subviews {
            overlay.frame = overlayContainerView.bounds
        }
    }
    super.layoutSubviews()
  }
}
