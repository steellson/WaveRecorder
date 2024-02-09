//
//  MainTableView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 05.02.2024.
//

import UIKit
import OSLog
import WRResources


//MARK: - Impl

final class MainTableView: UITableView {
    
    private var viewModel: MainViewModel?
        
    
    //MARK: Lifecycle
    
    override init(
        frame: CGRect,
        style: UITableView.Style
    ) {
        super.init(
            frame: frame,
            style: style
        )
       
        seutupAppereance()
        setupSettings()
        setupDelegate()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        seutupAppereance()
        setupSettings()
        setupDelegate()
    }

    func configure(withViewModel viewModel: MainViewModel) {
        self.viewModel = viewModel
    }
}


//MARK: - Setup

private extension MainTableView {
    
    func seutupAppereance() {
       backgroundColor = .white
       rowHeight = UITableView.automaticDimension
       layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
       layer.cornerRadius = 26
       estimatedRowHeight = 160
    }
    
    func setupSettings() {
        keyboardDismissMode = .onDrag
        showsVerticalScrollIndicator = false
        alwaysBounceVertical = true
    }
    
    func setupDelegate() {
        dataSource = self
        delegate = self
    }
}


//MARK: - Data Source

extension MainTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         viewModel?.numberOfItems ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = dequeueReusableCell(
                withIdentifier: MainTableViewCell.cellIdentifier,
                for: indexPath) as? MainTableViewCell,
            let viewModel,
            viewModel.numberOfItems > 0
        else {
            os_log("\(RErrors.cantDequeReusableCell)")
            return UITableViewCell()
        }
        
        cell.configureCellWith(
            editViewModel: viewModel.makeEditViewModel(withIndexPath: indexPath),
            playToolbarViewModel: viewModel.makePlayToolbarViewModel(withIndexPath: indexPath)
        )
        
        return cell
    }
}


//MARK: - Delegate

extension MainTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let viewModel else {
            os_log("ERROR: ViewModel isn't setted!")
            return 0.0
        }
        return viewModel.tableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        false
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        UISwipeActionsConfiguration(actions: [ UIContextualAction(
            style: .destructive,
            title: "Kill",
            handler: { _, _, _ in
                guard let viewModel = self.viewModel else {
                    os_log("ERROR: ViewModel isn't setted!")
                    return
                }
                viewModel.didSwipedForDelete(forIndexPath: indexPath)
            }
        )])
    }
}
