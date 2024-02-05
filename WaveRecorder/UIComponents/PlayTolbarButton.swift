//
//  PlayTolbarButton.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 28.11.2023.
//

import UIKit

//MARK: - Type

public enum PlayToolbarButtonType {
    case goBack
    case play
    case stop
    case goForward
    case delete
}


//MARK: - Impl

@available(iOS 13.0, *)
public final class PlayTolbarButton: UIButton {
    
    public var type: PlayToolbarButtonType
    
    
    public init(
        type: PlayToolbarButtonType
    ) {
        self.type = type
        super.init(frame: .zero)
        
        setupButton(ofType: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupButton(ofType type: PlayToolbarButtonType) {
        switch type {
        case .goBack:
            setImage(UIImage(systemName: "gobackward.15"), for: .normal)
        case .play:
            setImage(UIImage(systemName: "play.fill"), for: .normal)
        case .stop:
            setImage(UIImage(systemName: "stop.fill"), for: .normal)
        case .goForward:
            setImage(UIImage(systemName: "goforward.15"), for: .normal)
        case .delete:
            setImage(UIImage(systemName: "trash"), for: .normal)
        }
        
        backgroundColor = .clear
        tintColor = .black
        transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
    }
}
