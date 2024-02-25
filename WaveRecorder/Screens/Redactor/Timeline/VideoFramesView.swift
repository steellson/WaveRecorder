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
    private let progressLayer = CALayer()
    
    
    //MARK: Variables
    
    private var progress: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }
    
    private var frames = [UIImage]()
    private var singleFrameWidth: CGFloat = 10.0
    
    
    //MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    override func draw(_ rect: CGRect) {
        backgroundMask.path = UIBezierPath(
            roundedRect: rect,
            cornerRadius: rect.height * 0.25
        ).cgPath
        layer.mask = backgroundMask
        
        let progressRect = CGRect(
            origin: .zero,
            size: CGSize(
                width: rect.width * progress,
                height: rect.height
        ))
        
        progressLayer.frame = progressRect
        progressLayer.borderWidth = 0.5
        progressLayer.borderColor = UIColor.black.cgColor
        progressLayer.backgroundColor = UIColor.darkGray.cgColor
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
        
        self.singleFrameWidth = singleFrameWidth
        
        frames.enumerated().forEach { index, frame in
            let imageFrame = UIImage(cgImage: frame)
            self.frames.append(imageFrame)
            self.setupImageView(withIndex: index)
        }
        
        setNeedsLayout()
    }
}

//MARK: - Setup

private extension VideoFramesView {
    
    func setupLayers() {
        layer.addSublayer(progressLayer)
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
}
