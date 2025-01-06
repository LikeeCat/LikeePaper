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
    
    
    
    func update(){
        playerController?.updatePlayer()
        hiddenFolder()
    }
    
    func play(){
        playerController?.playerplay()
        hiddenFolder()
    }
    
    func stop(){
        playerController?.playerstop()
        hiddenFolder()
    }
    
    func muted(){
        playerController?.ismuted = Defaults[.isMuted]
        hiddenFolder()
    }
    
    func bindingControllerToWindow(){
        window?.contentView = playerController?.view
        window?.makeKeyAndOrderFront(self)
        window?.hiddenFolder = Defaults[.isHiddenFolder]
    }
    
    private func hiddenFolder(){
        window?.hiddenFolder = Defaults[.isHiddenFolder]
        
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
    let powerSourceWatcher = PowerSourceWatcher()
    var cancellables = Set<AnyCancellable>()
    var isScreenLocked = false
    
    var screenManagers:[ScreenManager] = []
    var canPlay = false
    
    var isEnterFullScreen = false
    var isBattery = false
    var isActive = false
    
    private(set) lazy var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    init() {
        DispatchQueue.main.async { [self] in
            didLaunch()
            startWallPaper()
        }
    }
    
    func startWallPaper(){
        updateWallPaper()
        updatePlay(state: BatteryManager.shared.playState)
    }
    
    func updateWallPaper(){
        
        for sc in Defaults[.screensSetting]{
            let screen = NSScreen.from(cgDirectDisplayID: sc.screenId)
            creatPaperWindow(screen: screen, asset: sc.screenAssetUrl)
        }
    }
    
    func updateSingleWallPaper(screen:NSScreen, asset: String){
        creatPaperWindow(screen: screen, asset: asset)
        updatePlay(state: BatteryManager.shared.playState)

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
    
    private func didLaunch() {
        setEvents()
        setUpAppEvents()
        setStatusItem()
        BatteryManager.shared.start()
    }
    
}


//MARK: screen
extension AppState{
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
    }
    
    private func updateScreenManager(screen:NSScreen?, asset:String?, screenManager:ScreenManager){
        guard let _ = screen else{
            return
        }
        screenManager.playerController?.updateAssetUrl(newAsset: URL.init(string: asset!)!)
        screenManager.window?.contentView = screenManager.playerController?.view
        screenManager.settingWindowWallPaper()
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
    
}

//MARK: play
extension AppState{
    
    
    func updatePlay(state:ScreenStateOption = .activity){
        // 如果使用其他应用 暂停播放
        if state == .activity &&  Defaults[.isStopPlayWhenDeactivity] {
            stopAll()
            return
        }
        
        // 未使用电源时  暂停播放
        if state == .activity && Defaults[.isStopPlayWhenBattery] && powerSourceWatcher?.powerSource.isUsingBattery == true {
            stopAll()
            return
        }
        
        
        playAll()
    }
    
    
    func stopAll(){
        screenManagers.forEach { sc in
            sc.stop()
        }
    }
    
    func playAll(){
        screenManagers.forEach { sc in
            sc.play()
        }
    }
    
    
    func update(screen:NSScreen){
        let sms = screenManagers.filter{$0.display?.id == screen.id}
        if sms.count > 0 {
            let sm = sms[0]
            sm.update()
        }
    }
    
    func muted(){
        for sc in screenManagers{
            sc.muted()
        }
    }
    
}
