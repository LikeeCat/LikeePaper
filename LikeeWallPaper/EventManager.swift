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
                handle()
                //电源
            }
            .store(in: &cancellables)
        
        BatteryManager.deviceDidWake
            .sink{[self] _ in
                handle()
            }.store(in: &cancellables)
        
        BatteryManager.didResignActiveNotification
            .sink{[self] result in
                BatteryManager.updatePlay()
            }.store(in: &cancellables)
        
        BatteryManager.didBecomeActiveNotification
            .sink{[self] _ in
                BatteryManager.updatePlay()
            }.store(in: &cancellables)

        BatteryManager.isScreenLocked
            .sink { [self] in
                
                isScreenLocked = $0
            }
            .store(in: &cancellables)
    }
}
