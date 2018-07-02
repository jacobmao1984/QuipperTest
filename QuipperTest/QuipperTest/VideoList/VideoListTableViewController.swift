//
//  VideoListTableViewController.swift
//  QuipperTest
//
//  Created by Jacob Mao on 2018/06/28.
//  Copyright © 2018 JacobMao. All rights reserved.
//

import UIKit

class VideoListTableViewController: UITableViewController {

    // MARK: Public Properties
    var cellForTransition: VideoListTableViewCell?
    
    // MARK: Private Properties
    private let viewModel: VideoListViewModel

    // MARK: Life Cycle
    init(viewModel: VideoListViewModel) {
        self.viewModel = viewModel
        
        super.init(style: .plain)
        
        self.viewModel.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = viewModel.estimatedRowHeight
        tableView.register(VideoListTableViewCell.self)
        
        // For removing blank cell
        tableView.tableFooterView = UIView()
        
        viewModel.fetchData()
    }

    override var shouldAutorotate: Bool {
        return false
    }
}

// MARK: UITableViewDataSource
extension VideoListTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemCount
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: VideoListTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)

        guard let cellViewModel = viewModel.getCellViewModel(at: indexPath.row) else {
            return cell
        }

        cell.configureForViewMode(cellViewModel)

        return cell
    }
}

// MARK: UITableViewDelegate
extension VideoListTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Because demo video is gone, we have to use a fixed url
        let videoUrl = URL(string: "https://recruit-a.akamaihd.net/rtmp/o1/4477599122001/4477599122001_4803584821001_4801290231001.mp4?pubId=4477599122001&videoId=4801290231001")!
        let vm = VideoPlayViewControllerViewModel(videoUrl: videoUrl)
        let vc = VideoPlayViewController(viewModel: vm)
        vc.modalPresentationStyle = .custom
        vc.modalPresentationCapturesStatusBarAppearance = true
        
        
        if let selectedCell = tableView.cellForRow(at: indexPath) as? VideoListTableViewCell {
            cellForTransition = selectedCell
            vc.transitioningDelegate = self
        } else {
            cellForTransition = nil
        }

        // https://stackoverflow.com/questions/21075540/presentviewcontrolleranimatedyes-view-will-not-appear-until-user-taps-again/30787046#30787046
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
}

// MARK: VideoListViewModelProtocol
extension VideoListTableViewController: VideoListViewModelProtocol {
    func videoListViewModelDidUpdateData(_ viewModel: VideoListViewModel) {
        tableView.reloadData()
    }
    
    func videoListViewModelUpdateDataFailed(_ error: Error) {
        showMessage(error.localizedDescription)
    }
}

// MARK: UIViewControllerTransitioningDelegate
extension VideoListTableViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return VideoPlayViewPresentAnimation()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let playVC = dismissed as? VideoPlayViewController else {
            return nil
        }
        
        return VideoPlayViewDismissAnimation(videoScreenshot: playVC.getCurrentVideoScreenshot())
    }
}

extension VideoListTableViewController: ShowMessageProtocol {}
