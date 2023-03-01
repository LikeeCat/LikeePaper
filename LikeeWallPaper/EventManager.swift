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
//                handle()
                //电源
            }
            .store(in: &cancellables)
        
//        BatteryManager.deviceDidWake
//            .sink{[self] _ in
////                handle()
//            }.store(in: &cancellables)
//
//        BatteryManager.didResignActiveNotification
//            .sink{[self] result in
//                print("didResignActiveNotification +++")
//                BatteryManager.updatePlay()
//            }.store(in: &cancellables)
////
//        BatteryManager.didUpdateNotification
//            .sink{[self] result in
//                print("didUpdateNotification +++")
//                BatteryManager.updatePlay()
//            }.store(in: &cancellables)
////
//
//        BatteryManager.didBecomeActiveNotification
//            .sink{[self] _ in
//                print("didBecomeActiveNotification +++")
//                BatteryManager.updatePlay()
//            }.store(in: &cancellables)
//
//        BatteryManager.willCloseNotification
//            .sink{[self] _ in
//                print("willCloseNotification +++")
//                BatteryManager.updatePlay()
//            }.store(in: &cancellables)
//        
//        BatteryManager.activeSpaceDidChangeNotification
//            .sink{[self] _ in
//                print("activeSpaceDidChangeNotification +++")
//                BatteryManager.updatePlay()
//            }.store(in: &cancellables)
//        
//        BatteryManager.didDeactivateApplicationNotification
//            .sink{[self] _ in
//                print("didDeactivateApplicationNotification +++")
//                BatteryManager.updatePlay()
//            }.store(in: &cancellables)
//        
//        BatteryManager.didActivateApplicationNotification
//            .sink{[self] _ in
//                print("didActivateApplicationNotification +++")
//                BatteryManager.updatePlay()
//            }.store(in: &cancellables)
//        
//        BatteryManager.didUnhideApplicationNotification
//            .sink{[self] _ in
//                print("didUnhideApplicationNotification +++")
//                BatteryManager.updatePlay()
//            }.store(in: &cancellables)
//        
//        BatteryManager.didHideApplicationNotification
//            .sink{[self] _ in
//                print("didHideApplicationNotification +++")
//                BatteryManager.updatePlay()
//            }.store(in: &cancellables)
//        
        //    public class let didActivateApplicationNotification: NSNotification.Name
        //
        //    @available(macOS 10.6, *)
        //    public class let didDeactivateApplicationNotification: NSNotification.Name

        
        
        BatteryManager.isScreenLocked
            .sink { [self] in
                
                isScreenLocked = $0
            }
            .store(in: &cancellables)
    }
}
