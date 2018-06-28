//
//  QuipperTestTests.swift
//  QuipperTestTests
//
//  Created by ST21073 on 2018/06/28.
//  Copyright © 2018 JacobMao. All rights reserved.
//

import XCTest
@testable import QuipperTest

class QuipperTestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
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
}
