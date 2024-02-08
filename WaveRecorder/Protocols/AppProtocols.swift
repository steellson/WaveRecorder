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
    func resetData() async
    func search(withText text: String) async
}

protocol Editor: AnyObject {
    func rename(record: AudioRecord, newName name: String) async
    func delete(record: AudioRecord) async
}


//MARK: - Interface

protocol InterfaceUpdatable: AnyObject {
    var shouldUpdateInterface: ((Bool) async -> Void)? { get set }
}


//MARK: - Notifications

protocol Notifier: AnyObject {
    func activateNotification(withName name: NSNotification.Name, selector: Selector, from: Any?)
    func removeNotification(withName name: NSNotification.Name, from: Any?)
}


//MARK: - Childs

protocol ChildViewModel: AnyObject {
    func update(record: AudioRecord)
}


//MARK: - Parents

protocol ModuleMaker: AnyObject {
    func makeRecordBar() -> RecordBarView
    func makeEditView(withIndexPath indexPath: IndexPath) -> EditView?
    func makePlayToolbarView(withIndexPath indexPath: IndexPath) -> PlayToolbarView?
}
