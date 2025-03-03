//
//  LikeeWallPaperApp.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2023/2/21.
//

import SwiftUI
import Defaults
@main
struct LikeeWallPaperApp: App {
    private var appState = AppState.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        
        Settings{
            UserSettingView()
        }
    }
    
    
}


@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    
    // Without this, Plash quits when the screen is locked. (macOS 13.2)
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        // It's important that this is here so it's registered in time.
        //        Defaults.removeAll()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // stop timer
        BatteryManager.shared.invalidate()
        TimerManager.shared.invalidate()
        DisplayMonitorObserver.shared.invalidate()
        
        AppState.shared.screenManagers.forEach { sc in
            sc.window?.hiddenFolder = true
        }
    }
    func applicationDidFinishLaunching(_ notification: Notification) {
        // init timer
        TimerManager.shared
        DisplayMonitorObserver.shared
        NSApp.setActivationPolicy(.accessory)
        Constants.mainWindow?.title = "选择壁纸"
        Constants.mainWindow?.titlebarAppearsTransparent = true           // 标题栏透明
        Constants.mainWindow?.isOpaque = false                            // 使窗口背景透明
        Constants.mainWindow?.backgroundColor = NSColor(Theme.backgroundColor)  // 设置背景为透明色
        Constants.mainWindow?.isMovableByWindowBackground = true
        Constants.mainWindow?.level = .normal
        Constants.mainWindow?.makeKeyAndOrderFront(nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeWindow), name: Notification.Name("CloseMainAppWindow"), object: nil)

    }
    
    @objc func closeWindow() {
        Constants.mainWindow?.close()
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        guard urls.count > 0 else{
            return
        }
        PaperShortCut.settingImageWithShortCut(url: urls[0])
        
    }
    
    // This is only run when the app is started when it's already running.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return false
    }
}

