//
//  Request.swift
//  QuipperTest
//
//  Created by Jacob Mao on 2018/06/29.
//  Copyright © 2018 JacobMao. All rights reserved.
//

import Foundation

protocol AppRequest {
    associatedtype Response: Decodable

    var url: String { get }
}

struct VideoListRequest: AppRequest{
    typealias Response = [VideoListItem]

    let url = "https://gist.githubusercontent.com/sa2dai/04da5a56718b52348fbe05e11e70515c/raw/60a93bd0191a66141cab185a1b814a9828ab12a2/code_test_iOS.json"
}
