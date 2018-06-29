//
//  VideoDurationLabel.swift
//  QuipperTest
//
//  Created by Jacob Mao on 6/28/18.
//  Copyright © 2018 JacobMao. All rights reserved.
//

import UIKit

// duration label needs to be a little bigger

@IBDesignable
class VideoDurationLabel: UILabel {
    @IBInspectable var cornerRadiusValue: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadiusValue
            layer.masksToBounds = cornerRadiusValue > 0
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override var intrinsicContentSize: CGSize {
        let origSize = super.intrinsicContentSize
        
        return CGSize(width: origSize.width + 8,
                      height: origSize.height + 8)
    }
}
