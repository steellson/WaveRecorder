//
//  RecordView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 24.11.2023.
//

import UIKit


//MARK: - Impl

final class RecordView: UIView {
    
    var viewModel: RecordViewModelProtocol?
    
    private lazy var recButtonView = RoundedRecButtonView(radius: viewModel?.buttonRadius ?? 30)
        
    
    //MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)
        
        seutupContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupConstraints()
    }
}


//MARK: - Setup

private extension RecordView {
    
    func seutupContentView() {
        backgroundColor = R.Colors.primaryBackgroundColor
        addNewSubview(recButtonView)
    }
    

    //MARK: Constraints
    
    func setupConstraints() {
        guard let viewModel else {
            print("ERROR: Couldnt setup layout by the reaason of viewModel = nil")
            return
        }
        NSLayoutConstraint.activate([
            recButtonView.centerXAnchor.constraint(equalTo: centerXAnchor),
            recButtonView.heightAnchor.constraint(equalToConstant: viewModel.buttonRadius * 2),
            recButtonView.widthAnchor.constraint(equalToConstant: viewModel.buttonRadius * 2),
            recButtonView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }
}


//MARK: - RoundedRecButtonView Delegate

extension RecordView: RoundedRecButtonViewDelegate {
    
    func recButtonDidTapped() {
        if recButtonView.isRecording {

        } else {

        }
    }
}
