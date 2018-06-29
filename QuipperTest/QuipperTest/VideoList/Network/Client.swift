//
//  Client.swift
//  QuipperTest
//
//  Created by ST21073 on 2018/06/29.
//  Copyright © 2018 JacobMao. All rights reserved.
//

import Foundation

enum ServiceError: Error {
    case invalidUrl
    case requestError
    case invalidDataFormat
}

enum RequestResult<T> {
    case success(T)
    case failed(Error)
}

// Define a Client protocol and you can use any object that inherit from this protocol to test
protocol Client {
    func send<T: AppRequest>(_ r: T, completion: @escaping (RequestResult<T.Response>) -> Void)
}

struct HttpClient: Client {
    func send<T: AppRequest>(_ r: T, completion: @escaping (RequestResult<T.Response>) -> Void) {
        guard let dataURL = URL(string: r.url) else {
            completion(.failed(ServiceError.invalidUrl))
            return
        }

        let fetchTask = URLSession(configuration: .default).dataTask(with:dataURL) { (data, response, e) in
            if let error = e {
                DispatchQueue.main.async {
                    completion(.failed(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200,
                let jsonData = data else {
                    DispatchQueue.main.async {
                        completion(.failed(ServiceError.requestError))
                    }
                    return
            }

            let decoder = JSONDecoder()
            guard let items = try? decoder.decode(T.Response.self, from: jsonData) else {
                DispatchQueue.main.async {
                    completion(.failed(ServiceError.invalidDataFormat))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(items))
            }
        }

        fetchTask.resume()
    }
}
