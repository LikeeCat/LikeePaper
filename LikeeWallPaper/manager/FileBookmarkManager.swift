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

    private init() {}

    /// 保存文件书签到 UserDefaults
    /// - Parameter fileURL: 要保存书签的文件 URL
    func saveBookmark(for fileURL: URL) {
        do {
            let bookmark = try fileURL.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(bookmark, forKey: bookmarkKey)
            print("Bookmark saved for URL: \(fileURL.path)")
        } catch {
            print("Error saving bookmark: \(error)")
        }
    }
    
    func accessFileInFolder(using filePath: String, completion: (URL?) -> Void) {
        guard let bookmarkData = UserDefaults.standard.data(forKey: bookmarkKey) else {
            print("No bookmark data found.")
            completion(nil)
            return
        }

        do {
            var isStale = false
            let folderURL = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)

            if isStale {
                print("Bookmark data is stale. Consider re-saving.")
                completion(nil)
                return
            }

            if folderURL.startAccessingSecurityScopedResource() {
                defer { folderURL.stopAccessingSecurityScopedResource() }

                // 构建目标文件 URL
                let targetFileURL = URL(fileURLWithPath: filePath)

                // 检查目标文件是否在书签关联的文件夹内
                guard targetFileURL.path.hasPrefix(folderURL.path) else {
                    print("Target file is not within the bookmarked folder.")
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
                print("Failed to access security-scoped resource from bookmark.")
                completion(nil)
            }
        } catch {
            print("Error accessing file from bookmark: \(error)")
            completion(nil)
        }
    }


    /// 从书签中访问文件
    @MainActor func accessFileFromBookmark() -> (info:[PaperInfo], tag:Set<String>){
        
        var papers:[PaperInfo] = []
        var allTags: Set<String> = []
        guard let bookmarkData = UserDefaults.standard.data(forKey: bookmarkKey) else {
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
                let contents = try fileManager.contentsOfDirectory(at: restoredURL, includingPropertiesForKeys: nil, options: [])

                for resourceURL in contents {
                    // 检查文件扩展名是否为 mp4
                    if ["mp4", "mov"].contains(resourceURL.pathExtension.lowercased()){
                        
                        let resolution = Papers.getVideoResolutionCategory(url: resourceURL)
                        let tags = resourceURL.absoluteString.extractTags()
                        if let imageUrl = AppState.getFirstFrameWithUrl(url: resourceURL){
                            let info =  PaperInfo(path: resourceURL.absoluteString, image: imageUrl, resolution: resolution, tags: tags, local: true)
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

    /// 删除保存的书签
    func clearBookmark() {
        UserDefaults.standard.removeObject(forKey: bookmarkKey)
        print("Bookmark cleared.")
    }
}


