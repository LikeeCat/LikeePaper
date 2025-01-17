//
//  Screens.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2025/1/17.
//

import AppKit
import Defaults
class DisplayMonitorObserver:ObservableObject {
    static let shared = DisplayMonitorObserver()
    @Published var screens:[ScreenModel]
    @Published var selectIndex: Int
    @Published var defaultScreens:[NSScreen]

    private var timer: Timer?

    func invalidate(){
        timer?.invalidate()
    }

    init() {
        // 每隔一段时间检查一次显示器数量
        screens = DisplayMonitorObserver.getScreens()
        selectIndex = DisplayMonitorObserver.getSelectedScreen()
        defaultScreens = NSScreen.screens
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkDisplayCount), userInfo: nil, repeats: true)
    }

    @objc func checkDisplayCount() {
        reloadScreenSetting()
        defaultScreens = NSScreen.screens
    }
    
    func reloadScreenSetting(){
        screens = DisplayMonitorObserver.getScreens()
        selectIndex = DisplayMonitorObserver.getSelectedScreen()
    }
    
    static func getScreens() -> [ScreenModel]{
       var result:[ScreenModel] = []
       for screen in NSScreen.screens {
           let model = ScreenModel(screenName: screen.localizedName)
           result.append(model)
       }
       return result
       
   }
   
    static func getSelectedScreen() -> Int{
       let models =  getScreens()
       let setting = Defaults[.defaultScreenSetting]
       return models.firstIndex { model in
           model.name == setting.screenName
       } ?? 0
   }

    deinit {
        // 停止定时器
        timer?.invalidate()
    }
}
