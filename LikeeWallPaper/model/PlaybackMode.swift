//
//  PlayListMode.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2025/1/13.
//

import Foundation
enum EnvType {
    case paperCenter
    case PlayList
}

enum PlaybackMode: String, CaseIterable {
    case single = "single"      // 单个播放
    case shuffle = "shuffle"      // 随机播放
    case loopAll = "loopAll"      // 列表循环

    // 获取当前模式的描述
    func description() -> String {
        switch self {
        case .loopAll:
            return "列表循环"
        case .single:
            return "单张循环"
        case .shuffle:
            return "随机播放"
        }
    }
    
    // 切换到下一个模式
    func nextMode() -> PlaybackMode {
        switch self {
        case .loopAll:
            return .single
        case .single:
            return .shuffle
        case .shuffle:
            return .loopAll
        }
    }
}
