//
//  VideoPlayViewControllerGestureProxy.swift
//  QuipperTest
//
//  Created by Jacob Mao on 2018/07/02.
//  Copyright © 2018 JacobMao. All rights reserved.
//

import UIKit
import MediaPlayer

// A extension for get slide dirrection
private extension UIPanGestureRecognizer {
    enum SlideDirection {
        case up
        case left
        case bottom
        case right

        case invalid
    }

    var slideDirection: SlideDirection {
        guard state == .changed else {
            return .invalid
        }

        let translationValue = self.translation(in: view)
        let absX = fabs(translationValue.x)
        let absY = fabs(translationValue.y)
        if max(absX, absY) < slideThresholdValue {
            return .invalid
        }

        if absX > absY {
            return translationValue.x < 0 ? .left : .right
        }

        if absY > absX {
            return translationValue.y < 0 ? .up : .bottom
        }

        return .invalid
    }

    // It is a valid slide that has to be large than this value
    var slideThresholdValue: CGFloat {
        return 10
    }
}

class VideoPlayViewControllerGestureProxy: NSObject {

    private enum AdjustmentOperation {
        case volume(originalVolume: Float)
        case brightness(originalBrightness: CGFloat)
    }

    private let viewModel: VideoPlayViewControllerViewModel
    private weak var parentVC: VideoPlayViewController?
    private var currentAdjustmentOperation: AdjustmentOperation?

    private lazy var volumeViewSlider: UISlider? = {
        var result: UISlider?

        let volumeView = MPVolumeView()
        for v in volumeView.subviews {
            if (v.description as NSString).contains("MPVolumeSlider") {
                result = v as? UISlider
                break
            }
        }

        return result
    }()

    init(parentVC: VideoPlayViewController, viewModel: VideoPlayViewControllerViewModel) {
        self.parentVC = parentVC
        self.viewModel = viewModel
    }

    func setup() {
        // For switch playback status
        let doubleTapGesture = UITapGestureRecognizer(target: self,
                                                      action: #selector(handleDoubleTapGesture))
        doubleTapGesture.numberOfTapsRequired = 2
        parentVC?.view.addGestureRecognizer(doubleTapGesture)

        // For show/hide controls
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTapGesture))
        parentVC?.view.addGestureRecognizer(tapGesture)
        tapGesture.require(toFail: doubleTapGesture)

        // For adjust volume/brightness
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(handlePanGesture))
        parentVC?.view.addGestureRecognizer(panGesture)
        panGesture.delegate = self

        // set init value for volume
        volumeViewSlider?.value = AVAudioSession.sharedInstance().outputVolume
    }
}

// MARK: Handle Gestures
private extension VideoPlayViewControllerGestureProxy {
    @objc func handleDoubleTapGesture(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else {
            return
        }

        viewModel.switchPlaybackStatus()
    }

    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended, let videoVC = parentVC else {
            return
        }

        if videoVC.bottomView.alpha > 0 {
            videoVC.animateControls(false)
        } else {
            videoVC.animateControls(true)
        }
    }

    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .cancelled, .ended, .failed:
            currentAdjustmentOperation = nil
        default:
            if currentAdjustmentOperation == nil, let videoVC = parentVC {
                let direction = sender.slideDirection
                switch direction {
                case .up, .bottom:
                    if sender.location(in: sender.view).x < videoVC.view.bounds.width / 2 {
                        currentAdjustmentOperation = .brightness(originalBrightness: UIScreen.main.brightness)
                    } else {
                        currentAdjustmentOperation = .volume(originalVolume: volumeViewSlider?.value ?? 0)
                    }
                default:
                    return
                }
            }

            doAdjustmentOperationByTranslation(sender.translation(in: sender.view))
        }
    }

    func doAdjustmentOperationByTranslation(_ translation: CGPoint) {
        guard let operation = currentAdjustmentOperation else {
            return
        }

        switch operation {
        case .brightness(let originalValue):
            UIScreen.main.brightness = originalValue + -translation.y / 200
        case .volume(let originalValue):
            volumeViewSlider?.value = originalValue + Float(-translation.y / 200)
        }
    }
}

extension VideoPlayViewControllerGestureProxy: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view != parentVC?.progressSlider
    }
}
