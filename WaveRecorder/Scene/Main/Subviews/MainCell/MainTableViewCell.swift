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
    
    //MARK: Variables
    
    private let mainCellView = MainCellView()
    private let playToolbar = Assembly.builder.build(subModule: .playToolbar)
    
    override var isSelected: Bool {
        didSet {
            updateAppereance()
            if isSelected {
                print("selected")
            } else {
                print("deselected")
            }
        }
    }
    
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
    
    func updateAppereance() {
//        playToolbar.isHidden = !isSelected
//        playToolbar.heightConstraint?.constant = isSelected ? 80 : 0
    }
}


//MARK: - Setup

private extension MainTableViewCell {
    
    func setupContentView() {
        selectionStyle = .gray
        contentView.clipsToBounds = true
        contentView.addNewSubview(mainCellView)
        contentView.addNewSubview(playToolbar)
    }
    
    
    //MARK: Constriants

    func setupConstraints() {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 220),
            
            mainCellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainCellView.bottomAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            playToolbar.topAnchor.constraint(equalTo: contentView.centerYAnchor),
            playToolbar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            playToolbar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            playToolbar.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func clear() {
        mainCellView.clearView()
    }
}
