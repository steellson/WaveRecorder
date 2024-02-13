//
//  RedactorViewController.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 09.02.2024.
//

import OSLog
import UIKit
import Photos
import UIComponents
import WRResources


//MARK: - Impl

final class RedactorViewController: UIViewController {
        
    private let titleLabel = TitleLabelView(
        text: RTitles.redactorMainTite,
        tColor: .darkGray,
        font: .systemFont(ofSize: 30, weight: .bold),
        alignment: .center
    )
    
    private let audioSectionView = AudioSectionView()
    private let videoSectionView = VideoSectionView()
    
    private lazy var isVideoSelected: Bool = {
        viewModel.videoRecordMetadata != nil
    }()
    
    private let viewModel: RedactorViewModel

    
    //MARK: Lifecycle
    
    init(
        viewModel: RedactorViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        seutpNavigationBar()
        setupContentView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupAudioSectionView()
        setupVideoSectionView()
        setupUpdatingLayout()
        setupConstrtaints()
    }
    
    
    //MARK: Actions
    
    @objc
    private func selectVideoButtonTapped() {
//        isVideoSelected.toggle()
//        videoSectionView.configureWith(emptyVideo: !isVideoSelected)
        
        Task {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .savedPhotosAlbum
            picker.mediaTypes = ["public.movie"]
            picker.allowsEditing = false
            present(picker, animated: true, completion: nil)
        }
    }
}


//MARK: - Setup

private extension RedactorViewController {
    
    func seutpNavigationBar() {
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: RTitles.selectVideo,
            style: .plain,
            target: self,
            action: #selector(selectVideoButtonTapped)
        )
    }
    
    func setupContentView() {
        view.backgroundColor = RColors.primaryBackgroundColor
        view.addNewSubview(titleLabel)
        view.addNewSubview(audioSectionView)
        view.addNewSubview(videoSectionView)
    }
    
    func setupAudioSectionView() {
        audioSectionView.configureWith(
            title: viewModel.audioRecordMetadata.name,
            date: viewModel.audioRecordMetadata.date,
            duration: viewModel.audioRecordMetadata.duration
        )
        audioSectionView.configureAppereanceWith(
            backgroundColor: RColors.secondaryBackgroundWithAlpha,
            shadowColor: UIColor.black
        )
    }
    
    func setupVideoSectionView() {
        videoSectionView.configureWith(emptyVideo: !isVideoSelected)
        videoSectionView.configureAppereanceWith(
            backgroundColor: RColors.secondaryBackgroundWithAlpha,
            shadowColor: UIColor.black,
            videoPlayerHeight: 300
        )
    }
    
    func setupUpdatingLayout() {
        viewModel.shouldUpdateInterface = { [weak self] isVideoEmpty in
            self?.videoSectionView.configureWith(emptyVideo: isVideoEmpty)
            self?.animateUpdatedLayout()
        }
    }
    
    
    //MARK: Constraints
    
    func setupConstrtaints() {
        guard let navBar = self.navigationController?.navigationBar else { return }
            
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            
            audioSectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 22),
            audioSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            audioSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            audioSectionView.heightAnchor.constraint(equalToConstant: 140),
       
            videoSectionView.topAnchor.constraint(equalTo: audioSectionView.bottomAnchor, constant: 22),
            videoSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            videoSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            videoSectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22)
        ])
    }
}

//MARK: Animation

private extension RedactorViewController {
    
    func animateUpdatedLayout() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1
        ) {
            Task {
                self.view.layoutSubviews()
            }
        }
    }
}


//MARK: - Picker & Navigation Delegate

extension RedactorViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        guard 
            let url = info[.mediaURL] as? URL
        else {
            picker.dismiss(animated: true)
            videoSectionView.configureWith(emptyVideo: true)
            return
        }
       
        Task {
            try await viewModel.update(videoMetadata: VideoRecordMetadata(name: url.lastPathComponent, url: url))
            picker.dismiss(animated: true)
        }
    }
}
