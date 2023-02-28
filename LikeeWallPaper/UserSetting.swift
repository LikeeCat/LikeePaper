//
//  UserSetting.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2023/2/23.
//

import Foundation
import Defaults
import Cocoa

struct ScreenSetting:Codable, Defaults.Serializable, Hashable{
    var screenName:String
    var screenId:CGDirectDisplayID
    var screenAssetUrl:String
}

extension Defaults.Keys {
    static let isStopPlay = Key<Bool>("isStopPlay", default: false)
    static let isStopPlayWhenBattery = Key<Bool>("isStopPlayWhenBattery", default: true)
    static let isStopPlayWhenDeactivity = Key<Bool>("isStopPlayWhenDeactivity", default: true)
    static let isStopPlayWhenFullScreen = Key<Bool>("isStopPlayWhenFullScreen", default: true)
    static let volume = Key<Float>("volume", default: 0.5)
    static let isMuted = Key<Bool>("isMuted", default: true)

    static let isHiddenFolder = Key<Bool>("isHiddenFolder", default: false)
    static let isUpdateAll = Key<Bool>("isUpdateAll", default: false)
    static let screensSetting = Key<[ScreenSetting]>("screensSetting", default: [])
    static let defaultScreenSetting = Key<ScreenSetting>("defaultScreenSetting", default: ScreenSetting(screenName: NSScreen.main!.localizedName, screenId: NSScreen.main!.id, screenAssetUrl: ""))
}

enum Constants {
 
    static let menuBarIcon = NSImage(named: "MenuBarIcon")!

    static var mainWindow: NSWindow? = NSWindow(contentViewController: PaperViewController.shared)

    static func openWebsitesWindow() {
        NSApp.activate(ignoringOtherApps: true)
        mainWindow?.makeKeyAndOrderFront(nil)
    }
    
    @MainActor
    static func showSettingsWindow() {
        activateIfAccessory()
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
    
    @MainActor
    static func activateIfAccessory() {
        guard NSApp.activationPolicy() == .accessory else {
            return
        }

        NSApp.activate(ignoringOtherApps: true)
    }
}



