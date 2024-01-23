//
//  MainViewController.swift.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import OSLog
import UIKit


//MARK: - Impl

final class MainViewController: UIViewController, IsolatedControllerModule {
    
    private let editButton = UIBarButtonItem()
    private let titleLabel = UILabel()
    private let searchController = WRSearchController()
    private let tableView = WRTableView(frame: .zero, style: .plain)
    
    private lazy var recordView = viewModel.makeRecordView()
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
        setupTitleLabel()
        setupSearchController()
        setupTableView()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupEditButton()
        seutpNavigationBar()
        activateNorifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupRecordViewHeight()
        setupConstrtaints()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeNotifications()
    }
    
    
    //MARK: Actions
    
    @objc
    private func editButtonDidTapped() {
        guard viewModel.numberOfItems != 0 else { return }
        
        DispatchQueue.main.async { [unowned self] in
            self.animateEditButton()
        }
    }
}


//MARK: - Setup

private extension MainViewController {
    
    func seutpNavigationBar() {
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
        editButton.title = R.Strings.Titles.editButtonTitle.rawValue
        editButton.tintColor = .black
        editButton.target = self
        editButton.action = #selector(editButtonDidTapped)
        editButton.isHidden = viewModel.numberOfItems == 0
    }
    
    func setupTitleLabel() {
        titleLabel.text = R.Strings.Titles.navigationTitleMain.rawValue
        titleLabel.textColor = .black
        titleLabel.backgroundColor = R.Colors.primaryBackgroundColor
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textAlignment = .left
    }
    
    func setupSearchController() {
        searchController.searchBar.searchTextField.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RecordCell.self,
                           forCellReuseIdentifier: RecordCell.recordCellIdentifier)
    }

    func setupRecordViewHeight() {
        viewModel.shouldUpdateInterface = { [weak self] isRecording in
            
            self?.recViewHeightConstraint.constant = isRecording
            ? UIScreen.main.bounds.height * 0.25
            : UIScreen.main.bounds.height * 0.15
     
            self?.animateUpdatedLayout()
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

//MARK: Notifications

private extension MainViewController {
    
    func activateNorifications() {
        viewModel.activateNotification(
            withName: UIResponder.keyboardWillHideNotification,
            selector: #selector(adjustForKeyboard),
            from: self
        )
        viewModel.activateNotification(
            withName: UIResponder.keyboardWillChangeFrameNotification,
            selector: #selector(adjustForKeyboard),
            from: self
        )
    }
    
    func removeNotifications() {
        viewModel.removeNotification(
            withName: UIResponder.keyboardWillHideNotification,
            from: self
        )
        viewModel.removeNotification(
            withName: UIResponder.keyboardWillChangeFrameNotification,
            from: self
        )
    }
}


//MARK: Animation

private extension MainViewController {
    
    func animateEditButton() {
        UIView.animate(withDuration: 0.3) {
            self.tableView.isEditing.toggle()
            
            self.editButton.title = self.tableView.isEditing
            ? R.Strings.Titles.stopEditButtonTitle.rawValue
            : R.Strings.Titles.editButtonTitle.rawValue
        }
    }
    
    func animateUpdatedLayout() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1
        ) {
            DispatchQueue.main.async { [unowned self] in
                self.setupEditButton()
                self.tableView.reloadData()
            }
        }
    }
}


//MARK: - Hide Keyboard

private extension MainViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc 
    func dismissKeyboard() {
        searchController.searchBar.searchTextField.endEditing(true)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard
            let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
            return
        }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            tableView.contentInset = .zero
        } else {
            tableView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom,
                right: 0
            )
        }
        
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
}


//MARK: - DataSource

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard 
            let cell = tableView.dequeueReusableCell(
                withIdentifier: RecordCell.recordCellIdentifier,
                for: indexPath
            ) as? RecordCell
        else {
            os_log("\(R.Strings.Errors.cantDequeReusableCell.rawValue)")
            return UITableViewCell()
        }

        let cellViewModel = viewModel.makeViewModelForCell(forIndexPath: indexPath)
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
            title: "Kill",
            handler: { _, _, _ in
                self.viewModel.delete(forIndexPath: indexPath)
            }
        )])
    }
}


//MARK: - SearchBar+Field Delegate

extension MainViewController: UISearchBarDelegate, UISearchTextFieldDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.isEmpty else { return }
        searchBar.resignFirstResponder()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        guard 
            textField == searchController.searchBar.searchTextField
        else {
            os_log("\(R.Strings.Errors.wrongFieldResponder.rawValue)")
            return false
        }
        
        textField.text = ""
        textField.endEditing(true)
        textField.resignFirstResponder()
        
        viewModel.fetchAll()
        
        return false
    }
}


//MARK: - Search Reslut Updating

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.searchTextField.text else {
            return
        }
        
        viewModel.search(withText: searchText.trimmingCharacters(in: .illegalCharacters))
    }
}
