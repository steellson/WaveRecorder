//
//  MainTableViewCell.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import UIKit

//MARK: - Impl

final class MainTableViewCell: BaseCell {
    
    static let mainTableViewCellIdentifier = R.Strings.mainTableViewCellIdentifier.rawValue
    
    
    //MARK: Variables

    private let mainContainerView = UIView()
    private let mainCellView = MainCellView()
    private let playToolbar = Assembly.builder.build(subModule: .playToolbar)
    
    private lazy var collapsedConstraint: NSLayoutConstraint = {
        let const = NSLayoutConstraint(
            item: playToolbar,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: mainContainerView,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )
        const.priority = .defaultLow
        return const
    }()
    
    private lazy var expandedConstraint: NSLayoutConstraint = {
        let const = NSLayoutConstraint(
            item: mainCellView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: mainContainerView,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )
        const.priority = .defaultLow
        return const
    }()
    
    override var isSelected: Bool {
        didSet {
            print("selected")
            updateAppereance()
        }
    }
    
    
    func configureCell(name: String, date: String, duraiton: String) {
        mainCellView.configureView(name: name, date: date, duraiton: duraiton)
    }

    
    //MARK: Setup
    
    private func setupContentView() {
        selectionStyle = .gray
        contentView.clipsToBounds = true
        
        contentView.addNewSubview(mainContainerView)
        mainContainerView.addNewSubview(mainCellView)
        mainContainerView.addNewSubview(playToolbar)
    }

    
    private func setupToolBar() {

    }
    
    
    //MARK: - Methods
    
    private func updateAppereance() {
        playToolbar.isHidden = !isSelected
        collapsedConstraint.isActive = !isSelected
        expandedConstraint.isActive = isSelected
    }
}
            
//MARK: - Base

extension MainTableViewCell {
    
    override func setupCell() {
        super.setupCell()
        setupContentView()
        setupToolBar()
    }
    
    override func setupCellLayout() {
        super.setupCellLayout()
        
        NSLayoutConstraint.activate([
            mainContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            mainCellView.topAnchor.constraint(equalTo: mainContainerView.topAnchor),
            mainCellView.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor),
            mainCellView.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor),
            mainCellView.heightAnchor.constraint(equalToConstant: 60),
//            collapsedConstraint,
            
            playToolbar.topAnchor.constraint(equalTo: mainCellView.bottomAnchor),
            playToolbar.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor),
            playToolbar.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor),
            playToolbar.heightAnchor.constraint(equalToConstant: 60),
//            expandedConstraint

        ])
    }
    
    override func clearCell() {
        super.clearCell()
        mainCellView.clearView()
    }
}
