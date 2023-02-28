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


class BatteryManager:NSObject{
    //1.查询当前省电模式的设置
    //2.查看当前屏幕的状态
    //3.通知App更新屏幕状态
    /*   static let isStopPlayWhenBattery = Key<Bool>("isStopPlayWhenBattery", default: true)
    static let isStopPlayWhenActivity = Key<Bool>("isStopPlayWhenActivity", default: true)
    static let isStopPlayWhenFullScreen = Key<Bool>("isStopPlayWhenFullScreen", default: true)
     */

    private var isStopPlay = Defaults[.isStopPlay]

    static let deviceDidWake = NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didWakeNotification)
        .map { _ in }
        .eraseToAnyPublisher()

    /**
    Publishes when the configuration of the displays attached to the computer is changed.

    The configuration change can be made either programmatically or when the user changes settings in the Displays control panel.
    */
    static let didResignActiveNotification = NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)
        .map { _ in }
        .eraseToAnyPublisher()
    
    static let didBecomeActiveNotification = NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
        .map { _ in }
        .eraseToAnyPublisher()

    static let willResignActiveNotification = NotificationCenter.default.publisher(for: NSWindow.willExitFullScreenNotification)
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
    
    static let obStateBar = NSWorkspace.shared.observe(\.menuBarOwningApplication, options:[.new,.old]) { workpace, value in
        let new = value.newValue!
        let old = value.newValue!
        let mouseLocation = NSEvent.mouseLocation
        let screens = NSScreen.screens
        let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) })
        let fullScreen = isFullScreen(screen: screenWithMouse!)
        AppState.shared.updatePlay(screen: screenWithMouse!, activeAppName: new!.localizedName!,fullScreen:fullScreen)
        
    }
    
    @MainActor static func updatePlay(){
        let mouseLocation = NSEvent.mouseLocation
        let screens = NSScreen.screens
        let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) })
        let fullScreen = isFullScreen(screen: screenWithMouse!)
        AppState.shared.updatePlay(screen: screenWithMouse!, activeAppName: "自定义",fullScreen:fullScreen)
    }
    
    static let ob = NSWorkspace.shared.observe(\.frontmostApplication, options: [.old,.new]) { a, value in
//        let old = value.oldValue!
        let new = value.newValue!
        print("ob ++++   目前活跃的app 是 \(new!.localizedName)")
    }
    
    static func getCurrentScreenWindowInfo() -> String? {
        let mouseLocation = NSEvent.mouseLocation
        let screens = NSScreen.screens
        let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) })
        let windowListInfo = CGWindowListCopyWindowInfo([.optionOnScreenOnly,.excludeDesktopElements],kCGNullWindowID)
        if let windowsInfo = windowListInfo as? [[String: AnyObject]]{
            let window = windowsInfo[0]
            return window["kCGWindowOwnerName"] as? String
        }
        else{
            return nil
        }
      }
    
    static func startob(){
//        ob
        obStateBar
    }

    static func isFullScreen(screen:NSScreen) -> ScreenStateOption{
        let windowListInfo = CGWindowListCopyWindowInfo([.optionOnScreenOnly,.excludeDesktopElements],kCGNullWindowID)
        for window in windowListInfo as! [ [ String : AnyObject] ] {
            if let name = window["kCGWindowOwnerName"] as? String{
                    guard let windowBounds = window["kCGWindowBounds"] else{
                        continue
                    }
                    if let bounds = CGRect(dictionaryRepresentation: windowBounds as! CFDictionary) {
                        
                        if CGSizeEqualToSize(bounds.size, screen.frame.size){
                            return .fullScreen
                        }
                        if bounds.origin.y > NSStatusBar.actualThickness{
                            return .activity
                        }
                    }
            }
        }
        return .nomal
    }
    
//    static func isFullScreen(screen:NSScreen) -> Bool{
//        let windowListInfo = CGWindowListCopyWindowInfo([.optionOnScreenOnly,.excludeDesktopElements],kCGNullWindowID)
//        for window in windowListInfo as! [ [ String : AnyObject] ] {
//            if let name = window["kCGWindowOwnerName"] as? String{
//                    guard let windowBounds = window["kCGWindowBounds"] else{
//                        continue
//                    }
//                    if let bounds = CGRect(dictionaryRepresentation: windowBounds as! CFDictionary) {
//                        print("window is \(name), x: \(bounds.origin.x) y:\(bounds.origin.y) width:\(bounds.width) height:\(bounds.height)")
//                        if CGSizeEqualToSize(bounds.size, screen.frame.size){
//                            return true
//                        }
//                    }
//            }
//        }
//        return false
//    }
    
    static func noActivityView(screen:NSScreen) -> Bool{
        let windowListInfo = CGWindowListCopyWindowInfo([.optionOnScreenOnly,.excludeDesktopElements],kCGNullWindowID)
        for window in windowListInfo as! [ [ String : AnyObject] ] {
            if let _ = window["kCGWindowOwnerName"] as? String{
                    guard let windowBounds = window["kCGWindowBounds"] else{
                        continue
                    }
                    if let bounds = CGRect(dictionaryRepresentation: windowBounds as! CFDictionary) {
                        
                    }
            }
        }
        return false

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
