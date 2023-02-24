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
    static let screensSetting = Key<[ScreenSetting]>("screensSetting", default: [])
    static let isStopPlay = Key<Bool>("isStopPlay", default: false)
    static let isHiddenFolder = Key<Bool>("isHiddenFolder", default: false)
    static let isMuted = Key<Bool>("isMuted", default: true)
    static let isUpdateAll = Key<Bool>("isUpdateAll", default: false)
    static let defaultScreenSetting = Key<ScreenSetting>("defaultScreenSetting", default: ScreenSetting(screenName: NSScreen.main!.localizedName, screenId: NSScreen.main!.id, screenAssetUrl: ""))
}

enum Constants {
    
    static var all: [ScreenSetting] {
        get { Defaults[.screensSetting] }
        set {
            Defaults[.screensSetting] = newValue
        }
    }
    
    static let menuBarIcon = NSImage(named: "MenuBarIcon")!

    static var websitesWindow: NSWindow? {
        NSApp.windows.first { $0.identifier?.rawValue == "websites" }
    }

    static func openWebsitesWindow() {
        NSApp.activate(ignoringOtherApps: true)
        websitesWindow?.makeKeyAndOrderFront(nil)
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



