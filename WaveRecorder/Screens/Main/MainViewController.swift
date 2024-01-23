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
    
    private lazy var recViewHeightConstraint: NSLayoutConstraint = {
        NSLayoutConstraint(
            item: recordView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: UIScreen.main.bounds.height * 0.15
        )
    }()
    
    private let viewModel: MainViewModel

    
    //MARK: Lifecycle
    
    init(
        viewModel: MainViewModel
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
        let searchControllerInput = WRSearchControllerInput(
            fetchAllAction: viewModel.fetchAll,
            searchWithTextAction: viewModel.search
        )
        searchController.setup(withInput: searchControllerInput)
    }
    
    func setupTableView() {
        let tableViewInput = WRTableViewInput(
            numberOfItems: viewModel.numberOfItems,
            tableViewCellHeight: viewModel.tableViewCellHeight,
            makeViewModelForCellAction: viewModel.makeViewModelForCell,
            deleteAction: viewModel.delete
        )
        tableView.setup(withInput: tableViewInput)
        tableView.register(RecordCell.self, forCellReuseIdentifier: RecordCell.recordCellIdentifier)
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
