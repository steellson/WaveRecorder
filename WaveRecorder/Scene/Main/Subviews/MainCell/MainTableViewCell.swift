//
//  MainTableViewCell.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import UIKit


//MARK: - Impl

final class MainTableViewCell:  UITableViewCell {
    
    static let mainTableViewCellIdentifier = R.Strings.mainTableViewCellIdentifier.rawValue
    
    private var viewModel: MainCellViewModelProtocol!
    
    //MARK: Variables
    
    private let mainCellView = MainCellView()
    private let playToolbar = PlayToolbarView()
    
    
    //MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupContentView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clear()
    }
    
    
    //MARK: Methods
    
    func configureCell(withViewModel viewModel: MainCellViewModelProtocol) {
        self.viewModel = viewModel
        self.mainCellView.configureView(withRecord: viewModel.record)
        self.playToolbar.configureView(withRecord: viewModel.record)
    }
}


//MARK: - Setup

private extension MainTableViewCell {
    
    func setupContentView() {
        selectionStyle = .gray
        contentView.clipsToBounds = true
        contentView.backgroundColor = R.Colors.secondaryBackgroundColor
//        contentView.addNewSubview(mainCellView)
//        contentView.addNewSubview(playToolbar)
    }
    
    
    //MARK: Constriants

    func setupConstraints() {
        NSLayoutConstraint.activate([
//            contentView.topAnchor.constraint(equalTo: topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            contentView.heightAnchor.constraint(equalToConstant: 220),
//            
//            mainCellView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            mainCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            mainCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            mainCellView.bottomAnchor.constraint(equalTo: contentView.centerYAnchor),
//            
//            playToolbar.topAnchor.constraint(equalTo: contentView.centerYAnchor),
//            playToolbar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            playToolbar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            playToolbar.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func clear() {
        mainCellView.clearView()
    }
}
