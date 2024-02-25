//
//  MainConfigurator.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 25.02.2024.
//

import Foundation


//MARK: - View

protocol MainViewProtocol: InterfaceUpdatable { }


//MARK: - ViewModel

protocol MainViewModel: MainViewProtocol,
                        Searcher,
                        Editor,
                        Notifier,
                        MainTableViewModel,
                        ModuleMaker { }
