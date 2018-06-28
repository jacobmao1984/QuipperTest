//
//  Service.swift
//  QuipperTest
//
//  Created by ST21073 on 2018/06/28.
//  Copyright © 2018 JacobMao. All rights reserved.
//

import Foundation

private let dataUrlStr = "https://gist.githubusercontent.com/sa2dai/04da5a56718b52348fbe05e11e70515c/raw/60a93bd0191a66141cab185a1b814a9828ab12a2/code_test_iOS.json"

enum ServiceError: Error {
    case invalidUrl
}

enum VideoListResult {
    case success([VideoListItem])
    case failed(Error)
}

struct VideoListService {
    private let session: URLSession

    init() {
        session = URLSession(configuration: .default)
    }

    func fetchList(_ completion: @escaping (VideoListResult) -> Void) {
        guard let dataURL = URL(string: dataUrlStr) else {
            completion(.failed(ServiceError.invalidUrl))
            return
        }

        session.dataTask(with:dataURL) { (data, response, e) in
            print("aaa")
            if let error = e {
                completion(.failed(error))
                return
            }
        }
    }
}
