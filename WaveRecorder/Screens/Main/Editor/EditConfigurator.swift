//
//  EditConfigurator.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 25.02.2024.
//

import Foundation


//MARK: - View

protocol EditViewProtocol: AnyObject {
    func editDidTapped()
    func onEndEditing(withNewName newName: String) async throws
    func addToVideoButtonTapped()
}


//MARK: - ViewModel

protocol EditViewModel: EditViewProtocol {
    func isEditingNow() -> Bool
    func getRecordName() -> String
    func getCreatinonDateString() -> String
}
