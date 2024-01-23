//
//  WRSearchController.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.01.2024.
//

import UIKit

//MARK: - Impl

final class WRSearchController: UISearchController {
    
    //MARK: Init
    
    init() {
        super.init(searchResultsController: nil)
        setupAppereance()
        setupSettings()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAppereance()
        setupSettings()
    }
}

//MARK: - Setup

private extension WRSearchController {
    
    func setupAppereance() {
        searchBar.placeholder = R.Strings.Titles.searchTextFieldPlaceholder.rawValue
        searchBar.tintColor = .black
        searchBar.searchBarStyle = .minimal
    }
    
    func setupSettings() {
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        hidesNavigationBarDuringPresentation = false
        obscuresBackgroundDuringPresentation = false
        searchBar.setShowsCancelButton(false, animated: true)
    }
}
