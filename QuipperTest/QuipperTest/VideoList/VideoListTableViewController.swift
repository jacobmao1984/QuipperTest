//
//  VideoListTableViewController.swift
//  QuipperTest
//
//  Created by Jacob Mao on 2018/06/28.
//  Copyright © 2018 JacobMao. All rights reserved.
//

import UIKit

class VideoListTableViewController: UITableViewController {

    // MARK: Private Properties
    private let viewModel: VideoListViewModel

    // MARK: Life Cycle
    init(viewModel: VideoListViewModel) {
        self.viewModel = viewModel
        
        super.init(style: .plain)
        
        self.viewModel.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = viewModel.estimatedRowHeight

        tableView.register(VideoListTableViewCell.self)
        
        viewModel.fetchData()
    }


}

// MARK: UITableViewDataSource
extension VideoListTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemCount
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: VideoListTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)

        guard let cellViewModel = viewModel.getCellViewModel(at: indexPath.row) else {
            return cell
        }

        cell.configureForViewMode(cellViewModel)

        return cell
    }
}

// MARK: VideoListViewModelProtocol
extension VideoListTableViewController: VideoListViewModelProtocol {
    func videoListViewModelDidUpdateData(_ viewModel: VideoListViewModel) {
        tableView.reloadData()
    }
    
    func videoListViewModelUpdateDataFailed(_ error: Error) {
        let errorAlert = UIAlertController(title: nil,
                                           message: error.localizedDescription,
                                           preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK",
                                           style: .default,
                                           handler: nil))
        present(errorAlert, animated: true, completion: nil)
    }
}
