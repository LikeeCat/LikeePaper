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
import SwiftUI



extension NSScreen: @retroactive Identifiable {
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

extension View{
    func windowLevel(_ level: NSWindow.Level) -> some View {
        accessHostingWindow {
            $0?.level = level
        }
    }
    
    func accessHostingWindow(_ onWindow: @escaping (NSWindow?) -> Void) -> some View {
        modifier(WindowViewModifier(onWindow: onWindow))
    }
    
    func bindHostingWindow(_ window: Binding<NSWindow?>) -> some View {
        background(WindowAccessor(window))
    }
    
}

private struct WindowAccessor: NSViewRepresentable {
    private final class WindowAccessorView: NSView {
        @Binding var windowBinding: NSWindow?
        
        init(binding: Binding<NSWindow?>) {
            self._windowBinding = binding
            super.init(frame: .zero)
        }
        
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            windowBinding = window
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError() // swiftlint:disable:this fatal_error_message
        }
    }
    
    @Binding var window: NSWindow?
    
    init(_ window: Binding<NSWindow?>) {
        self._window = window
    }
    
    func makeNSView(context: Context) -> NSView {
        WindowAccessorView(binding: $window)
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

private struct WindowViewModifier: ViewModifier {
    @State private var window: NSWindow?
    
    let onWindow: (NSWindow?) -> Void
    
    func body(content: Content) -> some View {
        onWindow(window)
        
        return content
            .bindHostingWindow($window)
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

extension URL: @retroactive ExpressibleByExtendedGraphemeClusterLiteral {}
extension URL: @retroactive ExpressibleByUnicodeScalarLiteral {}
extension URL: @retroactive ExpressibleByStringLiteral {
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

extension URL {
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}


extension AppState{
    //获取视频首桢
    static func getFirstFrameWithUrl(url:URL)-> URL?{
        let document = getDocumentsDirectory()
        let appHome = document.appendingPathComponent(getLastBundleIDComponent(), isDirectory: true)
        
        do {
            // 如果文件夹不存在，则创建它
            if !FileManager.default.fileExists(atPath: appHome.path) {
                try FileManager.default.createDirectory(at: appHome, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            print("创建文件夹失败：\(error.localizedDescription)")
        }
        
        var fileName = url.lastPathComponent.split(separator: ".")[0]
        fileName = fileName + ".png"
        let savePath = appHome.appendingPathComponent(String(fileName), isDirectory: false)
        if FileManager.default.fileExists(atPath: savePath.path) {
            return savePath
        }
        
        let asset = AVAsset(url: url)
        let imageGen = AVAssetImageGenerator(asset: asset)
        // 设置图像的最大尺寸
        let maxSize = CGSize(width: 800, height: 600)  // 设置最大尺寸，根据需要调整
        imageGen.maximumSize = maxSize

        var firstFrame: CGImage? = nil
        do {
            firstFrame = try imageGen.copyCGImage(at: CMTime(value: 0, timescale: 1), actualTime: nil)
        } catch {
            print("Error generating image: \(error.localizedDescription)")
            return nil
        }
        
        let rep = NSBitmapImageRep(cgImage: firstFrame!)
        let data = rep.representation(using: .png, properties: [:])
        do{
            try data?.write(to: savePath)
        }
        catch{
            return nil
        }
        return savePath
        
    }
    
    private static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private static func getLastBundleIDComponent(defaultValue: String = "LikeeWallPaper") -> String {
        guard let bundleID = Bundle.main.bundleIdentifier else {
            return defaultValue
        }
        let components = bundleID.split(separator: ".")
        return components.last.map(String.init) ?? defaultValue
    }

    
}

extension FileManager {
    public func isDirectory(at url: URL) -> Bool {
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        if fileManager.fileExists(atPath: url.path, isDirectory:&isDir) {
            return isDir.boolValue
        } else {
            return false
        }
    }
}

extension NSAlert {
    /**
     Show an async alert sheet on a window.
     */
    @MainActor
    @discardableResult
    static func show(
        in window: NSWindow? = nil,
        title: String,
        message: String? = nil,
        style: Style = .warning,
        buttonTitles: [String] = [],
        defaultButtonIndex: Int? = nil
    ) async -> NSApplication.ModalResponse {
        let alert = NSAlert(
            title: title,
            message: message,
            style: style,
            buttonTitles: buttonTitles,
            defaultButtonIndex: defaultButtonIndex
        )
        
        guard let window else {
            return await alert.run()
        }
        
        return await alert.beginSheetModal(for: window)
    }
    
    /**
     Show an alert as a window-modal sheet, or as an app-modal (window-indepedendent) alert if the window is `nil` or not given.
     */
    @discardableResult
    static func showModal(
        for window: NSWindow? = nil,
        title: String,
        message: String? = nil,
        style: Style = .warning,
        buttonTitles: [String] = [],
        defaultButtonIndex: Int? = nil
    ) -> NSApplication.ModalResponse {
        NSAlert(
            title: title,
            message: message,
            style: style,
            buttonTitles: buttonTitles,
            defaultButtonIndex: defaultButtonIndex
        )
        .runModal(for: window)
    }
    
    /**
     The index in the `buttonTitles` array for the button to use as default.
     
     Set `-1` to not have any default. Useful for really destructive actions.
     */
    var defaultButtonIndex: Int {
        get {
            buttons.firstIndex { $0.keyEquivalent == "\r" } ?? -1
        }
        set {
            // Clear the default button indicator from other buttons.
            for button in buttons where button.keyEquivalent == "\r" {
                button.keyEquivalent = ""
            }
            
            if newValue != -1 {
                buttons[newValue].keyEquivalent = "\r"
            }
        }
    }
    
    convenience init(
        title: String,
        message: String? = nil,
        style: Style = .warning,
        buttonTitles: [String] = [],
        defaultButtonIndex: Int? = nil
    ) {
        self.init()
        self.messageText = title
        self.alertStyle = style
        
        if let message {
            self.informativeText = message
        }
        
        addButtons(withTitles: buttonTitles)
        
        if let defaultButtonIndex {
            self.defaultButtonIndex = defaultButtonIndex
        }
    }
    
    /**
     Runs the alert as a window-modal sheet, or as an app-modal (window-indepedendent) alert if the window is `nil` or not given.
     */
    @discardableResult
    func runModal(for window: NSWindow? = nil) -> NSApplication.ModalResponse {
        guard let window else {
            return runModal()
        }
        
        beginSheetModal(for: window) { returnCode in
            NSApp.stopModal(withCode: returnCode)
        }
        
        return NSApp.runModal(for: window)
    }
    
    /**
     Adds buttons with the given titles to the alert.
     */
    func addButtons(withTitles buttonTitles: [String]) {
        for buttonTitle in buttonTitles {
            addButton(withTitle: buttonTitle)
        }
    }
}


extension NSAlert {
    /**
     Workaround to allow using `NSAlert` in a `Task`.
     
     [FB9857161](https://github.com/feedback-assistant/reports/issues/288)
     */
    @MainActor
    @discardableResult
    func run() async -> NSApplication.ModalResponse {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async { [self] in
                continuation.resume(returning: runModal())
            }
        }
    }
}

@MainActor
class PaperPlayList: ObservableObject {
    static let shared = PaperPlayList()
    @Published var papers: [PaperInfo] =  sortPaper()
    
    @Published var tags: Set<String> = []
    
    static func sortPaper()->[PaperInfo] {
        return Papers.shared.all
            .filter { info in
                PlayListManager.getPlayList().contains(info.image.lastPathComponent)
            }
            .sorted { paper1, paper2 in
                let playListIDS = PlayListManager.getPlayList()
                guard
                    let index1 = playListIDS.firstIndex(of: paper1.image.lastPathComponent),
                    let index2 = playListIDS.firstIndex(of: paper2.image.lastPathComponent)
                else {
                    return false
                }
                return index1 < index2
            }
    }
    
    func updatePaper(){
        papers = PaperPlayList.sortPaper()
        var tmp :Set<String> = []
        papers.forEach { paper in
            tmp = tmp.union(paper.tags)
        }
        tags = tmp
    }
}

struct PaperInfo: Identifiable{
    let path:String
    let image: URL
    let resolution: String
    var cachedImage: NSImage?
    let id:UUID
    let tags:Set<String>
    let local: Bool
    init(path: String, image: URL, resolution: String, tags: Set<String>, local: Bool = false) {
        self.path = path
        self.image = image
        self.resolution = resolution
        self.tags = tags
        self.local = local
        self.cachedImage = NSImage(contentsOf: image)!
        self.id = UUID()
    }
    
    
}

@MainActor
class Papers: ObservableObject {
    @Published var all: [PaperInfo] = {
        Papers.allPapers().info
    }()
    
    @Published  var allTags: Set<String> = {
        Papers.allPapers().tag
    }()
    
    @Published  var selectTags: Set<String> = []

    
    static let shared = Papers()
    
    var defaultUserSettingPath = Defaults[.defaultPaperFolder]
    
    func reloadAll(){
        let papers = Papers.allPapers()
        all = papers.info
        allTags = papers.tag
    }
    
    func filterWithTag(tag: String){
        if selectTags.contains(tag) {
            selectTags.remove(tag)
        } else {
            selectTags.insert(tag)
        }
        
        if  selectTags.isEmpty {
            all =  Papers.allPapers().info
        }else {
            all = Papers.shared.all.filter({ paper in
                !paper.tags.isDisjoint(with: selectTags)
            })
        }
    }
    
    @MainActor static func allPapers()->(info: [PaperInfo], tag: Set<String>){
        
        guard let defaultVideosPath = VideoAssetsManager.defaultBundler else {
            return ([],Set())
        }
        
        if Defaults[.defaultPaperFolder] == "" {
            return getAllMP4FilePaths(inBundleAtPath: defaultVideosPath)
        }
        let embed = getAllMP4FilePaths(inBundleAtPath: defaultVideosPath)
        let userSetting = FileBookmarkManager.shared.accessFileFromBookmark()
        
        return (embed.info + userSetting.info, embed.tag.union(userSetting.tag))
    }
    
    
    
    // return [url : [resolution , tags]]
    static  func getAllMP4FilePaths(inBundleAtPath bundlePath: String) -> (info:[PaperInfo], tag:Set<String>) {
        var papers:[PaperInfo] = []
        var allTags: Set<String> = []
        guard let bundle = Bundle(url: URL(string: bundlePath)!) else {
            return (papers, allTags)
        }
        
        guard let resourcePath = bundle.resourcePath else{
            return (papers, allTags)
            
        }
        let fileManager = FileManager.default
        
        do {
            let resourceURLs = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: resourcePath), includingPropertiesForKeys: nil)
            
            for resourceURL in resourceURLs {
                // 检查文件扩展名是否为 mp4
                if resourceURL.pathExtension.lowercased() == "mp4" {
                    
                    let resolution = getVideoResolutionCategory(url: resourceURL)
                    let tags = resourceURL.absoluteString.extractTags()
                    if let imageUrl = AppState.getFirstFrameWithUrl(url: resourceURL){
                        let info =  PaperInfo(path: resourceURL.absoluteString, image: imageUrl, resolution: resolution, tags: tags)
                        allTags.formUnion(tags) // 合并到最终结果集合
                        papers.append(info)
                    }
                }
            }
        } catch {
            print("遍历 bundle 资源目录时发生错误：\(error)")
        }
        
        return (papers , allTags)
    }
    
    static  func getAllLocalMP4FilePaths(url: URL) -> (info:[PaperInfo], tag:Set<String>) {
        var papers:[PaperInfo] = []
        var allTags: Set<String> = []

        let fileManager = FileManager.default
        
        do {
            let resourceURLs = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            
            for resourceURL in resourceURLs {
                // 检查文件扩展名是否为 mp4
                if resourceURL.pathExtension.lowercased() == "mp4" {
                    
                    let resolution = getVideoResolutionCategory(url: resourceURL)
                    let tags = resourceURL.absoluteString.extractTags()
                    if let imageUrl = AppState.getFirstFrameWithUrl(url: resourceURL){
                        let info =  PaperInfo(path: resourceURL.absoluteString, image: imageUrl, resolution: resolution, tags: tags)
                        allTags.formUnion(tags) // 合并到最终结果集合
                        papers.append(info)
                    }
                }
            }
        } catch {
            print("遍历 bundle 资源目录时发生错误：\(error)")
        }
        
        return (papers , allTags)
    }
    
    static func getVideoResolutionCategory(url: URL) -> String {
        let asset = AVAsset(url: url)
        
        // 获取视频的所有轨道
        for track in asset.tracks(withMediaType: .video) {
            let resolution = track.naturalSize
            // 判断分辨率范围并返回对应的类别
            if resolution.width >= 1920  && resolution.width < 2048 {
                return "1080p"
            } else if resolution.width >= 2048 && resolution.width < 3840 {
                return "2K"
            } else if resolution.width >= 3840 {
                return "4K"
            } else {
                return "Unknown Resolution"
            }
        }
        
        return "No Video Track Found"
    }
    
    
    //   static func getAllPaper(path:String)->[String]{
    //
    //
    //       var urls: [String] = []
    //       if path.isEmpty{
    //           return []
    //       }
    //       if FileManager.default.isDirectory(at: URL(string: path)!) == false{
    //           return urls
    //       }
    //       URL(string: path)!.startAccessingSecurityScopedResource()
    //       var paths = FileManager.default.subpaths(atPath: path)!
    //
    //       for subPath in paths{
    //           if subPath.hasSuffix(".mp4"){
    //               let url = URL(fileURLWithPath: "\(path)/\(subPath)")
    //               urls.append(url.absoluteString)
    //           }
    //
    //       }
    //       return urls
    //   }
}
