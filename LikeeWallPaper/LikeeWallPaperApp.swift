//
//  LikeeWallPaperApp.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2023/2/21.
//

import SwiftUI

@main
struct LikeeWallPaperApp: App {
    private var appState = AppState.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Window("设置壁纸", id: "websites") {
            ContentView()
        }
            .windowToolbarStyle(.unifiedCompact)
            .windowResizability(.contentSize)
            .defaultPosition(.center)
        
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
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        Constants.websitesWindow?.close()
    }

    // This is only run when the app is started when it's already running.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return false
    }
}

