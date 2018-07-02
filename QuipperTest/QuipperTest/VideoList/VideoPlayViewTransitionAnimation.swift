//
//  VideoPlayViewTransitionAnimation.swift
//  QuipperTest
//
//  Created by Jacob Mao on 6/30/18.
//  Copyright © 2018 JacobMao. All rights reserved.
//

import UIKit

private extension UIView {
    func forceLandscapeByContainerView(_ containerView: UIView) {
        transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        frame = containerView.bounds
    }
}

// Present animation
class VideoPlayViewPresentAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? VideoListTableViewController,
              let selectedCell = fromVC.cellForTransition,
              let toVC = transitionContext.viewController(forKey: .to),
              let snapshotOfFromVC = fromVC.view.snapshotView(afterScreenUpdates: false) else {
            return
        }
        
        let containerView = transitionContext.containerView

        toVC.view.forceLandscapeByContainerView(containerView)
        containerView.addSubview(toVC.view)

        // Add a snapshot as a background of animation
        containerView.addSubview(snapshotOfFromVC)

        // selected cell's thumbnail imageView frame
        let imageViewFrame = selectedCell.convert(selectedCell.thumbnailImageView.frame, to: nil)

        // A mask view to hide selected cell's image view
        let imageMaskView = UIView(frame: imageViewFrame)
        imageMaskView.backgroundColor = UIColor.white
        containerView.addSubview(imageMaskView)

        let transitionImageView = UIImageView(image: selectedCell.thumbnailImageView.image)
        transitionImageView.frame = imageViewFrame
        containerView.addSubview(transitionImageView)

        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       animations: {
                        transitionImageView.forceLandscapeByContainerView(containerView)
                        UIApplication.shared.statusBarOrientation = .landscapeRight
        }) { (finished) in
            snapshotOfFromVC.removeFromSuperview()
            transitionImageView.removeFromSuperview()
            imageMaskView.removeFromSuperview()
            
            transitionContext.completeTransition(true)
        }
    }
}

class VideoPlayViewDismissAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    private let videoScreenshot: UIImage?
    
    init(videoScreenshot: UIImage?) {
        self.videoScreenshot = videoScreenshot
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) as? VideoListTableViewController,
            let selectedCell = toVC.cellForTransition,
            let snapshotOfToVC = toVC.view.snapshotView(afterScreenUpdates: false) else {
                return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(snapshotOfToVC)

        let imageViewFrame = selectedCell.convert(selectedCell.thumbnailImageView.frame, to: nil)

        // Same a white mask view
        let imageMaskView = UIView(frame: imageViewFrame)
        imageMaskView.backgroundColor = UIColor.white
        containerView.addSubview(imageMaskView)

        // current video's screenshot
        let videoScreenshotImageView = UIImageView(image: videoScreenshot)
        videoScreenshotImageView.forceLandscapeByContainerView(containerView)
        containerView.addSubview(videoScreenshotImageView)

        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       animations: {
                        videoScreenshotImageView.transform = CGAffineTransform.identity
                        videoScreenshotImageView.frame = imageViewFrame

                        UIApplication.shared.statusBarOrientation = .portrait
        }) { (finished) in
            snapshotOfToVC.removeFromSuperview()
            videoScreenshotImageView.removeFromSuperview()
            imageMaskView.removeFromSuperview()
            
            transitionContext.completeTransition(true)
        }
    }
}
