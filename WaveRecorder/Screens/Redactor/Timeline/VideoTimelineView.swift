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

final class VideoTimelineView: UIView {
    
    //MARK: Variables
    
    private let backgroundMask = CAShapeLayer()
    private let progressLayer = CALayer()
    
    private var progress: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }
    
    private var frames = [UIImage]()
    
    
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
        progressLayer.backgroundColor = UIColor.darkGray.cgColor
    }
    
    
    //MARK: Configure
    
    func configure(withFrames frames: [CGImage]?) {
        guard 
            let frames,
            !frames.isEmpty
        else {
            os_log("ATTENTION <VideoTimelineView>: View configured with empty video frames!")
            return
        }
        
        frames.enumerated().forEach { index, frame in
            let imageFrame = UIImage(cgImage: frame)
            self.frames.append(imageFrame)
            self.setupImageView(withIndex: index)
        }
        
        setNeedsLayout()
    }
}

//MARK: - Setup

private extension VideoTimelineView {
    
    func setupLayers() {
        layer.addSublayer(progressLayer)
    }
    
    func setupImageView(withIndex index: Int) {
        let imageView = UIImageView()
        let indexValue = CGFloat(index)
        
        imageView.frame = CGRect(
            x: indexValue * 20.0,
            y: 0.0,
            width: 20.0,
            height: self.frame.height
        )
        imageView.image = self.frames[index]
        
        self.addSubview(imageView)
    }
}
