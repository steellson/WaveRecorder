//
//  MainViewController.swift.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import UIKit

//MARK: - Types

typealias DataSource = UITableViewDiffableDataSource<Section, Record>
typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Record>


//MARK: - Impl

final class MainViewController: BaseController {
    
    private let editButton = UIBarButtonItem()
    private let titleLabel = UILabel()
    private let searchController = UISearchController()
    private let tableView = UITableView()
    
    private var dataSource: DataSource!
    
    private let recordingView = Assembly.builder.build(subModule: .record)
    
    private let viewModel: MainViewModelProtocol
    
    private var recordingViewHeight = UIScreen.main.bounds.height * 0.15
        
    
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
        editButton.target = self
        editButton.action = #selector(editButtonDidTapped)
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
        tableView.backgroundColor = R.Colors.secondaryBackgroundColor
        tableView.showsVerticalScrollIndicator = false
        tableView.layer.cornerRadius = 26
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
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
                ? UIScreen.main.bounds.height * 0.25
                : UIScreen.main.bounds.height * 0.15
            }
        }
    }
    
    
    //MARK: Methods
    
    @objc
    private func editButtonDidTapped() {
        UIView.animate(withDuration: 0.5) {
            self.tableView.isEditing.toggle()
            
            self.editButton.title = self.tableView.isEditing
            ? R.Strings.stopEditButtonTitle.rawValue
            : R.Strings.editButtonTitle.rawValue
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
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: recordingView.topAnchor)
        ])
    }
}


///MARK: - DataSource

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MainTableViewCell.mainTableViewCellIdentifier,
            for: indexPath) as? MainTableViewCell else {
            print("ERROR: Cant dequeue reusable cell")
            return UITableViewCell()
        }
        
        let record = viewModel.records[indexPath.row]
        let dateString = Formatter.instance.formatDate(record.date)
        let durationString = Formatter.instance.formatDuration(record.duration)
        
        cell.configureCell(
            name: record.name,
            date: dateString,
            duraiton: durationString
        )
        return cell
    }
}


//MARK: - TableView Delegate

extension MainViewController: UITableViewDelegate {
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        UISwipeActionsConfiguration(actions: [ UIContextualAction(
            style: .destructive, 
            title: "Delete",
            handler: { action, view, result in
                self.tableView.beginUpdates()
                
                let record = self.viewModel.records[indexPath.row]
                self.viewModel.deleteRecord(withID: record.id) { [weak self] res in
                    switch res {
                    case .success:
                        self?.viewModel.records.remove(at: indexPath.row)
                        self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    case .failure(let error):
                        print(error)
                    }
                }
                self.tableView.endUpdates()
            }
        )])
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
