
//
//  Ta"g.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2025/1/9.
//

import Foundation

extension String{
    func extractTags(blacklist: Set<String> = ["with", "golden", "wind", "indoors", "mixing", "generated", "blue", "foggy", "ai", "drop", "illuminated", "catching", "horror", "running", "beautiful", "cute", "full%202", "calm", "spooky", "ready", "between", "walking", "moving", "crashing", "wet", "liquid", "modern", "together", "top", "wintry", "no", "pink", "colorful", "autumn", "winter", "halloween", "speed", "rocky", "to", "by", "at", "above", "of", "in", "on", "an", "the", "and", "a", "birds", "trees", "colors", "backgrounds", "animals", "pets", "remnants",  "waves", "looks", "lights","mp4", "1080p", "full", "temp", "mixkit", "lumalion", "lumafoxskunk",   "coverr", "surfboard", "speedometer", "dashboard"]) -> Set<String> {
        // 获取文件名并移除扩展名
        let fileName = URL(fileURLWithPath: self).lastPathComponent
        let nameWithoutExtension = (fileName as NSString).deletingPathExtension
        
        // 按 "-" 分割文件名
        let components = nameWithoutExtension.components(separatedBy: "-")
        
        // 使用 Set 过滤无效部分，并去重
        let validTags = Set(components.compactMap { component in
            let tag = component.trimmingCharacters(in: .whitespaces).lowercased()
            
            // 检查是否在黑名单中，是否为空，或是否为数字
            return !tag.isEmpty &&
                   !blacklist.contains(tag) &&
                   Int(tag) == nil ? tag : nil
        })
        
        return validTags
    }
}
