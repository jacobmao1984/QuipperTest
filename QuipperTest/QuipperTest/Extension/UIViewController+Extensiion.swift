//
//  UIViewController+Extensiion.swift
//  QuipperTest
//
//  Created by Jaocb Mao on 2018/06/29.
//  Copyright © 2018 JacobMao. All rights reserved.
//

import UIKit

protocol ShowMessageProtocol {
}

extension ShowMessageProtocol where Self: UIViewController {
    func showMessage(_ message: String) {
        let errorAlert = UIAlertController(title: nil,
                                           message: message,
                                           preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK",
                                           style: .default,
                                           handler: nil))
        present(errorAlert, animated: true, completion: nil)
    }
}
