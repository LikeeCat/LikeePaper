//
//  TimerManager.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2025/1/14.
//

import SwiftUI
import Defaults

class TimerManager: ObservableObject {
    static let shared = TimerManager()
    private var timer: Timer?
    private var lastChangeTime: Date?
    @ObservedObject var paperPlayList = PaperPlayList.shared
    private var cancellables: Set<AnyCancellable> = []
    
    var switchTime: Double = Defaults[.playListSwitchTime] {
        didSet {
            rebuildTimer()
        }
    }
    
    var switchType: PlaybackMode = (PlaybackMode(rawValue: Defaults[.playListMode]) ?? .single) {
        didSet{
            if switchType == .single {
                invalidate()
            }
            else{
                startWallpaperChangeTimer()
            }
        }
    }
    
    func invalidate(){
        timer?.invalidate()
    }
    
    init() {
        loadTimerState() // 加载定时器的状态
        startWallpaperChangeTimer()
    }
    
    // 重建定时器
    private func rebuildTimer() {
        // 停止现有定时器
        timer?.invalidate()
        
        // 重建定时器
        startWallpaperChangeTimer()
    }
    
//    *3600
    
    private func startWallpaperChangeTimer() {
        timer = Timer.scheduledTimer(timeInterval: switchTime * 1 , target: self, selector: #selector(changeWallpaper), userInfo: nil, repeats: true)
    }
    
    // 切换壁纸的操作
    @objc private func changeWallpaper() {
        
        print("timer is \(switchTime) ++++++++++")
        if paperPlayList.papers.isEmpty {
            return
        }
        // 1. 获取当前的播放壁纸

        let mainScreenSetting = Defaults[.screensSetting].first { sc in
            sc.screenId == NSScreen.main?.id
        }
        
        if mainScreenSetting.isNil {
            return
        }
        
        let currentPaperIndex = paperPlayList.papers.firstIndex { paper in
            if let comp = URL.init(string: mainScreenSetting?.screenAssetUrl ?? "")?.deletingPathExtension() {
                var  imagePath = paper.image
                return imagePath.deletingPathExtension().lastPathComponent == comp.lastPathComponent
            }
            return false
        }
        
        if let currentIndex = currentPaperIndex {
            switch switchType {
                case .single:
                updateWallPaper(assetUrlString: paperPlayList.papers[currentIndex].path)
            case .loopAll:
                if currentIndex < paperPlayList.papers.count - 1 {
                    updateWallPaper(assetUrlString: paperPlayList.papers[currentIndex + 1].path)
                }
                else{
                    updateWallPaper(assetUrlString: paperPlayList.papers[0].path)
                }
            case .shuffle:
                let randomIndex = Int.random(in: 0..<(paperPlayList.papers.count - 1))
                updateWallPaper(assetUrlString: paperPlayList.papers[randomIndex].path)
            }
        }
        
    }
    
    
    private func updateWallPaper(assetUrlString: String){
        PaperManager.sharedPaperManager.updateWithAll(assetUrlString: assetUrlString)

    }
    
    // 模拟选择下一个壁纸
    private func getNextWallpaper() -> String {
        let wallpapers = ["wallpaper1.jpg", "wallpaper2.jpg", "wallpaper3.jpg"]
        return wallpapers.randomElement() ?? wallpapers[0]
    }
    
    // 保存定时器的状态
    private func saveTimerState() {
        UserDefaults.standard.set(lastChangeTime, forKey: "LastWallpaperChangeTime")
    }
    
    // 加载定时器的状态
    private func loadTimerState() {
        if let savedTime = UserDefaults.standard.object(forKey: "LastWallpaperChangeTime") as? Date {
            lastChangeTime = savedTime
        }
    }
    
    // 在对象销毁时停止定时器
    deinit {
        timer?.invalidate()
    }
}
