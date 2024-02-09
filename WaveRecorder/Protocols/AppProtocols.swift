//
//  AppProtocols.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 07.02.2024.
//

import UIKit
import WRAudio


//MARK: - Data

protocol Searcher: AnyObject {
    func updateData() async throws
    func search(withText text: String) async throws
}

protocol Editor: AnyObject {
    func rename(record: AudioRecord, newName name: String) async throws
    func delete(record: AudioRecord) async throws
}


//MARK: - Interface

protocol InterfaceUpdatable: AnyObject {
    var shouldUpdateInterface: ((Bool) async throws -> Void)? { get set }
}


//MARK: - Reusable View

protocol ReusableView {
    func reset()
}


//MARK: - Notifications

protocol Notifier: AnyObject {
    func activateNotification(withName name: NSNotification.Name, selector: Selector, from: Any?)
    func removeNotification(withName name: NSNotification.Name, from: Any?)
}


//MARK: - Parents

protocol ModuleMaker: AnyObject {
    func makeRecordBar() -> RecordBarView
    func makeEditViewModel(withIndexPath indexPath: IndexPath) -> EditViewModel
    func makePlayToolbarViewModel(withIndexPath indexPath: IndexPath) -> PlayToolbarViewModel
}
