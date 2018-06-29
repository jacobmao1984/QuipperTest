//
//  UIView+Extension.swift
//  QuipperTest
//
//  Created by Jacob Mao on 2018/06/29.
//  Copyright © 2018 JacobMao. All rights reserved.
//

import UIKit

protocol ReusableViewProtocol: class {}

extension ReusableViewProtocol where Self: UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableViewProtocol { }


protocol NibLoadableView: class { }

extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
}

