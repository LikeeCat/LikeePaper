//
//  PlayListManager.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2025/1/10.
//

import Foundation
import Defaults
struct PlayListManager {
    
    static func getPlayList() -> [String] {
        Defaults[.playListSetting]
    }
    
    @MainActor static func updatePlayList(paper: PaperInfo?, delete: Bool = false){
        guard let paper = paper else{
            return
        }
        var currentArray = Defaults[.playListSetting]
        
        if currentArray.contains(paper.image.lastPathComponent) && delete  {
            currentArray.removeAll { id in
                id == paper.image.lastPathComponent
            }
            Defaults[.playListSetting] = currentArray
            PaperPlayList.shared.updatePaper()
            return
        }
        // 添加新元素
        if !currentArray.contains(paper.image.lastPathComponent) { // 可选：防止重复
            currentArray.append(paper.image.lastPathComponent)
        }
        // 保存更新后的数组
        Defaults[.playListSetting] = currentArray
        PaperPlayList.shared.updatePaper()
    }

}
