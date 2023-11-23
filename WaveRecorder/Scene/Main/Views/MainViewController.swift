//
//  MainViewController.swift.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import UIKit


//MARK: - Impl

final class MainViewController: BaseController {
    
    private let editButton = UIBarButtonItem()
    private let titleLabel = UILabel()
    private let searchController = UISearchController()
    private let tableView = UITableView(frame: .zero)
    
    private let viewModel: MainViewModelProtocol

    
    //MARK: Init
    
    init(
        viewModel: MainViewModelProtocol
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Seutp methods
    
    private func seutpNavigationBar() {
        navigationItem.rightBarButtonItem = editButton
        navigationItem.titleView = titleLabel
        navigationItem.searchController = searchController
    }
    
    private func setupContentView() {
        view.addNewSubview(tableView)
    }
    
    private func setupEditButton() {
        editButton.title = R.Strings.editButtonTitle.rawValue
        editButton.tintColor = .black
    }
    
    private func setupTitleLabel() {
        titleLabel.text = R.Strings.navigationTitleMain.rawValue
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textAlignment = .left
    }
    
    private func setupSearchController() {
        searchController.searchBar.placeholder = R.Strings.searchTextFieldPlaceholder.rawValue
        searchController.searchBar.searchTextField.backgroundColor = R.Colors.secondaryBackgroundColor
        searchController.searchBar.backgroundColor = R.Colors.primaryBackgroundColor
        searchController.searchBar.tintColor = .black
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.searchBarStyle = .minimal
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
    }
    
    private func setupTableView() {
        tableView.tableHeaderView = titleLabel
        tableView.backgroundColor = R.Colors.primaryBackgroundColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MainTableViewCell.self,
                           forCellReuseIdentifier: MainTableViewCell.mainTableViewCellIdentifier)
    }
    
}


//MARK: - Base

extension MainViewController {
    
    override func setupView() {
        super.setupView()
        setupContentView()
        setupEditButton()
        setupTitleLabel()
        setupSearchController()
        setupTableView()
    }
    
    override func setupNavBar() {
        super.setupNavBar()
        seutpNavigationBar()
    }
    
    override func setupLayout() {
        super.setupLayout()
                
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchController.searchBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}


//MARK: - Data Source

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.mainTableViewCellIdentifier,
                                                       for: indexPath) as? MainTableViewCell else {
            print(R.Strings.dequeueMainTableViewCellError.rawValue)
            return UITableViewCell()
        }
        
        cell.configureCell()
        return cell
    }
    
    
}


//MARK: - TableView Delegate

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}


//MARK: - SearchBar Delegate

extension MainViewController: UISearchBarDelegate {
    
    
}


//MARK: - Search Reslut Updating

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
