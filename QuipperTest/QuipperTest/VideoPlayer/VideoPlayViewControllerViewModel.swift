//
//  VideoPlayViewControllerViewModel.swift
//  QuipperTest
//
//  Created by Jacob Mao on 2018/06/29.
//  Copyright © 2018 JacobMao. All rights reserved.
//

import Foundation
import AVKit

protocol VideoPlayViewControllerViewModelProtocol: class {
    func successfullyLoadedVideo() -> Void
    func videoPlaybackFailed() -> Void
    func playbackButtonStatusDidUpdate(_ status: VideoPlayViewControllerViewModel.PlaybackButtonStatus) -> Void
    func videoTimeStringDidUpdate(_ timeStr: String) -> Void
    func videoProgressDidUpdate(_ currentProgress: Float) -> Void
}

class VideoPlayViewControllerViewModel {

    enum PlaybackButtonStatus {
        case play
        case pause
        case uninitialized

        var title: String {
            switch self {
            case .play:
                return "Pause"
            case .pause:
                return "Play"
            case .uninitialized:
                return ""
            }
        }
    }

    // MARK: Public Properties
    weak var delegate: VideoPlayViewControllerViewModelProtocol?
    var disableProgressUpdating = false

    // MARK: Private Properties
    private(set) lazy var player: AVPlayer = {
        return AVPlayer(playerItem: playItem)
    }()
    
    private lazy var durationTimeStr: String = {
        return TimeInterval(CMTimeGetSeconds(videoDuration) * 1000).clockRepresentation
    }()

    private let playItem: AVPlayerItem
    private var videoStatusObservation: NSKeyValueObservation?
    private var currentPlaybackStatus: PlaybackButtonStatus = .uninitialized {
        didSet {
            delegate?.playbackButtonStatusDidUpdate(currentPlaybackStatus)
        }
    }

    private var videoDuration: CMTime {
        return playItem.asset.duration
    }

    // MARK: Life Cycle
    init(videoUrl: URL) {
        self.playItem = AVPlayerItem(url: videoUrl)
    }
}

// MARK: Public Methods
extension VideoPlayViewControllerViewModel {
    func start() {
        delegate?.playbackButtonStatusDidUpdate(.pause)

        videoStatusObservation = self.playItem.observe(\.status) { [weak self] (item, changed) in
            self?.handleVideoItemStatusChanged()
        }

        // To update time string and progress
        player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: nil) { [weak self] (time) in
            guard let strongSelf = self,
                  !strongSelf.disableProgressUpdating else {
                return
            }
            
            strongSelf.updateTimeStringByTime(time)
            strongSelf.updateProgressByTime(time)
        }
    }

    func switchPlaybackStatus() {
        switch currentPlaybackStatus {
        case .uninitialized, .pause:
            play()
        case .play:
            pause()
        }
    }
    
    func stop() {
        pause()
    }
    
    func updateVideoProgress(_ progress: Float) {
        pause()

        let seekingTime = getTimeByProgress(progress)
        player.seek(to: seekingTime) { [weak self] (finished) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.disableProgressUpdating = true
            strongSelf.play()
            strongSelf.updateProgressByTime(seekingTime)
        }
    }
    
    func updateVideoTimeStrByProgress(_ progress: Float) {
        updateTimeStringByTime(getTimeByProgress(progress))
    }
    
    func getCurrentVideoScreenshot() -> UIImage? {
        let imageGenerator = AVAssetImageGenerator(asset: playItem.asset)
        imageGenerator.requestedTimeToleranceAfter = kCMTimeZero
        imageGenerator.requestedTimeToleranceBefore = kCMTimeZero
        
        guard let screenshot = try? imageGenerator.copyCGImage(at: playItem.currentTime(), actualTime: nil) else {
            return nil
        }
        
        return UIImage(cgImage: screenshot)
    }
}

// MARK: Private Methods
private extension VideoPlayViewControllerViewModel {
    func handleVideoItemStatusChanged() {
        switch playItem.status {
        case .failed, .unknown:
            delegate?.videoPlaybackFailed()
        case .readyToPlay:
            delegate?.successfullyLoadedVideo()
            updateTimeStringByTime(kCMTimeZero)
            updateProgressByTime(kCMTimeZero)
            play()
        }
    }

    func play() {
        currentPlaybackStatus = .play
        player.play()
    }

    func pause() {
        currentPlaybackStatus = .pause
        player.pause()
    }

    func getTimeByProgress(_ progress: Float) -> CMTime {
        let p = max(0, min(progress, 1.0))
        return CMTimeMultiplyByFloat64(videoDuration, Float64(p))
    }
    
    func updateTimeStringByTime(_ time: CMTime) {
        let currentTimeStr = TimeInterval(CMTimeGetSeconds(time) * 1000).clockRepresentation
        let result = "\(currentTimeStr)/\(durationTimeStr)"
        
        delegate?.videoTimeStringDidUpdate(result)
    }
    
    func updateProgressByTime(_ time: CMTime) {
        let currentProgress = CMTimeGetSeconds(time) / CMTimeGetSeconds(videoDuration)
        delegate?.videoProgressDidUpdate(min(Float(currentProgress < 0 ? 0 : currentProgress), 1))
    }
}
