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
                AppState.shared.updatePlay()
                //电源
            }
            .store(in: &cancellables)
        
        BatteryManager.willSleepNotification
            .sink{[self] _ in
                print("++++ sleep ")
                AppState.shared.updatePlay(state: .nomal)
            }.store(in: &cancellables)

        
        BatteryManager.deviceDidWake
            .sink{[self] _ in
                AppState.shared.updatePlay()
            }.store(in: &cancellables)
        
        BatteryManager.didChangeScreenParametersNotification
            .sink{[self] _ in
                handleScreenChangeIfNeeded()

            }.store(in: &cancellables)

        
        BatteryManager.isScreenLocked
            .sink { [self] in
                
                isScreenLocked = $0
            }
            .store(in: &cancellables)
    }
    
    private func handleScreenChangeIfNeeded() {
        let currentScreens = NSScreen.screens

        // 只有当屏幕配置变化时才处理
        if currentScreens != lastScreenState {
            lastScreenState = currentScreens
            handleScreenChange()
        }
    }
    
    private func handleScreenChange() {
        AppState.shared.screenManagers.forEach { sc in
            sc.cleanUp()
        }
        AppState.shared.screenManagers.removeAll()
        AppState.shared.startWallPaper()
    }
}
