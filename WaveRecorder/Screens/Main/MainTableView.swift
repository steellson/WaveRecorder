//
//  MainTableView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 05.02.2024.
//

import UIKit
import OSLog
import WRResources

//MARK: - Input

public struct MainTableViewInput {
    let numberOfItems: Int
    let tableViewCellHeight: CGFloat
    let makeEditViewModelAction: (_ indexPath: IndexPath) -> EditViewModel
    let makePlayToolbarViewModelAction: (_ indexPath: IndexPath) -> PlayToolbarViewModel
    let deleteAction: (_ indexPath: IndexPath) async -> Void
}


//MARK: - Impl

final public class MainTableView: UITableView {
    
    private var input: MainTableViewInput?
        
    
    //MARK: Lifecycle
    
    override public init(
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

    public func configure(withInput input: MainTableViewInput) {
        self.input = input
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
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         input?.numberOfItems ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = dequeueReusableCell(
                withIdentifier: MainTableViewCell.cellIdentifier,
                for: indexPath) as? MainTableViewCell,
            let input
        else {
            os_log("\(RErrors.cantDequeReusableCell)")
            return UITableViewCell()
        }
        
        cell.configureCellWith(
            editViewModel: input.makeEditViewModelAction(indexPath),
            playToolbarViewModel: input.makePlayToolbarViewModelAction(indexPath)
        )
        
        return cell
    }
}


//MARK: - Delegate

extension MainTableView: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let input else {
            os_log("ERROR: Input isn't setted!")
            return 0.0
        }
        return input.tableViewCellHeight
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        false
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        UISwipeActionsConfiguration(actions: [ UIContextualAction(
            style: .destructive,
            title: "Kill",
            handler: { _, _, _ in
                guard let input = self.input else {
                    os_log("ERROR: Input isn't setted!")
                    return
                }
                Task { await input.deleteAction(indexPath) }
            }
        )])
    }
}
