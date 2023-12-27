//
//  Resources.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import UIKit

enum R {
    
    //MARK: - Strings
    
    enum Strings {
     
        
        //MARK: Erorrs
        enum Errors: String {
            
            // Main View Model
            case cantGetRecordsFromStorage = "ERROR: Cant get records from storage! "
            case cantRenameRecord = "ERROR: Cant rename record! "
            case cantSearchRecordsWithText = "ERROR: Cant search records with text: "
            case cantDeleteRecordWithName = "ERROR: Cant delete record with name "
            
            //MARK: Main View
            case cantDequeReusableCell = "ERROR: Cant dequeue reusable cell"
            case wrongFieldResponder = "ERROR: Wrong field responder"
            
            
            //MARK: Edit View
            case editViewModelIsNotSetted = "ERROR: EditViewModel isn't setted!"
            
            
            //MARK: Play View Model
            case audioIsAlreadyPlaying = "ERROR: Audio is already playing!"

            //MARK: Play View
            case playViewModelIsNotSetted = "ERROR: PlayViewModel isn't setted!"
        }
        
        
        //MARK: Logs
        enum Logs: String {
            case recordDeleted = "SUCCESS: Record deleted. Name: "
        }
        
        
        //MARK: Titles
        enum Titles: String {
            
            //MARK: Main Screen
            case navigationTitleMain = "All records"
            case editButtonTitle = "Edit"
            case stopEditButtonTitle = "Cancel"
            case searchTextFieldPlaceholder = "Search"
        }
        
        
        //MARK: Identity
        enum Identifiers: String {
            case mainTableViewCellIdentifier = "MainTableViewCellIdentifier"
        }
    }
    
    
    
    //MARK: - Colors
    
    enum Colors {
        static let primaryBackgroundColor = UIColor(red: 183/255, green: 198/255, blue: 206/255, alpha: 1)
        static let secondaryBackgroundColor = UIColor.white
    }
}
