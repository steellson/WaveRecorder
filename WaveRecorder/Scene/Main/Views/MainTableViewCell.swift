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
    
    override var isSelected: Bool {
        didSet {
            print("selected")
            updateAppereance()
        }
    }
    
    
    func configureCell(withRecord record: Record) {
        mainCellView.configureView(
            name: record.name,
            date: Formatter.instance.formatDate(record.date),
            duraiton: Formatter.instance.formatDuration(record.duration)
        )
        
        guard let toolbar = playToolbar as? PlayToolbarView else {
            print("ERROR: Couldnt setup play toolbar")
            return
        }
        toolbar.configure(withRecord: record)
    }

    
    //MARK: Setup
    
    private func setupContentView() {
        selectionStyle = .gray
        contentView.clipsToBounds = true
        
        contentView.addNewSubview(mainContainerView)
        mainContainerView.addNewSubview(mainCellView)
        mainContainerView.addNewSubview(playToolbar)
    }
    
    
    //MARK: - Methods
    
    private func updateAppereance() {
        playToolbar.isHidden = !isSelected
    }
}
            
//MARK: - Base

extension MainTableViewCell {
    
    override func setupCell() {
        super.setupCell()
        setupContentView()
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
            
            playToolbar.topAnchor.constraint(equalTo: mainCellView.bottomAnchor),
            playToolbar.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor),
            playToolbar.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor),
            playToolbar.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    override func clearCell() {
        super.clearCell()
        mainCellView.clearView()
    }
}
