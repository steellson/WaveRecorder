//
//  RedactorViewController.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 09.02.2024.
//

import OSLog
import UIKit
import UIComponents
import WRResources

typealias VideoPickerDelegate = UIImagePickerControllerDelegate & UINavigationControllerDelegate


//MARK: - Impl

final class RedactorViewController: UIViewController {
        
    private let titleLabel = TitleLabelView(
        text: WRTitles.redactorMainTite,
        tColor: WRColors.primaryText,
        font: .systemFont(ofSize: 22, weight: .bold),
        alignment: .center
    )
    
    private let audioSectionView = AudioSectionView()
    private let videoSectionView = VideoSectionView()
    
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
        viewModel.didSeletVideoButtonTapped(self)
    }
}


//MARK: - Setup

private extension RedactorViewController {
    
    func seutpNavigationBar() {
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: WRTitles.selectVideo,
            style: .plain,
            target: self,
            action: #selector(selectVideoButtonTapped)
        )
    }
    
    func setupContentView() {
        view.backgroundColor = WRColors.primaryBackground
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
            backgroundColor: WRColors.secondaryBackgroundWithHighAlpha,
            shadowColor: WRColors.commonShadow
        )
    }
    
    func setupVideoSectionView() {
        videoSectionView.delegate = self
        videoSectionView.configureEmpty()
        videoSectionView.configureAppereanceWith(
            backgroundColor: WRColors.secondaryBackgroundWithHighAlpha,
            shadowColor: WRColors.commonShadow,
            videoPlayerHeight: WRSizes.videoPlayerHeight
        )
    }
    
    func setupUpdatingLayout() {
        viewModel.shouldUpdateInterface = { [weak self] _ in
            self?.animateUpdatedLayout()
        }
    }
    
    
    //MARK: Constraints
    
    func setupConstrtaints() {
        guard let navBar = self.navigationController?.navigationBar else { return }
            
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            
            audioSectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 22),
            audioSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            audioSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            audioSectionView.heightAnchor.constraint(equalToConstant: WRSizes.audioSectionView),
       
            videoSectionView.topAnchor.constraint(equalTo: audioSectionView.bottomAnchor, constant: 14),
            videoSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            videoSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            videoSectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22)
        ])
    }
}

//MARK: - Animation

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
                self.videoSectionView.updateProgressWith(
                    elapsedTime: self.viewModel.elapsedTimeFormatted,
                    remainingTime: self.viewModel.remainingTimeFormatted
                )
            }
        }
    }
}


//MARK: - Video Picker Delegate

extension RedactorViewController: VideoPickerDelegate {
    
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
            videoSectionView.configureEmpty()
            return
        }
       
        Task {
            let playerLayer = try await viewModel.didSelected(videoWithURL: url)
            videoSectionView.configureWith(
                videoRecord: viewModel.videoRecord,
                playerLayer: playerLayer
            )
            videoSectionView.updateProgressWith(
                elapsedTime: viewModel.elapsedTimeFormatted,
                remainingTime: viewModel.remainingTimeFormatted
            )
            picker.dismiss(animated: true)
        }
    }
}


//MARK: - Video Section View Delegate

extension RedactorViewController: VideoSectionViewDelegate {
    
    func didVideoPlayerTapped() {
        do {
            try viewModel.didVideoPlayerTapped()
        } catch {

        }
    }
}
