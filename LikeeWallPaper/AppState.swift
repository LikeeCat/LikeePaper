//
//  AppState.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2023/2/22.
//


import SwiftUI
import Defaults
import Combine
typealias AnyCancellable = Combine.AnyCancellable

@MainActor
class ScreenManager{
    var playerController:PaperPlayerController?
    var window:DesktopWindow?
    var display:Display?
    
    init(playerController:PaperPlayerController?, window:DesktopWindow?,display:Display?) {
        self.playerController = playerController
        self.window = window
        self.display = display
    }
    
    func play(){
        playerController?.playerplay()
    }
    
    func bindingControllerToWindow(){
        window?.contentView = playerController?.view
        window?.makeKeyAndOrderFront(self)
    }
    
    func settingWindowWallPaper(){
        if let url = playerController?.assetUrl{
            if let path = AppState.getFirstFrameWithUrl(url: url){
                do{
                    try NSWorkspace.shared.setDesktopImageURL(path, for:  display?.screen! ?? NSScreen.defaultScreen!, options: [:])
                }
                catch{
                    print("error")
                }
                
            }
            
        }
    }
    
}


@MainActor
final class AppState: ObservableObject{
    static let shared = AppState()
    

    let menu = SSMenu()
    var cancellables = Set<AnyCancellable>()
        
    var screenManagers:[ScreenManager] = []
    
    private(set) lazy var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    init() {
        DispatchQueue.main.async { [self] in
            didLaunch()
            setEvents()
            setStatusItem()
        }
    }
    
    private func setEvents(){
        menu.onUpdate = { [self] in
            updateMenu()
        }
        
    }
    
    private func setStatusItem(){
        statusItem.isVisible = true
        statusItem.behavior = [.removalAllowed, .terminationOnRemoval]
        statusItem.menu = menu
        statusItem.button?.image = Constants.menuBarIcon
        statusItem.button?.imageScaling = .scaleProportionallyUpOrDown
    }
    
    func handle(){
        updateWallPaper()
    }
    
    func muted(){
        for sc in screenManagers{
            sc.playerController?.ismuted = Defaults[.isMuted]
        }
    }
    
    func updateWallPaper(){
        //update all
        for sc in Defaults[.screensSetting]{
            let screen = NSScreen.from(cgDirectDisplayID: sc.screenId)
            creatPaperWindow(screen: screen, asset: sc.screenAssetUrl)
        }
        
    }
    
    private func creatPaperWindow(screen:NSScreen?, asset:String?){
        
        guard let screen = screen else{
            return
        }
        let filterResult = screenManagers.filter({$0.display?.screen?.id == screen.id})
        if filterResult.isEmpty{
            creatScreenManager(screen: screen, asset: asset)
        }
        else{
            updateScreenManager(screen: screen, asset: asset, screenManager:filterResult[0])
        }
    }
    
    
    private func updateScreenManager(screen:NSScreen?, asset:String?, screenManager:ScreenManager){
        guard let screen = screen else{
            return
        }
        screenManager.playerController?.updateAssetUrl(newAsset: URL.init(string: asset!)!)
        screenManager.window?.contentView = screenManager.playerController?.view
        screenManager.settingWindowWallPaper()
        screenManager.playerController?.playerplay()
        
    }
    
    
    private func creatScreenManager(screen:NSScreen?,asset:String?){
        guard let screen = screen else{
            return
        }
        let display = Display(screen: screen)
        let desktopWindow = DesktopWindow(display: display)
        desktopWindow.alphaValue = 1
        let playerController = PaperPlayerController(assetUrl: URL.init(string: asset!))
        desktopWindow.contentView = playerController.view
        let screenManager = ScreenManager(playerController: playerController, window: desktopWindow, display: display)
        desktopWindow.makeKeyAndOrderFront(self)
        screenManagers.append(screenManager)
        screenManager.settingWindowWallPaper()
        screenManager.playerController?.playerplay()
        
        
    }
    
    private func didLaunch() {
    }
    
    
    
}
