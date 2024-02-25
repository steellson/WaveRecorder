//
//  VideoTimelineView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 15.02.2024.
//

import OSLog
import UIKit
import WRResources


//MARK: - Impl

final class VideoFramesView: UIView {
    
    private let backgroundMask = CAShapeLayer()
    private let carretView = UIView()
    
    
    //MARK: Variables
    
    private var frames = [UIImage]()

    private var singleFrameWidth: CGFloat = 10.0
    private var cornerRadiusMultiplier: CGFloat = 0.25
    
    
    //MARK: Draw
    
    override func draw(_ rect: CGRect) {
        setupBackgroundMask(withRect: rect)
    }
    
    
    //MARK: Configure
    
    func configure(withFrames frames: [CGImage]?, singleFrameWidth: CGFloat) {
        guard
            let frames,
            !frames.isEmpty
        else {
            os_log("ATTENTION <VideoTimelineView>: View configured with empty video frames!")
            return
        }
        
        setupFrames(frames, width: singleFrameWidth)
        seutpCarretView()
        animateCarretViewOnAppear()
        
        setNeedsLayout()
    }
}

//MARK: - Setup

private extension VideoFramesView {
    
    func setupBackgroundMask(withRect rect: CGRect) {
        self.backgroundMask.path = UIBezierPath(
            roundedRect: rect,
            cornerRadius: rect.height * cornerRadiusMultiplier
        ).cgPath
        self.layer.mask = backgroundMask
    }
    
    func setupFrames(_ frames: [CGImage], width: CGFloat) {
        self.singleFrameWidth = width

        frames.enumerated().forEach { index, frame in
            let imageFrame = UIImage(cgImage: frame)
            self.frames.append(imageFrame)
            self.setupImageView(withIndex: index)
        }
    }
    
    func setupImageView(withIndex index: Int) {
        let imageView = UIImageView()
        let indexValue = CGFloat(index)
        
        imageView.frame = CGRect(
            x: indexValue * singleFrameWidth,
            y: 0.0,
            width: singleFrameWidth,
            height: self.frame.height
        )
        imageView.image = self.frames[index]
        
        self.addSubview(imageView)
    }
    
    func seutpCarretView() {
        let carretWidth = 5.0
        carretView.frame = CGRect(
            x: 0.1,
            y: 0,
            width: carretWidth,
            height: bounds.height + carretWidth
        )
        carretView.backgroundColor = .white
        carretView.layer.borderColor = UIColor.black.cgColor
        carretView.layer.borderWidth = 1
        carretView.layer.cornerRadius = 1
        
        self.addSubview(carretView)
    }
}


//MARK: - Animation

private extension VideoFramesView {
    
    func animateCarretViewOnAppear() {
        carretView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        carretView.backgroundColor = .clear
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0.5,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: [.autoreverse]
        ) {
            self.carretView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.carretView.backgroundColor = .white
        }
    }
}
