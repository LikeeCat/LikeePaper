//
//  PaperManager.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2023/2/23.
//

import Foundation
import Defaults
import Cocoa
class PaperManager{
    static let sharedPaperManager = PaperManager()
    
    @MainActor func updatePaper(assetUrlString:String, screen:NSScreen?){
        if Defaults[.isUpdateAll]{
            updateWithAll(assetUrlString: assetUrlString)
        }
        else{
            updateSinglePaper(assetUrlString: assetUrlString, screen: screen)
        }
    }
    
    func stopPlay(stop:Bool){
        UserSetting.stopPlay(stop: stop)
    }
    
    func hiddenFolder(hiddenFolder:Bool){
        UserSetting.hiddenFolder(hidden: hiddenFolder)
    }
    
    func updateDefaultScreen(screen:NSScreen){
        UserSetting.updateDefaultScreen(screen: screen)
    }
    
    func isUpdateAll(isUpdateAll:Bool){
        UserSetting.isUpdateAll(isUpdateAll: isUpdateAll)
    }
    
    @MainActor private func updateSinglePaper(assetUrlString:String, screen:NSScreen?){
        let updateScreen =  screen == nil ? NSScreen.defaultScreen! : screen!
        settingSingleScreen(assetUrlString: assetUrlString, screen: updateScreen)
    }
    
    
    @MainActor private func settingSingleScreen(assetUrlString:String, screen:NSScreen){
        UserSetting.updateScreenDisplay(screen: screen, assetUrl: assetUrlString)
    }
    
    @MainActor private func updateWithAll(assetUrlString:String){
        UserSetting.updateWithAll(assetUrlString: assetUrlString)
    }
    
    
}


private class UserSetting{
    
    static func stopPlay(stop:Bool){
        Defaults[.isStopPlay] = stop
    }
    
    static func hiddenFolder(hidden:Bool){
        Defaults[.isHiddenFolder] = hidden
    }
    
    static func isUpdateAll(isUpdateAll:Bool){
        Defaults[.isUpdateAll] = isUpdateAll
    }
    
    @MainActor static func updateScreenDisplay(screen:NSScreen,assetUrl:String){
        
        Defaults[.screensSetting].removeAll(where: { $0.screenId == screen.id })
        let newScreenSetting = ScreenSetting(screenName: screen.localizedName, screenId: screen.id, screenAssetUrl: assetUrl)
        Defaults[.screensSetting].append(newScreenSetting)
        AppState.shared.startWallPaper()

    }
    
    @MainActor static func updateWithAll(assetUrlString:String){
        var newSetting:[ScreenSetting] = []
        for sc in NSScreen.screens{
            let screenSetting = ScreenSetting(screenName: sc.localizedName, screenId: sc.id, screenAssetUrl: assetUrlString)
            newSetting.append(screenSetting)
        }
        Defaults[.screensSetting] = newSetting

        AppState.shared.startWallPaper()
    }
    
    
    static func updateDefaultScreen(screen:NSScreen){
        let screenSetting = ScreenSetting(screenName: screen.localizedName, screenId: screen.id, screenAssetUrl: "")
        Defaults[.defaultScreenSetting] = screenSetting
    }
    
    
}
