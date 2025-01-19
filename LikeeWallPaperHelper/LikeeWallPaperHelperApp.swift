//
//  LikeeWallPaperHelperApp.swift
//  LikeeWallPaperHelper
//
//  Created by likeecat on 2025/1/19.
//

import SwiftUI

@main
struct LikeeWallPaperHelperApp: App {
    var body: some Scene {
        WindowGroup {
            EmptyView() // 不需要 UI，保持窗口为空
        }
        .commands {
            CommandGroup(replacing: .appTermination) {
                Button("Quit Helper App") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
    }
    
    init() {
        launchMainApp()
    }
    
    
    private func launchMainApp() {
        let mainAppBundleIdentifier = "com.LikeeWallPaper.app" // 主应用的 Bundle Identifier

        // 查询主应用路径
        if let mainAppURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: mainAppBundleIdentifier) {
            NSWorkspace.shared.open(mainAppURL)
           
        } else {
            print("找不到主应用，确保它已正确安装并具有指定的 Bundle Identifier")
        }

        // Helper App 自行退出
        NSApplication.shared.terminate(nil)
    }

}
