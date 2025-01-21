//
//  DocumentManager.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2025/1/18.
//

import Foundation
import Cocoa
class PaperShortCut{
    @MainActor static func settingImageWithShortCut(url: URL) -> Bool{
        // save file load
        FileBookmarkManager.shared.saveBookmark(for: url, userSetting: true)
        PaperManager.sharedPaperManager.updateUserSelectPath(userSelectPath: url.path)
        let resolution = Papers.getVideoResolutionCategory(url: url)
        let tags = url.absoluteString.extractTags()
        let audio = Papers.hasAudioTrack(for: url)
        if let imageUrl = AppState.getFirstFrameWithUrl(url: url){
            let info =  PaperInfo(path: url.absoluteString, image: imageUrl, resolution: resolution, tags: tags, local: true, audio: audio)
            let selectedIndex = DisplayMonitorObserver.shared.selectIndex
            PlayListManager.updatePlayMode(mode: .single)
            PaperManager.sharedPaperManager.updatePaper(assetUrlString: info.path, screen: DisplayMonitorObserver.shared.defaultScreens[selectedIndex])
            Papers.shared.reloadAll()
            Papers.shared.all = Papers.allPapers().info
            Papers.shared.allTags = Papers.allPapers().tag
            return true
        }
        return false
    }
}
