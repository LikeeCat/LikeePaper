//
//  File.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2025/1/6.
//

import Foundation


struct VideoWallpaper {
    let name: String       // 视频名称
    let url: URL           // 视频文件路径
    let tags: [String]     // 标签数组
}

class VideoWallpaperManager {
    private var videoWallpapers: [VideoWallpaper] = []
    
    // 初始化，传入标签和路径的映射关系
    init(mapping: [String: [URL]]) {
        loadVideoWallpapers(from: mapping)
    }

    // 加载视频壁纸
    private func loadVideoWallpapers(from mapping: [String: [URL]]) {
        for (tag, urls) in mapping {
            for url in urls {
                // 检查 URL 是否有效
                guard FileManager.default.fileExists(atPath: url.path) else {
                    print("文件不存在: \(url.path)")
                    continue
                }
                
                // 创建壁纸模型
                let video = VideoWallpaper(
                    name: url.lastPathComponent,
                    url: url,
                    tags: [tag] // 将当前标签添加为模型的标签
                )
                videoWallpapers.append(video)
            }
        }
    }

    // 根据标签获取视频壁纸
    func getWallpapers(byTag tag: String) -> [VideoWallpaper] {
        return videoWallpapers.filter { $0.tags.contains(tag) }
    }

    // 获取所有视频壁纸
    func getAllWallpapers() -> [VideoWallpaper] {
        return videoWallpapers
    }

    // 获取所有标签
    func getAllTags() -> [String] {
        let allTags = videoWallpapers.flatMap { $0.tags }
        return Array(Set(allTags)) // 去重
    }
}
