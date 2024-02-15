//
//  MainViewController.swift.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import OSLog
import UIKit
import WRParts
import WRResources
import UIComponents


//MARK: - Impl

final class MainViewController: UIViewController {
    
    private let editButton = UIBarButtonItem()
    
    private let titleLabel = TitleLabelView(
        text: WRTitles.navigationTitleMain,
        tColor: .black,
        font: .systemFont(ofSize: 26, weight: .bold),
        alignment: .left
    )
    
    private let searchController = WRSearchController(
        placeholderText: WRTitles.searchTextFieldPlaceholder
    )
    
    private let tableView = MainTableView(
        frame: .zero, 
        style: .plain
    )
    
    private lazy var recordBarView = viewModel.makeRecordBar()
    
    private lazy var recViewHeightConstraint: NSLayoutConstraint = {
        NSLayoutConstraint(
            item: recordBarView,
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
        setupSearchController()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupTableView()
        setupConstrtaints()
        setupRecordViewHeight()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupEditButton()
        seutpNavigationBar()
        activateNorifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeNotifications()
    }
    
    
    //MARK: Actions
    
    @objc
    private func editButtonDidTapped() {
        guard viewModel.numberOfItems != 0 else { return }
        
        Task {
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
        view.backgroundColor = WRColors.primaryBackgroundColor
        view.addNewSubview(recordBarView)
        view.addNewSubview(tableView)
    }
    
    func setupEditButton() {
        editButton.title = WRTitles.editButtonTitle
        editButton.tintColor = .black
        editButton.target = self
        editButton.action = #selector(editButtonDidTapped)
        editButton.isHidden = viewModel.numberOfItems == 0
    }
    
    func setupSearchController() {
        let searchControllerInput = WRSearchControllerInput(
            searchWithTextAction: viewModel.search, 
            updateDataAction: viewModel.updateData
        )
        searchController.configure(withInput: searchControllerInput)
    }
    
    func setupTableView() {
        tableView.configure(withViewModel: viewModel)
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.cellIdentifier)
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
            recordBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recordBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            recordBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: recordBarView.topAnchor)
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
            ? WRTitles.stopEditButtonTitle
            : WRTitles.editButtonTitle
        }
    }
    
    func animateUpdatedLayout() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1
        ) {
            Task {
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
