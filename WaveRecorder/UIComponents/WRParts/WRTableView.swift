//
//  WRTableView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.01.2024.
//

import UIKit
import OSLog


//MARK: - Input

struct WRTableViewInput {
    let numberOfItems: Int
    let tableViewCellHeight: CGFloat
    let makeViewModelForCellAction: (_ indexPath: IndexPath) -> RecordCellViewModel
    let deleteAction: (_ indexPath: IndexPath) -> Void
}


//MARK: - Impl

final class WRTableView: UITableView {
    
    private var input: WRTableViewInput?
        
    
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

    func configure(withInput input: WRTableViewInput) {
        self.input = input
    }
}


//MARK: - Setup

private extension WRTableView {
    
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

extension WRTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let input else {
            os_log("ERROR: Input isn't setted!")
            return 0
        }
        return input.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = dequeueReusableCell(
                withIdentifier: RecordCell.recordCellIdentifier,
                for: indexPath) as? RecordCell,
            let cellViewModel = input?.makeViewModelForCellAction(indexPath)
        else {
            os_log("\(R.Strings.Errors.cantDequeReusableCell.rawValue)")
            return UITableViewCell()
        }
        
        cell.configureCell(withViewModel: cellViewModel)
        
        return cell
    }
}


//MARK: - Delegate

extension WRTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let input else {
            os_log("ERROR: Input isn't setted!")
            return 0.0
        }
        return input.tableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        false
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        UISwipeActionsConfiguration(actions: [ UIContextualAction(
            style: .destructive,
            title: "Kill",
            handler: { _, _, _ in
                guard let input = self.input else {
                    os_log("ERROR: Input isn't setted!")
                    return
                }
                input.deleteAction(indexPath)
            }
        )])
    }
}
