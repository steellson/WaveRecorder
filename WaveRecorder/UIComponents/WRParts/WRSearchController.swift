//
//  WRSearchController.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.01.2024.
//

import UIKit
import OSLog


//MARK: - Input

struct WRSearchControllerInput {
    var fetchAllAction: () -> Void
    var searchWithTextAction: (String) -> Void
}


//MARK: - Impl

final class WRSearchController: UISearchController {
    
    private var input: WRSearchControllerInput?
    
    
    //MARK: Lifecycle
    
    init() {
        super.init(searchResultsController: nil)
        setupAppereance()
        setupSettings()
        setupDelegates()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAppereance()
        setupSettings()
        setupDelegates()
    }
    
    func setup(withInput input: WRSearchControllerInput) {
        self.input = input
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
            os_log("\(R.Strings.Errors.wrongFieldResponder.rawValue)")
            return
        }
        
        textField.text = ""
        textField.endEditing(true)
        textField.resignFirstResponder()
    }
    
    func updateResults(withText text: String) {
        guard let input else {
            os_log("ERROR: Input isn't setted!")
            return
        }
        
        input.searchWithTextAction(text.trimmingCharacters(in: .illegalCharacters))
    }
    
    func restoreResults() {
        guard let input else {
            os_log("ERROR: Input isn't setted!")
            return
        }
        
        input.fetchAllAction()
    }
}


//MARK: - SearchBar+TextField Delegate

extension WRSearchController: UISearchBarDelegate, UISearchTextFieldDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.isEmpty else { return }
        searchBar.resignFirstResponder()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchFieldShouldClear(textField)
        restoreResults()
        return false
    }
}


//MARK: - Search Reslut Updating

extension WRSearchController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.searchTextField.text else {
            os_log("ERROR: Couldnt recognize search field!")
            return
        }
        updateResults(withText: searchText)
    }
}
