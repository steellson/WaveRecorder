//
//  Resources.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import UIKit

enum R {
    
    //MARK: - Strings
    
    enum Strings: String {
        
        //MARK: Main Screen
        case navigationTitleMain = "All records"
        case editButtonTitle = "Edit"
        case stopEditButtonTitle = "Cancel"
        case searchTextFieldPlaceholder = "Search"
        
        //MARK: System Log Messages
        case dequeueMainTableViewCellError = "ERROR: Dequeue MainTableViewCell error!"
        
        //MARK: Identity
        case mainTableViewCellIdentifier = "MainTableViewCellIdentifier"
    }
    
    
    //MARK: - Colors
    
    enum Colors {
        static let primaryBackgroundColor = UIColor(red: 183/255, green: 198/255, blue: 206/255, alpha: 1)
        static let secondaryBackgroundColor = UIColor.white
    }
}
