//
//  BatteryManager.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2023/2/27.
//

import Foundation
import Cocoa
import Defaults
import Combine

enum ScreenStateOption{
    case fullScreen
    case activity
    case nomal
}

@MainActor
class BatteryManager:NSObject{
    static let shared = BatteryManager()
    
    //MARK: Timer
    var timer:Timer?
    func start(){
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updatePlaying) , userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    func invalidate(){
        timer?.invalidate()
    }
    
    @MainActor @objc  func updatePlaying(){
        self.playState =  screenState()
    }

    //MARK: Noti
    static let didChangeScreenParametersNotification = NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
        .map { _ in }
        .eraseToAnyPublisher()
    
    //MARK: Noti
    static let deviceDidWake = NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didWakeNotification)
        .map { _ in }
        .eraseToAnyPublisher()

    
    /**
     Publishes when the screen becomes locked/unlocked.
     */
    static let isScreenLocked = Publishers.Merge(
        DistributedNotificationCenter.default().publisher(for: .screenIsLocked).map { _ in true },
        DistributedNotificationCenter.default().publisher(for: .screenIsUnlocked).map { _ in false }
    )
        .eraseToAnyPublisher()

    
    private var isStopPlay = Defaults[.isStopPlay]

    var playState:ScreenStateOption = .activity{
        didSet{
            if playState != oldValue  {
                AppState.shared.updatePlay(state: playState)
            }
        }
    }
    
    func screenState() -> ScreenStateOption{
        let windowListInfo = CGWindowListCopyWindowInfo([.optionOnScreenOnly,.excludeDesktopElements],kCGNullWindowID)
        for window in windowListInfo as! [ [ String : AnyObject] ] {
            if let level = window["kCGWindowLayer"] as? Int{
                if level == 0{
                    return .activity
                }
            }
        }
        return .nomal
    }
    
}

extension Notification.Name {
    /**
     Must be used with `DistributedNotificationCenter`.
     */
    static let screenIsLocked = Self("com.apple.screenIsLocked")
    
    /**
     Must be used with `DistributedNotificationCenter`.
     */
    static let screenIsUnlocked = Self("com.apple.screenIsUnlocked")
}

final class PowerSourceWatcher {
    enum PowerSource {
        case internalBattery
        case externalUnlimited
        case externalUPS
        
        var isUsingPowerAdapter: Bool { self == .externalUnlimited || self == .externalUPS }
        var isUsingBattery: Bool { self == .internalBattery }
        
        fileprivate init(identifier: String) {
            switch identifier {
            case kIOPMBatteryPowerKey:
                self = .internalBattery
            case kIOPMACPowerKey:
                self = .externalUnlimited
            case kIOPMUPSPowerKey:
                self = .externalUPS
            default:
                self = .externalUnlimited
                
                assertionFailure("This should not happen as `IOPSGetProvidingPowerSourceType` is documented to return one of the defined types")
            }
        }
    }
    
    private lazy var didChangeSubject = CurrentValueSubject<PowerSource, Never>(powerSource)
    
    /**
     Publishes the power source when it changes. It also publishes an initial event.
     */
    private(set) lazy var didChangePublisher = didChangeSubject.eraseToAnyPublisher()
    
    var powerSource: PowerSource {
        let identifier = IOPSGetProvidingPowerSourceType(nil)!.takeRetainedValue() as String
        return PowerSource(identifier: identifier)
    }
    
    init?() {
        let powerSourceCallback: IOPowerSourceCallbackType = { context in
            // Force-unwrapping is safe here as we're the ones passing the `context`.
            let this = Unmanaged<PowerSourceWatcher>.fromOpaque(context!).takeUnretainedValue()
            this.internalOnChange()
        }
        
        guard
            let runLoopSource = IOPSCreateLimitedPowerNotification(powerSourceCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))?.takeRetainedValue()
        else {
            return nil
        }
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .defaultMode)
    }
    
    private func internalOnChange() {
        didChangeSubject.send(powerSource)
    }
}
