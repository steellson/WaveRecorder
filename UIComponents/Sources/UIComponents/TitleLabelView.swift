//
//  File.swift
//  
//
//  Created by Andrew Steellson on 12.02.2024.
//

import Foundation
import UIKit

//MARK: - Impl

final public class TitleLabelView: UILabel {
    
    //MARK: Init
    
    public init(
        text: String,
        tColor: UIColor,
        font: UIFont,
        alignment: NSTextAlignment = .center
    ) {
        super.init(frame: .zero)
        setupLabelView(
            text: text,
            tColor: tColor,
            font: font,
            alignment: alignment
        )
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        setupLabelView(
            text: "Title configured with error!",
            tColor: .black,
            font: .systemFont(ofSize: 12),
            alignment: .left
        )
    }
}

//MARK: - Setuup

private extension TitleLabelView {
    
    func setupLabelView(
        text: String,
        tColor: UIColor,
        font: UIFont,
        alignment: NSTextAlignment = .center
    ) {
        self.text = text
        self.textColor = tColor
        self.font = font
        self.textAlignment = alignment
        
        self.numberOfLines = 0
    }
}
