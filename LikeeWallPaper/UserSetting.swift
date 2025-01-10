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
    // play state
    static let isStopPlayWhenBattery = Key<Bool>("isStopPlayWhenBattery", default: true)
    static let isStopPlayWhenDeactivity = Key<Bool>("isStopPlayWhenDeactivity", default: true)
    static let isStopPlayWhenFullScreen = Key<Bool>("isStopPlayWhenFullScreen", default: true)
    static let volume = Key<Float>("volume", default: 0.5)
    static let isMuted = Key<Bool>("isMuted", default: true)
    // update state
    static let isHiddenFolder = Key<Bool>("isHiddenFolder", default: false)
    static let isUpdateAll = Key<Bool>("isUpdateAll", default: false)
    static let screensSetting = Key<[ScreenSetting]>("screensSetting", default: [])
    static let defaultScreenSetting = Key<ScreenSetting>("defaultScreenSetting", default: ScreenSetting(screenName: NSScreen.main!.localizedName, screenId: NSScreen.main!.id, screenAssetUrl: ""))
    // default folder setting
    static let defaultPaperFolder = Key<String>("defaultPaperFolder", default: "")
    static let playListSetting = Key<[String]>("playListSetting", default: [])

}


enum Constants {
 
    static let menuBarIcon = NSImage(named: "MenuBarIcon")!

    static var mainWindow: NSWindow? = NSWindow(contentViewController: PaperViewController.shared)

    static func openPaperWindow() {
        NSApp.activate(ignoringOtherApps: true)
        mainWindow?.styleMask = [
            .titled,                // 标题栏
            .closable,              // 关闭按钮
            .miniaturizable,        // 最小化按钮
            .resizable,             // 可调整大小
            .fullSizeContentView    // 全尺寸内容
        ]
        mainWindow?.titlebarAppearsTransparent = true           // 标题栏透明
        mainWindow?.isOpaque = false                            // 使窗口背景透明
        mainWindow?.backgroundColor = NSColor(Theme.backgroundColor)  // 设置背景为透明色
        mainWindow?.isMovableByWindowBackground = true
        mainWindow?.makeKeyAndOrderFront(nil)
    }
    
    @MainActor
    static func showSettingsWindow() {
        activateIfAccessory()
        NSApplication.shared.openSettings()

//        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
    
    @MainActor
    static func activateIfAccessory() {
        guard NSApp.activationPolicy() == .accessory else {
            return
        }

        NSApp.activate(ignoringOtherApps: true)
    }
}


// https://stackoverflow.com/a/76714125/19625526
private let kAppMenuInternalIdentifier = "app"
private let kSettingsLocalizedStringKey = "Settings\\U2026"

extension NSApplication {
    /// Open the application settings/preferences window.
    public func openSettings() {
        // macOS 14 Sonoma
        if let internalItemAction = NSApp.mainMenu?.item(
            withInternalIdentifier: kAppMenuInternalIdentifier
        )?.submenu?.item(
            withLocalizedTitle: kSettingsLocalizedStringKey
        )?.internalItemAction {
            internalItemAction()
            return
        }

        guard let delegate = NSApp.delegate else { return }

        // macOS 13 Ventura
        var selector = Selector(("showSettingsWindow:"))
        if delegate.responds(to: selector) {
            delegate.perform(selector, with: nil, with: nil)
            return
        }

        // macOS 12 Monterrey
        selector = Selector(("showPreferencesWindow:"))
        if delegate.responds(to: selector) {
            delegate.perform(selector, with: nil, with: nil)
            return
        }
    }
}


// MARK: - NSMenuItem (Private)

extension NSMenuItem {
    
    /// An internal SwiftUI menu item identifier that should be a public property on `NSMenuItem`.
    var internalIdentifier: String? {
        guard let id = Mirror.firstChild(
            withLabel: "id", in: self
        )?.value else {
            return nil;
        }
        
        return "\(id)";
    }
    
    /// A callback which is associated directly with this `NSMenuItem`.
    var internalItemAction: (() -> Void)? {
        guard
            let platformItemAction = Mirror.firstChild(
                withLabel: "platformItemAction", in: self)?.value,
            let typeErasedCallback = Mirror.firstChild(
                in: platformItemAction)?.value
        else {
            return nil;
        }
            
        return Mirror.firstChild(
            in: typeErasedCallback
        )?.value as? () -> Void;
    }
    
}

// MARK: - NSMenu (Private)

extension NSMenu {
    /// Get the first `NSMenuItem` whose internal identifier string matches the given value.
    func item(withInternalIdentifier identifier: String) -> NSMenuItem? {
        self.items.first(where: {
            $0.internalIdentifier?.elementsEqual(identifier) ?? false
        })
    }
    
    /// Get the first `NSMenuItem` whose title is equivalent to the localized string referenced
    /// by the given localized string key in the localization table identified by the given table name
    /// from the bundle located at the given bundle path.
    func item(
        withLocalizedTitle localizedTitleKey: String,
        inTable tableName: String = "MenuCommands",
        fromBundle bundlePath: String = "/System/Library/Frameworks/AppKit.framework"
    ) -> NSMenuItem? {
        guard let localizationResource = Bundle(path: bundlePath) else {
            return nil;
        }
        
        return self.item(withTitle: NSLocalizedString(
            localizedTitleKey,
            tableName: tableName,
            bundle: localizationResource,
            comment: ""));
    }
    
}

// MARK: - Mirror (Helper)

fileprivate extension Mirror {
    
    /// The unconditional first child of the reflection subject.
    var firstChild: Child? { self.children.first }
    
    /// The first child of the reflection subject whose label matches the given string.
    func firstChild(withLabel label: String) -> Child? {
        self.children.first(where: {
            $0.label?.elementsEqual(label) ?? false
        })
    }
    
    /// The unconditional first child of the given subject.
    static func firstChild(in subject: Any) -> Child? {
        Mirror(reflecting: subject).firstChild
    }
    
    /// The first child of the given subject whose label matches the given string.
    static func firstChild(
        withLabel label: String, in subject: Any
    ) -> Child? {
        Mirror(reflecting: subject).firstChild(withLabel: label)
    }
    
}



