//
//  Utilities.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2023/2/22.
//

import Foundation
import Cocoa
import Defaults
import AVKit
import IOKit.ps
import Combine

extension NSScreen: Identifiable {
    public var id: CGDirectDisplayID {
        deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as! CGDirectDisplayID
    }
}

extension NSScreen {
    static func from(cgDirectDisplayID id: CGDirectDisplayID) -> NSScreen? {
        screens.first { $0.id == id }
    }


    /**
    Get the screen that contains the menu bar and has origin at (0, 0).
    */
    static var primary: NSScreen? { screens.first }

    /**
    This can be useful if you store a reference to a `NSScreen` instance as it may have been disconnected.
    */
    var isConnected: Bool {
        Self.screens.contains { $0.id == id }
    }
    
    static var defaultScreen: NSScreen? {NSScreen.from(cgDirectDisplayID: Defaults[.defaultScreenSetting].screenId) ?? .main}
    /**
    Get the main screen if the current screen is not connected.
    */
    var withFallbackToMain: NSScreen? { isConnected ? self : .main }

    /**
    Whether the screen shows a status bar.

    Returns `false` if the status bar is set to show/hide automatically as it then doesn't take up any screen space.
    */
    var hasStatusBar: Bool {
        // When `screensHaveSeparateSpaces == true`, the menu bar shows on all the screens.
        !NSStatusBar.isAutomaticallyToggled && (self == .primary || Self.screensHaveSeparateSpaces)
    }

    /**
    Get the frame of the actual visible part of the screen. This means under the dock, but *not* under the status bar if there's a status bar. This is different from `.visibleFrame` which also includes the space under the status bar.
    */
    var visibleFrameWithoutStatusBar: CGRect {
        var screenFrame = frame

        // Account for the status bar if the window is on the main screen and the status bar is permanently visible, or if on a secondary screen and secondary screens are set to show the status bar.
        if hasStatusBar {
            screenFrame.size.height -= NSStatusBar.actualThickness
        }

        return screenFrame
    }
    
    var hasNotch: Bool {
        if #available(macOS 12, *) {
            guard let width = auxiliaryTopRightArea?.width else {
                return false
            }
            return width < frame.width
        }
        return false
    }

}


extension NSStatusBar {
//    /**
//    The actual thickness of the status bar. `.thickness` confusingly returns the thickness of the content area.
//
//    Keep in mind for screen calculations that the status bar has an additional 1 point padding below it (between it and windows).
//    */
    static var actualThickness: Double {
        let legacyHeight = 24.0

        guard let screen = NSScreen.primary else {
            return legacyHeight
        }

        return screen.hasNotch ? 33 : legacyHeight
    }

    /**
    Whether the user has "Automatically hide and show the menu bar" enabled in system settings.
    */
    static var isAutomaticallyToggled: Bool {
        guard let screen = NSScreen.primary else {
            return false
        }

        // There's a 1 point gap between the status bar and any maximized window.
        let statusBarBottomPadding = 1.0

        let menuBarHeight = actualThickness + statusBarBottomPadding
        let dockHeight = NSWorkspace.shared.dockHeight ?? 0

        return (screen.frame.height - screen.visibleFrame.height - dockHeight) < menuBarHeight
    }
}

extension NSWorkspace {
    /**
    Returns the height of the Dock.

    It's `nil` if there's no primary screen or if the Dock is set to be automatically hidden.
    */
    var dockHeight: Double? {
        guard let screen = NSScreen.primary else {
            return nil
        }

        let height = screen.visibleFrame.origin.y - screen.frame.origin.y

        guard height != 0 else {
            return nil
        }

        return height
    }

    /**
    Whether the user has "Turn Hiding On" enabled in the Dock settings.
    */
    var isDockAutomaticallyToggled: Bool {
        guard NSScreen.primary != nil else {
            return false
        }

        return dockHeight == nil
    }
}


struct Display: Hashable, Codable, Identifiable {

    /**
    The main display.
    */
    static let main = Self(id: CGMainDisplayID())

    /**
    All displays.
    */
    static var all: [Self] {
        NSScreen.screens.map { self.init(screen: $0) }
    }

    /**
    The ID of the display.
    */
    let id: CGDirectDisplayID

    /**
    The `NSScreen` for the display.
    */
    var screen: NSScreen? { .from(cgDirectDisplayID: id) }

    /**
    The localized name of the display.
    */
    var localizedName: String { screen?.localizedName ?? "<Unknown name>" }

    /**
    Whether the display is connected.
    */
    var isConnected: Bool { screen?.isConnected ?? false }

    /**
    Get the main display if the current display is not connected.
    */
    var withFallbackToMain: Self { isConnected ? self : .main }

    init(id: CGDirectDisplayID) {
        self.id = id
    }

    init(screen: NSScreen) {
        self.id = screen.id
    }
}


extension StringProtocol {
    /**
    Word wrap the string at the given length.
    */
    func wordWrapped(atLength length: Int) -> String {
        var string = ""
        var currentLineLength = 0

        for word in components(separatedBy: .whitespaces) {
            let wordLength = word.count

            if currentLineLength + wordLength + 1 > length {
                // Can't wrap as the word is longer than the line.
                if wordLength >= length {
                    string += word
                }

                string += "\n"
                currentLineLength = 0
            }

            currentLineLength += wordLength + 1
            string += "\(word) "
        }

        return string
    }
}

extension NSWindow.Level {
    private static func level(for cgLevelKey: CGWindowLevelKey) -> Self {
        .init(rawValue: Int(CGWindowLevelForKey(cgLevelKey)))
    }

    static let desktop = level(for: .desktopWindow)
    static let desktopIcon = level(for: .desktopIconWindow)
    static let backstopMenu = level(for: .backstopMenu)
    static let dragging = level(for: .draggingWindow)
    static let overlay = level(for: .overlayWindow)
    static let help = level(for: .helpWindow)
    static let utility = level(for: .utilityWindow)
    static let assistiveTechHigh = level(for: .assistiveTechHighWindow)
    static let cursor = level(for: .cursorWindow)

    static let minimum = level(for: .minimumWindow)
    static let maximum = level(for: .maximumWindow)
}

public struct FatalReason: CustomStringConvertible {
    public static let unreachable = Self("Should never be reached during execution.")
    public static let notYetImplemented = Self("Not yet implemented.")
    public static let subtypeMustOverride = Self("Must be overridden in subtype.")
    public static let mustNotBeCalled = Self("Should never be called.")

    public let reason: String

    public init(_ reason: String) {
        self.reason = reason
    }

    public var description: String { reason }
}

public func fatalError(
    because reason: FatalReason,
    function: StaticString = #function,
    file: StaticString = #fileID,
    line: Int = #line
) -> Never {
    fatalError("\(function): \(reason)", file: file, line: UInt(line))
}


final class SSMenu: NSMenu, NSMenuDelegate {
    var onUpdate: (() -> Void)?

    private(set) var isOpen = false
    
    static let popover = NSPopover()

    override init(title: String) {
        super.init(title: title)
        self.delegate = self
        self.autoenablesItems = false
    }

    @available(*, unavailable)
    required init(coder decoder: NSCoder) {
        fatalError(because: .notYetImplemented)
    }

    func menuWillOpen(_ menu: NSMenu) {
        isOpen = true
    }

    func menuDidClose(_ menu: NSMenu) {
        isOpen = false
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        onUpdate?()
    }
}

extension NSMenuItem {
    convenience init(
        _ title: String,
        key: String = "",
        keyModifiers: NSEvent.ModifierFlags? = nil,
        isEnabled: Bool = true,
        isChecked: Bool = false,
        isHidden: Bool = false
    ) {
        self.init(title: title, action: nil, keyEquivalent: key)
        self.isEnabled = isEnabled
        self.isChecked = isChecked
        self.isHidden = isHidden

        if let keyModifiers {
            self.keyEquivalentModifierMask = keyModifiers
        }
    }

    convenience init(
        _ attributedTitle: NSAttributedString,
        key: String = "",
        keyModifiers: NSEvent.ModifierFlags? = nil,
        isEnabled: Bool = true,
        isChecked: Bool = false,
        isHidden: Bool = false
    ) {
        self.init(
            "",
            key: key,
            keyModifiers: keyModifiers,
            isEnabled: isEnabled,
            isChecked: isChecked,
            isHidden: isHidden
        )
        self.attributedTitle = attributedTitle
    }

    var isChecked: Bool {
        get { state == .on }
        set {
            state = newValue ? .on : .off
        }
    }
}


extension NSMenu {
    func addSeparator() {
        addItem(.separator())
    }

    @discardableResult
    func add(_ menuItem: NSMenuItem) -> NSMenuItem {
        addItem(menuItem)
        return menuItem
    }

    @discardableResult
    func addDisabled(_ title: String) -> NSMenuItem {
        let menuItem = NSMenuItem(title)
        menuItem.isEnabled = false
        addItem(menuItem)
        return menuItem
    }

    @discardableResult
    func addDisabled(_ attributedTitle: NSAttributedString) -> NSMenuItem {
        let menuItem = NSMenuItem(attributedTitle)
        menuItem.isEnabled = false
        addItem(menuItem)
        return menuItem
    }

    @discardableResult
    func addItem(
        _ title: String,
        key: String = "",
        keyModifiers: NSEvent.ModifierFlags? = nil,
        isEnabled: Bool = true,
        isChecked: Bool = false,
        isHidden: Bool = false
    ) -> NSMenuItem {
        let menuItem = NSMenuItem(
            title,
            key: key,
            keyModifiers: keyModifiers,
            isEnabled: isEnabled,
            isChecked: isChecked,
            isHidden: isHidden
        )
        addItem(menuItem)
        return menuItem
    }

    @discardableResult
    func addItem(
        _ attributedTitle: NSAttributedString,
        key: String = "",
        keyModifiers: NSEvent.ModifierFlags? = nil,
        isEnabled: Bool = true,
        isChecked: Bool = false,
        isHidden: Bool = false
    ) -> NSMenuItem {
        let menuItem = NSMenuItem(
            attributedTitle,
            key: key,
            keyModifiers: keyModifiers,
            isEnabled: isEnabled,
            isChecked: isChecked,
            isHidden: isHidden
        )
        addItem(menuItem)
        return menuItem
    }

    @discardableResult
    func addCallbackItem(
        _ title: String,
        key: String = "",
        keyModifiers: NSEvent.ModifierFlags? = nil,
        isEnabled: Bool = true,
        isChecked: Bool = false,
        isHidden: Bool = false,
        action: @escaping () -> Void
    ) -> NSMenuItem {
        let menuItem = CallbackMenuItem(
            title,
            key: key,
            keyModifiers: keyModifiers,
            isEnabled: isEnabled,
            isChecked: isChecked,
            isHidden: isHidden,
            action: action
        )
        addItem(menuItem)
        return menuItem
    }

    @discardableResult
    func addCallbackItem(
        _ title: NSAttributedString,
        key: String = "",
        keyModifiers: NSEvent.ModifierFlags? = nil,
        isEnabled: Bool = true,
        isChecked: Bool = false,
        isHidden: Bool = false,
        action: @escaping () -> Void
    ) -> NSMenuItem {
        let menuItem = CallbackMenuItem(
            "",
            key: key,
            keyModifiers: keyModifiers,
            isEnabled: isEnabled,
            isChecked: isChecked,
            isHidden: isHidden,
            action: action
        )
        menuItem.attributedTitle = title
        addItem(menuItem)
        return menuItem
    }


    @discardableResult
    func addLinkItem(_ title: String, destination: URL) -> NSMenuItem {
        addCallbackItem(title) {
            destination.open()
        }
    }

    @discardableResult
    func addLinkItem(_ title: NSAttributedString, destination: URL) -> NSMenuItem {
        addCallbackItem(title) {
            destination.open()
        }
    }


    @discardableResult
    func addAboutItem() -> NSMenuItem {
        addCallbackItem("关于") {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.orderFrontStandardAboutPanel(nil)
        }
    }


}

extension URL {
    /**
    Convenience for opening URLs.
    */
    func open() {
        NSWorkspace.shared.open(self)
    }
}

extension String {
    /*
    ```
    "https://sindresorhus.com".openUrl()
    ```
    */
    func openUrl() {
        URL(string: self)?.open()
    }
}

extension URL: ExpressibleByStringLiteral {
    /**
    Example:

    ```
    let url: URL = "https://sindresorhus.com"
    ```
    */
    public init(stringLiteral value: StaticString) {
        self.init(string: "\(value)")!
    }
}

extension URL {
    /**
    Example:

    ```
    URL("https://sindresorhus.com")
    ```
    */
    init(_ staticString: StaticString) {
        self.init(string: "\(staticString)")!
    }
}



final class CallbackMenuItem: NSMenuItem {
    private static var validateCallback: ((NSMenuItem) -> Bool)?

    static func validate(_ callback: @escaping (NSMenuItem) -> Bool) {
        validateCallback = callback
    }

    private let callback: () -> Void

    init(
        _ title: String,
        key: String = "",
        keyModifiers: NSEvent.ModifierFlags? = nil,
        isEnabled: Bool = true,
        isChecked: Bool = false,
        isHidden: Bool = false,
        action: @escaping () -> Void
    ) {
        self.callback = action
        super.init(title: title, action: #selector(action(_:)), keyEquivalent: key)
        self.target = self
        self.isEnabled = isEnabled
        self.isChecked = isChecked
        self.isHidden = isHidden

        if let keyModifiers {
            self.keyEquivalentModifierMask = keyModifiers
        }
    }

    @available(*, unavailable)
    required init(coder decoder: NSCoder) {
        fatalError(because: .notYetImplemented)
    }

    @objc
    private func action(_ sender: NSMenuItem) {
        callback()
    }
}

extension CallbackMenuItem: NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        Self.validateCallback?(menuItem) ?? true
    }
}


extension AppState{
    //获取视频首桢
     static func getFirstFrameWithUrl(url:URL)-> URL?{
        let asset = AVAsset(url: url)
        let imageGen = AVAssetImageGenerator(asset: asset)
        guard let firstFrame = try? imageGen.copyCGImage(at: CMTime(value: 0, timescale: 1), actualTime: nil) else {
                  return nil
        }
        let rep = NSBitmapImageRep(cgImage: firstFrame)
        let data = rep.representation(using: .png, properties: [:])
        let document = getDocumentsDirectory()
        var fileName = url.lastPathComponent.split(separator: ".")[0]
        fileName = fileName + ".png"
        let savePath = document.appendingPathComponent(String(fileName), isDirectory: false)
        do{
            try data?.write(to: savePath)
        }
        catch{
            return nil
        }
        print("this is the url \(savePath)")
       return savePath
    }
    
    private static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

}

