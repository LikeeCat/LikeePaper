//
//  PlayListManager.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2025/1/10.
//

import Foundation
import Defaults
struct PlayListManager {
    
    
    static func getPlayListSwitchTime() -> Double {
        Defaults[.playListSwitchTime]
    }
    
    static func updatePlayListSwitchTime(time: Double) {
        TimerManager.shared.switchTime = time
        Defaults[.playListSwitchTime] = time
    }
    
    static func getPlayMode() -> PlaybackMode {
        let nowMode = Defaults[.playListMode]
        return PlaybackMode.allCases.first { mode in
            mode.rawValue == nowMode
        } ?? PlaybackMode.single
    }
    
    static func updatePlayMode(mode: PlaybackMode, envType: EnvType) {
        TimerManager.shared.envType = envType
        TimerManager.shared.switchType = mode
        Defaults[.playListMode] = mode.rawValue
    }
    
    static func getPlayList() -> [playListSetting] {
        Defaults[.playListSetting]
    }
    
    @MainActor static func updatePlayList(paper: PaperInfo?, local: Bool, delete: Bool = false){
        guard let paper = paper else{
            return
        }
        var currentArray = Defaults[.playListSetting]
        if delete {
            currentArray.removeAll() { setting in
                setting.name == paper.image.lastPathComponent && setting.local == local
            }
            Defaults[.playListSetting] = currentArray
            PaperPlayList.shared.updatePaper()
            return 
        }
        
        if currentArray.first(where: { setting in
            setting.name == paper.image.lastPathComponent && setting.local == local
        }) != nil {
            return
        } else{
            currentArray.append(playListSetting(local: local, name: paper.image.lastPathComponent))
            // 保存更新后的数组
            Defaults[.playListSetting] = currentArray
            PaperPlayList.shared.updatePaper()
        }
    }
    
    @MainActor static func rebuildPlayList(papers: [PaperInfo]){
        if papers.isEmpty{
            return
        }
        
        // 保存更新后的数组
        let newArray =  papers.map { paper in
            playListSetting(local: paper.local, name: paper.image.lastPathComponent)
        }
        Defaults[.playListSetting] = newArray
        PaperPlayList.shared.updatePaper()

    }

}
