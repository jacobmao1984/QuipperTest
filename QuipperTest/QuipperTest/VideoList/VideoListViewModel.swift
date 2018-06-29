//
//  VideoListViewModel.swift
//  QuipperTest
//
//  Created by Jacob Mao on 6/28/18.
//  Copyright © 2018 JacobMao. All rights reserved.
//

import Foundation

private extension TimeInterval {
    var clockRepresentation: String {
        if self <= 0 {
            return "0 : 0"
        }

        let ms = Int(self)

        let sec = ms / 1000 % 60
        let min = ms / 1000 / 60

        return "\(min) : \(sec)"
    }
}

struct VideoListItemViewModel {
    let title: String
    let desc: String
    let presenter: String
    let duration: String
    let imageUrl: URL
}

protocol VideoListViewModelProtocol: class {
    func videoListViewModelDidUpdateData(_ viewModel: VideoListViewModel) -> Void
    func videoListViewModelUpdateDataFailed(_ error: Error) -> Void
}

class VideoListViewModel {
    // MARK: Public Properties
    var itemCount: Int {
        return items.count
    }
    
    weak var delegate: VideoListViewModelProtocol?

    // MARK: Private Properties
    private let client: Client
    private var items = [VideoListItem]()
    private var cellViewModels = [VideoListItemViewModel]()

    // MARK: Life Cycle
    init(client: Client) {
        self.client = client
    }
}

// MARK: Public Methods
extension VideoListViewModel {
    func fetchData() {
        client.send(VideoListRequest()) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }

            switch result {
            case .success(let videos):
                DispatchQueue.global().async {
                    let viewModels = VideoListViewModel.generateCellViewModels(from: videos)

                    DispatchQueue.main.async {
                        strongSelf.items = videos
                        strongSelf.cellViewModels = viewModels
                        strongSelf.delegate?.videoListViewModelDidUpdateData(strongSelf)
                    }
                }
            case .failed(let e):
                strongSelf.delegate?.videoListViewModelUpdateDataFailed(e)
            }
        }
    }
    
    func getCellViewModel(at index: Int) -> VideoListItemViewModel? {
        if index < 0 || index >= cellViewModels.count {
            return nil
        }
        
        return cellViewModels[index]
    }
    
    func getVideoUrl(at index: Int) -> URL? {
        if index < 0 || index >= items.count {
            return nil
        }
        
        return items[index].url
    }
}

// MARK: Private Methods
private extension VideoListViewModel {
    static func generateCellViewModels(from itemDatas: [VideoListItem]) -> [VideoListItemViewModel] {
        var result = [VideoListItemViewModel]()
        result.reserveCapacity(itemDatas.count)
        for itemData in itemDatas {
            let cellViewModel = VideoListItemViewModel(title: itemData.title,
                                                       desc: itemData.description,
                                                       presenter: itemData.presenter,
                                                       duration: itemData.duration.clockRepresentation,
                                                       imageUrl: itemData.thumbnail)
            result.append(cellViewModel)
        }
        
        return result
    }
}
