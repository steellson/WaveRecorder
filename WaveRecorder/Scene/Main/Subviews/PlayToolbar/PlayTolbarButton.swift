//
//  PlayTolbarButton.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 28.11.2023.
//

import UIKit

//MARK: - Type

enum PlayToolbarButtonType {
    case goBack
    case play
    case goForward
    case delete
}


//MARK: - Impl

final class PlayTolbarButton: UIButton {
    
    var type: PlayToolbarButtonType
    
    init(
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
        backgroundColor = .clear
        tintColor = .black
        
        switch type {
        case .goBack:
            setImage(UIImage(systemName: "gobackward.15"), for: .normal)
        case .play:
            setImage(UIImage(systemName: "playpause.fill"), for: .normal)
        case .goForward:
            setImage(UIImage(systemName: "goforward.15"), for: .normal)
        case .delete:
            setImage(UIImage(systemName: "trash"), for: .normal)
        }
    }
}
