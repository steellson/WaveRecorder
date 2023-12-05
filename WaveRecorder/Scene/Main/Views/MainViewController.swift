//
//  MainViewController.swift.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import UIKit


//MARK: - Impl

final class MainViewController: UIViewController {
    
    private let editButton = UIBarButtonItem()
    private let titleLabel = UILabel()
    private let searchController = UISearchController()
    private let tableView = UITableView()
        
    private lazy var recordView = Assembly.builder.build(subModule: .record)
    private var recordViewHeight = UIScreen.main.bounds.height * 0.15
    
    private let viewModel: MainViewModelProtocol
    
        
    //MARK: Lifecycle
    
    init(
        viewModel: MainViewModelProtocol
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContentView()
        setupEditButton()
        setupTitleLabel()
        setupSearchController()
        setupTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        seutpNavigationBar()
        setupRecordingViewHeight()
        setupConstrtaints()
    }

    
    //MARK: Actions
    
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


//MARK: - Setup

private extension MainViewController {
    
    func seutpNavigationBar() {
        navigationController?.navigationBar.backgroundColor = R.Colors.primaryBackgroundColor
        navigationItem.rightBarButtonItem = editButton
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        navigationItem.searchController = searchController
    }
    
    func setupContentView() {
        view.backgroundColor = R.Colors.primaryBackgroundColor
        view.addNewSubview(recordView)
        view.addNewSubview(tableView)
    }
    
    func setupEditButton() {
        editButton.title = R.Strings.editButtonTitle.rawValue
        editButton.tintColor = .black
        editButton.target = self
        editButton.action = #selector(editButtonDidTapped)
    }
    
    func setupTitleLabel() {
        titleLabel.text = R.Strings.navigationTitleMain.rawValue
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textAlignment = .left
    }
    
    func setupSearchController() {
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
    
    func setupTableView() {
        tableView.backgroundColor = R.Colors.secondaryBackgroundColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tableView.layer.cornerRadius = 26
        tableView.estimatedRowHeight = 160
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceVertical = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MainTableViewCell.self,
                           forCellReuseIdentifier: MainTableViewCell.mainTableViewCellIdentifier)
    }
    
    func setupRecordingViewHeight() {
        guard let recView = (recordView as? RecordView) else { return }
        
        recView.onRecord = { [weak self] isRecording in
            UIView.animate(
                withDuration: 0.5,
                delay: 0.2,
                options: .curveEaseIn
            ) {
                self?.recordView.heightConstraint?.constant = isRecording
                ? UIScreen.main.bounds.height * 0.25
                : UIScreen.main.bounds.height * 0.15
            }
        }
    }
    
    
    //MARK: Constraints
    
    func setupConstrtaints() {
        guard let navBar = self.navigationController?.navigationBar else { return }
        
        NSLayoutConstraint.activate([
            recordView.heightAnchor.constraint(equalToConstant: recordViewHeight),
            recordView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recordView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            recordView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: recordView.topAnchor)
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
        
        cell.configureCell(withRecord: viewModel.records[indexPath.row])
        return cell
    }
}


//MARK: - TableView Delegate

extension MainViewController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) else { return }
//        cell.isSelected = true
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
