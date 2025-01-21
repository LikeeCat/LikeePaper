
//
//  Ta"g.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2025/1/9.
//

import Foundation

extension String{
    func extractTags(blacklist: Set<String> = ["ran"]) -> Set<String> {
        // 获取文件名并移除扩展名
        let fileName = URL(fileURLWithPath: self).lastPathComponent.removingPercentEncoding
        let nameWithoutExtension = (fileName as! NSString).deletingPathExtension
        
        // 按 "-" 分割文件名
        let components = nameWithoutExtension.components(separatedBy: "-")
        
        // 使用 Set 过滤无效部分，并去重
        let validTags = Set(components.compactMap { component in
                let tag = component.trimmingCharacters(in: .whitespaces)
                
                // 仅对英文字符进行小写处理
                let processedTag: String
                if tag.rangeOfCharacter(from: .letters) != nil {
                    processedTag = tag.lowercased()
                } else {
                    processedTag = tag
                }
                
                // 检查是否在黑名单中，是否为空，或是否为数字
                return !processedTag.isEmpty &&
                       !blacklist.contains { processedTag.hasPrefix($0) } &&
                       Int(processedTag) == nil ? processedTag : nil
            })
        
        return validTags
    }
}
