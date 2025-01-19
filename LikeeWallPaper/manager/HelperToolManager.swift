//
//  HelperToolManager.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2025/1/19.
//

import Foundation
import ServiceManagement

class HelperToolManager {
    static let shared = HelperToolManager()
    private let helperToolIdentifier = "com.shukangfan.LikeeWallPaper.Helper"
    
    
    @MainActor func handleEvent(install: Bool) -> Bool {
        if install {
            return installHelperTool()
        }else{
            return uninstallHelperTool()
        }
    }
        /// 安装 Helper Tool
    /// - Returns: 安装是否成功
    @MainActor func installHelperTool() -> Bool {
        let success = SMLoginItemSetEnabled(helperToolIdentifier as CFString, true)
        if success {
            PaperManager.sharedPaperManager.isLaunchAtStartUP(isLaunchAtStartUP: true)
            print("Helper Tool 安装成功")

        } else {
            print("Login Item 启用失败")
        }
        return success
    }
    
    /// 卸载 Helper Tool
    /// - Returns: 卸载是否成功
    @MainActor func uninstallHelperTool() -> Bool {
        let success = SMLoginItemSetEnabled(helperToolIdentifier as CFString, false)
        if success {
            PaperManager.sharedPaperManager.isLaunchAtStartUP(isLaunchAtStartUP: false)
            print("Helper App 开机启动已禁用")
        } else {
            print("禁用 Helper App 失败")
        }
        return success
        
    }
    
    /// 检查 Helper Tool 是否已安装
    /// - Returns: 是否已安装
    func isHelperToolInstalled() -> Bool {
        let helperToolPath = "/Library/PrivilegedHelperTools/\(helperToolIdentifier)"
        return FileManager.default.fileExists(atPath: helperToolPath)
    }
    
    /// 停止 Helper Tool 服务
    /// - Throws: 如果停止服务失败，会抛出错误
    private func stopHelperTool() throws {
        let result = try Process.run(URL(fileURLWithPath: "/bin/launchctl"), arguments: ["unload", "/Library/LaunchDaemons/\(helperToolIdentifier).plist"])
        if result.terminationStatus != 0 {
            throw NSError(domain: "HelperToolManager", code: Int(result.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "无法停止 Helper Tool 服务"])
        }
    }
}

// 扩展 Process，便于执行命令
extension Process {
    static func run(_ executable: URL, arguments: [String]) throws -> Process {
        let process = Process()
        process.executableURL = executable
        process.arguments = arguments
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        return process
    }
}
