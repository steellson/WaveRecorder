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
    
    private var recordView = AssemblyBuilder.get(subModule: .record)
    private var recViewHeight = UIScreen.main.bounds.height * 0.15
    private lazy var recViewHeightConstraint: NSLayoutConstraint = {
        NSLayoutConstraint(
            item: recordView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: recViewHeight
        )
    }()
    
    private var tableViewCellHeight: CGFloat = 200

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
        viewModel.getRecords()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        seutpNavigationBar()
        updateTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupRecordViewHeight()
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        navigationItem.rightBarButtonItem = editButton
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
        searchController.searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func setupTableView() {
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tableView.layer.cornerRadius = 26
        tableView.estimatedRowHeight = 160
        tableView.keyboardDismissMode = .onDrag
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceVertical = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MainTableViewCell.self,
                           forCellReuseIdentifier: MainTableViewCell.mainTableViewCellIdentifier)
    }
    
    func updateTableView() {
        viewModel.dataSourceUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func setupRecordViewHeight() {
        viewModel.recordStarted = { [weak self] isRecording in
            
            self?.recViewHeightConstraint.constant = isRecording
            ? UIScreen.main.bounds.height * 0.25
            : UIScreen.main.bounds.height * 0.15
     
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 3
            ) {
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    
    //MARK: Constraints
    
    func setupConstrtaints() {
        guard let navBar = self.navigationController?.navigationBar else { return }
            
        NSLayoutConstraint.activate([
            recViewHeightConstraint,
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

        let cellViewModel = viewModel.makeViewModelForCell(atIndex: indexPath.row)
        cell.configureCell(withViewModel: cellViewModel)
        
        return cell
    }
}


//MARK: - TableView Delegate

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        false
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        UISwipeActionsConfiguration(actions: [ UIContextualAction(
            style: .destructive, 
            title: "Delete",
            handler: { action, view, result in
                self.tableView.beginUpdates()

                DispatchQueue.main.async { [weak self] in
                    guard let record = self?.viewModel.records[indexPath.row] else {
                        print("ERROR: Cannot delete record with swipe")
                        return
                    }
                    
                    self?.viewModel.delete(record: record, completion: { isDeleted in
                        if isDeleted {
                            self?.tableView.endUpdates()
                        }
                    })
                }
            }
        )])
    }
}


//MARK: - Search Reslut Updating

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.searchTextField.text else {
            return
        }
        viewModel.search(withText: searchText)
    }
}