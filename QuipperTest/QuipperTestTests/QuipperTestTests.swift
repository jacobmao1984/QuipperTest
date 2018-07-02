//
//  QuipperTestTests.swift
//  QuipperTestTests
//
//  Created by Jacob Mao on 2018/06/28.
//  Copyright © 2018 JacobMao. All rights reserved.
//

import XCTest
@testable import QuipperTest

struct LocalClient: Client {
    var isRespondError = false

    func send<T: AppRequest>(_ r: T, completion: @escaping (RequestResult<T.Response>) -> Void) {
        guard let fileURL = Bundle(for: QuipperTestTests.self).url(forResource: "LocalResponse", withExtension: "txt"),
            let data = try? Data(contentsOf: fileURL) else {
            fatalError()
        }

        if isRespondError {
            completion(.failed(ServiceError.requestError))
            return
        }

        let decoder = JSONDecoder()
        guard let responseData = try? decoder.decode(T.Response.self, from: data) else {
            fatalError()
        }

        completion(.success(responseData))
    }
}

class QuipperTestTests: XCTestCase {

    private let requestExpectation = XCTestExpectation(description: "Get Video List Request")
    private var isExpectErrorResponse = false

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDecodeListItemModel() {
        let json = """
                        {
                            "title": "G12 Standard Level English<Syntax> Trial Ver.",
                            "presenter_name": "Masao Seki",
                            "description": "G12 Standard Level English <Syntax> Tense(1) Chapter 1",
                            "thumbnail_url": "https://recruit-a.akamaihd.net/pd/4477599122001/201512/23/4477599122001_4672789792001_4672787431001-vs.jpg?pubId=4477599122001",
                            "video_url": "http://recruit.brightcove.com.edgesuite.net/rtmp/4477599122001/201602/12/4477599122001_4751366325001_4672787431001.mp4?pubId=4477599122001&videoId=4672787431001",
                            "video_duration": 677187
                        }
                   """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let listItem = try! decoder.decode(VideoListItem.self, from: json)
        XCTAssert(listItem.title == "G12 Standard Level English<Syntax> Trial Ver.")
        XCTAssert(listItem.presenter == "Masao Seki")
        XCTAssert(listItem.description == "G12 Standard Level English <Syntax> Tense(1) Chapter 1")
        XCTAssert(listItem.thumbnail == URL(string: "https://recruit-a.akamaihd.net/pd/4477599122001/201512/23/4477599122001_4672789792001_4672787431001-vs.jpg?pubId=4477599122001"))
        XCTAssert(listItem.url == URL(string: "http://recruit.brightcove.com.edgesuite.net/rtmp/4477599122001/201602/12/4477599122001_4751366325001_4672787431001.mp4?pubId=4477599122001&videoId=4672787431001"))
        XCTAssert(listItem.duration == 677187)
    }

    func testVideoListRequest() {
        let client = LocalClient()
        client.send(VideoListRequest()) { (r) in
            switch r {
            case .success(let datas):
                XCTAssertTrue(datas.count == 5)
            case .failed:
                XCTFail("Local videoList request is failed")
            }
        }
    }

    func testViewModelWithData() {
        let viewModel = VideoListViewModel(client: LocalClient())
        viewModel.delegate = self
        viewModel.fetchData()

        wait(for: [requestExpectation], timeout: 10.0)
    }

    func testViewModelWithError() {
        isExpectErrorResponse = true

        var client = LocalClient()
        client.isRespondError = true
        let viewModel = VideoListViewModel(client: client)
        viewModel.delegate = self
        viewModel.fetchData()

        wait(for: [requestExpectation], timeout: 10.0)
    }
}

extension QuipperTestTests: VideoListViewModelProtocol {
    func videoListViewModelDidUpdateData(_ viewModel: VideoListViewModel) {
        XCTAssertFalse(isExpectErrorResponse)

        XCTAssertTrue(viewModel.itemCount == 5)

        XCTAssertNotNil(viewModel.getCellViewModel(at: 0))
        XCTAssertNil(viewModel.getCellViewModel(at: 10))
        XCTAssertNil(viewModel.getCellViewModel(at: -1))

        XCTAssertTrue(viewModel.getVideoUrl(at: 0) == URL(string: "http://recruit.brightcove.com.edgesuite.net/rtmp/4477599122001/201602/12/4477599122001_4751366325001_4672787431001.mp4?pubId=4477599122001&videoId=4672787431001"))
        XCTAssertNil(viewModel.getVideoUrl(at: 10))
        XCTAssertNil(viewModel.getVideoUrl(at: -1))

        XCTAssertTrue(viewModel.itemCount == 5)

        requestExpectation.fulfill()
    }

    func videoListViewModelUpdateDataFailed(_ error: Error) {
        XCTAssertTrue(isExpectErrorResponse)
        requestExpectation.fulfill()
    }
}
