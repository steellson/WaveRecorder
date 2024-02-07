//
//  WRSearchController.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.01.2024.
//

import UIKit
import OSLog


//MARK: - Input

public struct WRSearchControllerInput {
    let fetchAllAction: () async -> Void
    let searchWithTextAction: (String) async -> Void
    
    public init(
        fetchAllAction: @escaping () async -> Void,
        searchWithTextAction: @escaping (String) async -> Void
    ) {
        self.fetchAllAction = fetchAllAction
        self.searchWithTextAction = searchWithTextAction
    }
}


//MARK: - Impl

public final class WRSearchController: UISearchController {
    
    private var input: WRSearchControllerInput?
    
    
    //MARK: Lifecycle
    
    public init(placeholderText: String) {
        super.init(searchResultsController: nil)
        setupAppereance(withPlaceholderText: placeholderText)
        setupSettings()
        setupDelegates()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAppereance(withPlaceholderText: "Search")
        setupSettings()
        setupDelegates()
    }
    
    public func configure(withInput input: WRSearchControllerInput) {
        self.input = input
    }
}


//MARK: - Setup

private extension WRSearchController {
    
    func setupAppereance(withPlaceholderText text: String) {
        searchBar.placeholder = text
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
    
    func setupDelegates() {
        searchBar.searchTextField.delegate = self
        searchBar.delegate = self
        searchResultsUpdater = self
    }
}


//MARK: - Private methods

private extension WRSearchController {
    
    func searchFieldShouldClear(_ textField: UITextField) {
        guard textField == searchBar.searchTextField else {
            os_log("ERROR <WRSearchController>: Cant get search bar text field!")
            return
        }
        
        textField.text = ""
        textField.endEditing(true)
        textField.resignFirstResponder()
    }
    
    func updateResults(withText text: String) {
        guard let input else {
            os_log("ERROR <WRSearchController>: Input isn't setted!")
            return
        }
        Task {
            await input.searchWithTextAction(text.trimmingCharacters(in: .illegalCharacters))
        }
    }
    
    func restoreResults() {
        guard let input else {
            os_log("ERROR <WRSearchController>: Input isn't setted!")
            return
        }
        Task {
            await input.fetchAllAction()
        }
    }
}


//MARK: - SearchBar+TextField Delegate

extension WRSearchController: UISearchBarDelegate, UISearchTextFieldDelegate {
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.isEmpty else {
            updateResults(withText: searchText)
            return
        }
        searchBar.resignFirstResponder()
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchFieldShouldClear(textField)
        restoreResults()
        return false
    }
}


//MARK: - Search Reslut Updating

extension WRSearchController: UISearchResultsUpdating {
    
    public func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.searchTextField.text else {
            os_log("ERROR <WRSearchController>: Couldnt recognize search field!")
            return
        }
        
        updateResults(withText: searchText)
    }
}
