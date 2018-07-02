//
//  VideoPlayViewController.swift
//  QuipperTest
//
//  Created by Jacob Mao on 2018/06/29.
//  Copyright © 2018 JacobMao. All rights reserved.
//

import UIKit
import AVKit

class VideoPlayViewController: UIViewController {
    // MARK: Views
    @IBOutlet var playbackButton: UIButton!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var progressSlider: UISlider!
    @IBOutlet var backButton: UIButton!

    // MARK: Private Properties
    private let viewModel: VideoPlayViewControllerViewModel
    private var videoLayer: AVPlayerLayer?
    private var isHideStatusBar = false
    private var gestureProxy: VideoPlayViewControllerGestureProxy?

    // MARK: Life Cycle
    init(viewModel: VideoPlayViewControllerViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        self.gestureProxy = VideoPlayViewControllerGestureProxy(parentVC: self, viewModel: viewModel)
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gestureProxy?.setup()
        setupPlayerLayer()
        
        viewModel.start()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        videoLayer?.frame = view.bounds
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    override var prefersStatusBarHidden: Bool {
        return isHideStatusBar
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: Public Methods
extension VideoPlayViewController {
    func animateControls(_ showOrNot: Bool) {
        bottomView.layer.removeAllAnimations()
        backButton.layer.removeAllAnimations()

        isHideStatusBar = !showOrNot
        setNeedsStatusBarAppearanceUpdate()

        UIView.animate(withDuration: 0.3) {
            self.bottomView.alpha = showOrNot ? 1 : 0
            self.backButton.alpha = showOrNot ? 1 : 0
        }
    }

    func getCurrentVideoScreenshot() -> UIImage? {
        return viewModel.getCurrentVideoScreenshot()
    }
}

// MARK: Private Methods
private extension VideoPlayViewController {
    func setupPlayerLayer() {
        videoLayer?.removeFromSuperlayer()

        let playerLayer = AVPlayerLayer(player: viewModel.player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.needsDisplayOnBoundsChange = true
        playerLayer.contentsScale = UIScreen.main.scale
        playerLayer.frame = view.bounds
        view.layer.insertSublayer(playerLayer, at: 0)
        videoLayer = playerLayer
    }
}

// MARK: UI Actions
extension VideoPlayViewController {
    @IBAction func clickedBackButton(_ sender: UIButton) {
        viewModel.stop()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func clickedPlaybackButton(_ sender: UIButton) {
        viewModel.switchPlaybackStatus()
    }

    @IBAction func startDraggingSlider(_ sender: UISlider) {
        viewModel.disableProgressUpdating = true
    }

    @IBAction func changingProgressSlider(_ sender: UISlider) {
        viewModel.updateVideoTimeStrByProgress(sender.value)
    }

    @IBAction func changedProgressSlider(_ sender: UISlider) {
        viewModel.updateVideoProgress(sender.value)
    }

    @IBAction func canceledTouchSlider(_ sender: UISlider) {
        viewModel.updateVideoProgress(sender.value)
    }
}


// MARK: VideoPlayViewControllerViewModelProtocol
extension VideoPlayViewController: VideoPlayViewControllerViewModelProtocol {
    func videoProgressDidUpdate(_ currentProgress: Float) {
        progressSlider.value = currentProgress
    }
    
    func videoTimeStringDidUpdate(_ timeStr: String) {
        timeLabel.text = timeStr
    }

    func videoPlaybackFailed() {
        showMessage("Video is error")
    }

    func playbackButtonStatusDidUpdate(_ status: VideoPlayViewControllerViewModel.PlaybackButtonStatus) {
        playbackButton.setTitle(status.title, for: .normal)
    }

    func successfullyLoadedVideo() {
        bottomView.isHidden = false
        loadingIndicator.stopAnimating()
    }
}

extension VideoPlayViewController: ShowMessageProtocol {}

