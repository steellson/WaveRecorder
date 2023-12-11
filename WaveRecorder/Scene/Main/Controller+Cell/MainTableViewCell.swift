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
    
    private let mainCellView = MainCellView(frame: .zero)
    private let playToolbar = PlayToolbarView(frame: .zero)

    private var timer: Timer?
    
    //MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
        setupContentView()
        seutpDelegates()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clear()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePlayToolbar()
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
        contentView.addNewSubview(mainCellView)
        contentView.addNewSubview(playToolbar)
    }
    
    func seutpDelegates() {
        mainCellView.delegate = self
        playToolbar.delegate = self
    }

    
    //MARK: Constriants

    func setupConstraints() {
        NSLayoutConstraint.activate([
            mainCellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainCellView.bottomAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            playToolbar.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -12),
            playToolbar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            playToolbar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            playToolbar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func clear() {
        mainCellView.clearView()
        playToolbar.clearView()
    }
    
    func updatePlayToolbar() {
        viewModel.onPlaying = { [weak self] time in
            self?.timer = Timer.scheduledTimer(withTimeInterval: time, repeats: true) { _ in
                self?.playToolbar.updatePlayingTime(withValue: time)
            }
        }
        
        viewModel.onPause = { [weak self] onPause in
            if onPause {
                self?.timer?.invalidate()
            }
        }
    }
}

//MARK: - MainCellView Delegate

extension MainTableViewCell: MainCellViewDelegate {
    
    func rename(withNewName name: String) {
        viewModel.rename(withNewName: name)
    }
}


//MARK: - PlayToolbar Delegate

extension MainTableViewCell: PlayToolbarViewDelegate {
    
    func goBack() {
        viewModel.goBack()
    }
    
    func playPause() {
        viewModel.isPlaying
        ? viewModel.pause()
        : viewModel.play()
    }
    
    func goForward() {
        viewModel.goForward()
    }
    
    func deleteRecord() {
        viewModel.deleteRecord()
    }
    
    func progressDidChanged(onValue value: Float) {
        viewModel.play(onTime: value)
    }
}
