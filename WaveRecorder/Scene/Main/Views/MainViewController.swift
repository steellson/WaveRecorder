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
    private let tableView = UITableView()
    
    private let recordingView = Assembly.builder.build(subModule: .record)
    
    private let viewModel: MainViewModelProtocol
    
    private var recordingViewHeight = UIScreen.main.bounds.height * 0.2
        
    
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
    
    
    //MARK: Seutp
    
    private func seutpNavigationBar() {
        navigationItem.rightBarButtonItem = editButton
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        navigationItem.searchController = searchController
    }
    
    private func setupContentView() {
        view.addNewSubview(tableView)
        view.addNewSubview(recordingView)
    }
    
    private func setupEditButton() {
        editButton.title = R.Strings.editButtonTitle.rawValue
        editButton.tintColor = .black
    }
    
    private func setupTitleLabel() {
        titleLabel.text = R.Strings.navigationTitleMain.rawValue
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
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
        tableView.backgroundColor = R.Colors.primaryBackgroundColor
        tableView.layer.cornerRadius = 14
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MainTableViewCell.self,
                           forCellReuseIdentifier: MainTableViewCell.mainTableViewCellIdentifier)
    }
    
    private func setupRecordingViewHeight() {
        guard let recView = (recordingView as? RecordingView) else { return }
        
        recView.onRecord = { [weak self] isRecording in
            UIView.animate(
                withDuration: 0.5,
                delay: 0.2,
                options: .curveEaseIn
            ) {
                self?.recordingView.heightConstraint?.constant = isRecording
                ? UIScreen.main.bounds.height * 0.33
                : UIScreen.main.bounds.height * 0.2
            }
        }
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
        setupRecordingViewHeight()
        
        NSLayoutConstraint.activate([
            recordingView.heightAnchor.constraint(equalToConstant: recordingViewHeight),
            recordingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recordingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            recordingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchController.searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            tableView.bottomAnchor.constraint(equalTo: recordingView.topAnchor)
        ])
    }
}


//MARK: - Data Source

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.mainTableViewCellIdentifier,
                                                       for: indexPath) as? MainTableViewCell else {
            print(R.Strings.dequeueMainTableViewCellError.rawValue)
            return UITableViewCell()
        }
        
        cell.configureCell(
            name: "Record 2020-20-01",
            date: "20.01.2020",
            duraiton: "04:17"
        )
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
