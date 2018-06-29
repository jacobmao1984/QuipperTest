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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension VideoListTableViewCell: NibLoadableView { }
