//
//  VideoListItem.swift
//  QuipperTest
//
//  Created by ST21073 on 2018/06/28.
//  Copyright © 2018 JacobMao. All rights reserved.
//

import Foundation

struct VideoListItem: Decodable {

    private enum CodingKeys:String, CodingKey {
        case title
        case presenter = "presenter_name"
        case description
        case thumbnail = "thumbnail_url"
        case url = "video_url"
        case duration = "video_duration"
    }

    private(set) var title: String
    private(set) var presenter: String
    private(set) var description: String
    private(set) var thumbnail: URL
    private(set) var url: URL
    private(set) var duration: TimeInterval

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey:.title)
        self.presenter = try container.decode(String.self, forKey: .presenter)
        self.description = try container.decode(String.self, forKey: .description)
        self.thumbnail = try container.decode(URL.self, forKey:.thumbnail)
        self.url = try container.decode(URL.self, forKey: .url)
        self.duration = try container.decode(TimeInterval.self, forKey: .duration)
    }
}
