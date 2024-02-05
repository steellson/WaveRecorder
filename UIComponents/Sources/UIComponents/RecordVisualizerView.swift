//
//  RecordVisualizerView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 25.12.2023.
//

import Foundation
import UIKit
import WRResources


//MARK: - Impl

final public class RecordVisualizerView: UIView {
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.backgroundColor = RColors.primaryBackgroundColor
        view.distribution = .fillEqually
        view.spacing = 4
        view.axis = .horizontal
        return view
    }()
    
    //MARK: Variables
    
    private var numbreOfColumns: Int = 10
    private var duration: Double = 0.2
    private var rate: Double = 0.5
    private var color: UIColor = .black
    
    private var timer: Timer?
    
    
    //MARK: Init
    
    public init() {
        super.init(frame: .zero)
        setupView()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    //MARK: Configure
    
    public func configureWith(
        numbreOfColumns: Int,
        duration: Double,
        rate: Double,
        color: UIColor = .black
    ) {
        self.numbreOfColumns = numbreOfColumns
        self.duration = duration
        self.rate = rate
        self.color = color
        self.setupStackViewContent()
    }
               
    
    //MARK: Setup
    
    private func setupView() {
        backgroundColor = RColors.primaryBackgroundColor
        addSubview(stackView)
    }
    
    private func setupStackViewContent() {
        (0..<numbreOfColumns).forEach { _ in
            let view = self.makeColumnView()
            let height = self.makeRandomHeight()
            
            view.transform = CGAffineTransform(scaleX: 1, y: height)
            
            self.stackView.addArrangedSubview(view)
        }
    }
    
    private func resetStackViewContent() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stackView.layoutIfNeeded()
    }
    
    private func setupLayout() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}


//MARK: - Public

public extension RecordVisualizerView {
    
    func animationStart() {
        setupStackViewContent()
        setupLayout()
        startTimer()
    }
    
    func animationStop() {
        resetStackViewContent()
        stopTimer()
    }
}


//MARK: - Helpers (Private)

private extension RecordVisualizerView {
    
    func makeColumnView() -> UIView {
        let view = UIView()
        view.backgroundColor = color
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func makeRandomHeight() -> CGFloat {
        let projectedValue = Double(arc4random_uniform(10)) * 0.1
        let minimumValue = 0.05
        let maximumValue = 0.95
        
        if projectedValue < minimumValue {
            return minimumValue
        } else if projectedValue > maximumValue {
            return maximumValue
        } else {
            return projectedValue
        }
    }
    
    func transformSubviews() {
        stackView.arrangedSubviews.forEach {
            $0.transform = CGAffineTransform(
                scaleX: 1,
                y: self.makeRandomHeight()
            )
        }
    }
    
    @objc
    func makeImpulseAnimated() {
        UIView.animate(
            withDuration: self.duration,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1
        ) {
            self.transformSubviews()
        } completion: { _ in
            UIView.animate(
                withDuration: self.duration
            ) {
                self.transformSubviews()
            }
        }
    }
}


//MARK: - Timer (Private)

private extension RecordVisualizerView {
    
    private func startTimer() {
        self.timer = Timer.scheduledTimer(
            timeInterval: rate,
            target: self,
            selector: #selector(makeImpulseAnimated),
            userInfo: nil,
            repeats: true
        )
    }
    
    private func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}
