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
    private let carretView = CarretView()
    
    
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
        setupCarretView()
        
        setNeedsLayout()
    }
}

//MARK: - Setup

private extension VideoFramesView {
    
    func setupBackgroundMask(withRect rect: CGRect) {
        backgroundMask.path = UIBezierPath(
            roundedRect: rect,
            cornerRadius: rect.height * cornerRadiusMultiplier
        ).cgPath
        layer.mask = backgroundMask
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
            height: frame.height
        )
        imageView.image = frames[index]
        
        addSubview(imageView)
    }
    
    func setupCarretView() {
        carretView.frame = CGRect(
            x: 0.1,
            y: 0.0,
            width: bounds.height * 0.15,
            height: bounds.height
        )
        carretView.configure(withDelegate: self)
        addSubview(carretView)
    }
}


//MARK: - CarretVeiw Delegate

extension VideoFramesView: CarretViewDelegate {
    
}
