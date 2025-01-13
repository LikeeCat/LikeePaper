//
//  ScreenInfo.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2025/1/13.
//

import Foundation
import Defaults
import AppKit

struct ScreenInfo {
     static func getScreen() -> [ScreenModel]{
        var result:[ScreenModel] = []
        for screen in NSScreen.screens {
            let model = ScreenModel(screenName: screen.localizedName)
            result.append(model)
        }
        return result
        
    }
    
     static func getSelectedScreen() -> Int{
        let models =  getScreen()
        let setting = Defaults[.defaultScreenSetting]
        return models.firstIndex { model in
            model.name == setting.screenName
        } ?? 0
    }
}
