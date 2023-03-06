//
//  EventManager.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2023/2/23.
//

import Foundation
import Cocoa
import Defaults
import Combine


extension AppState{
    func setUpAppEvents(){
        powerSourceWatcher?.didChangePublisher
            .sink { [self] result in
                AppState.shared.startWallPaper()
                //电源
            }
            .store(in: &cancellables)
        
        BatteryManager.deviceDidWake
            .sink{[self] _ in
                AppState.shared.startWallPaper()
            }.store(in: &cancellables)
        
        BatteryManager.didChangeScreenParametersNotification
            .sink{[self] _ in
                AppState.shared.startWallPaper()
                BatteryManager.shared.updatePlaying()
            }.store(in: &cancellables)

        
        BatteryManager.isScreenLocked
            .sink { [self] in
                
                isScreenLocked = $0
            }
            .store(in: &cancellables)
    }
}
