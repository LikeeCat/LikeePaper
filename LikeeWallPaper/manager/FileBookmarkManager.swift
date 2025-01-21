//
//  File.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2025/1/6.
//

import Foundation
import AVFoundation

class FileBookmarkManager {
    static let shared = FileBookmarkManager()
    let bookmarkKey = "SavedBookmark"
    let userSettingKey = "userSetting"

    private init() {}

    /// 保存文件书签到 UserDefaults
    /// - Parameter fileURL: 要保存书签的文件 URL
    func saveBookmark(for fileURL: URL, userSetting: Bool = false) {
        do {
            let bookmark = try fileURL.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(bookmark, forKey: userSetting ? userSettingKey : bookmarkKey)
            print("Bookmark saved for URL: \(fileURL.path)")
        } catch {
            print("Error saving bookmark: \(error)")
        }
    }
    
    func accessFileInFolder(using filePath: String, userSetting: Bool = false, completion: (URL?) -> Void) {
        let key = userSetting ? userSettingKey : bookmarkKey
        guard let markData = UserDefaults.standard.data(forKey: key) else {
            print("No key: \(key) data found.")
            completion(nil)
            return
        }

        do {
            var isStale = false
            let folderURL = try URL(resolvingBookmarkData: markData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)

            if isStale {
                print("Bookmark data is stale. Consider re-saving.")
                completion(nil)
                return
            }

            if folderURL.startAccessingSecurityScopedResource() {
                defer { folderURL.stopAccessingSecurityScopedResource() }

                // 构建目标文件 URL
                let targetFileURL = URL(fileURLWithPath: filePath)
                
                if userSetting {
                    if folderURL != targetFileURL {
                        completion(nil)
                        PaperAlert.showAlert(message: "文件不存在 \(filePath)")
                        return
                    }
                    else{
                        completion(targetFileURL)
                        return
                    }
                }
                // 检查目标文件是否在书签关联的文件夹内
                guard targetFileURL.path.hasPrefix(folderURL.path) else {
                    PaperAlert.showAlert(message: "文件无访问权限 \(filePath)")
                    completion(nil)
                    return
                }

                // 检查文件是否存在
                if FileManager.default.fileExists(atPath: targetFileURL.path) {
                    completion(targetFileURL)
                } else {
                    PaperAlert.showAlert(message: "文件不存在 \(filePath)")
                    completion(nil)
                }
            } else {
                PaperAlert.showAlert(message: "文件无访问权限")
                completion(nil)
            }
        } catch {
            completion(nil)
        }
    }


    /// 从书签中访问文件
    @MainActor func accessFileFromBookmark(userSetting: Bool = false) -> (info:[PaperInfo], tag:Set<String>){
        
        var papers:[PaperInfo] = []
        var allTags: Set<String> = []
        let key = userSetting ? userSettingKey : bookmarkKey
        guard let bookmarkData = UserDefaults.standard.data(forKey: key) else {
            print("No bookmark data found.")
            return (papers, allTags)
        }

        do {
            var isStale = false
            
            let restoredURL = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)

            if isStale {
                print("Bookmark data is stale. Consider re-saving.")
            }

            if restoredURL.startAccessingSecurityScopedResource() {
                defer { restoredURL.stopAccessingSecurityScopedResource() }
                // 访问文件夹并列出内容
                let fileManager = FileManager.default
                if userSetting {
                    let result = handleDataWithUrl(url: restoredURL)
                    if let info = result.info, let tags = result.tag {
                        allTags.formUnion(tags) // 合并到最终结果集合
                        papers.append(info)
                    }
                }
                else{
                    let contents = try fileManager.contentsOfDirectory(at: restoredURL, includingPropertiesForKeys: nil, options: [])

                    for resourceURL in contents {
                        
                        let result = handleDataWithUrl(url: resourceURL)
                        if let info = result.info, let tags = result.tag {
                            allTags.formUnion(tags) // 合并到最终结果集合
                            papers.append(info)
                        }
                    }
                }

            } else {
                print("Failed to access security-scoped resource from bookmark.")
            }
        } catch {
            print("Error accessing folder from bookmark: \(error)")
        }

        return (papers, allTags)

    }
    
    @MainActor func handleDataWithUrl(url: URL) -> (info: PaperInfo?, tag: Set<String>?){
        if ["mp4", "mov"].contains(url.pathExtension.lowercased()){
            
            let resolution = Papers.getVideoResolutionCategory(url: url)
            let tags = url.absoluteString.extractTags()
            let audio = Papers.hasAudioTrack(for: url)
            if let imageUrl = AppState.getFirstFrameWithUrl(url: url){
                let info =  PaperInfo(path: url.absoluteString, image: imageUrl, resolution: resolution, tags: tags, local: true, audio: audio)
                return (info, tags)
            }
            return (nil, nil)
        }
        return (nil, nil)

    }

    /// 删除保存的书签
    func clearBookmark() {
        UserDefaults.standard.removeObject(forKey: bookmarkKey)
        print("Bookmark cleared.")
    }
}


