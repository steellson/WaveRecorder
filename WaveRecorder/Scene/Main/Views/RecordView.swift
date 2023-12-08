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
    
    private let buttonRadius: CGFloat = 30
    private lazy var recButtonView: RoundedRecButtonView = RoundedRecButtonView(radius: buttonRadius)
        
    
    //MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)
        
        seutupContentView()
        recButtonView.delegate = self
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
            recButtonView.heightAnchor.constraint(equalToConstant: buttonRadius * 2),
            recButtonView.widthAnchor.constraint(equalToConstant: buttonRadius * 2),
            recButtonView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }
}


//MARK: - RoundedRecButtonView Delegate

extension RecordView: RoundedRecButtonViewDelegate {
    
    func recButtonDidTapped() {
        viewModel?.record(isRecording: !recButtonView.isRecording)
    }
}
