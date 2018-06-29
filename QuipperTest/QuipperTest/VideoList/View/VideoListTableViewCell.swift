//
//  VideoListTableViewCell.swift
//  QuipperTest
//
//  Created by Jacob Mao on 6/28/18.
//  Copyright © 2018 JacobMao. All rights reserved.
//

import UIKit

class VideoListTableViewCell: UITableViewCell {
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var durationLabel: VideoDurationLabel!
    @IBOutlet var presenterNameLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
}

// MARK: Public Methods
extension VideoListTableViewCell {
    func configureForViewMode(_ viewModel: VideoListItemViewModel) {
        thumbnailImageView.kf.setImage(with: viewModel.imageUrl)
        durationLabel.text = viewModel.duration
        presenterNameLabel.text = viewModel.presenter
        titleLabel.text = viewModel.title
        descLabel.text = viewModel.desc
    }
}

extension VideoListTableViewCell: NibLoadableView { }
