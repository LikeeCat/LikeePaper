import Cocoa
import Defaults
extension AppState {
    
    
    private func createSwitchMenu() -> SSMenu {
        let menu = SSMenu()
        return menu
    }
    
    private func createMoreMenu() -> SSMenu {
        let menu = SSMenu()
        
        menu.addAboutItem()
        
        menu.addSeparator()
        
        return menu
    }
    
    
    
    func updateMenu() {
        if SSMenu.popover.isShown{
            closePopover()
        }
        menu.removeAllItems()
        menu.addCallbackItem("挑选本地壁纸") {
            Constants.openPaperWindow()
        }
        menu.addSeparator()
        menu.addCallbackItem("隐藏桌面文件", isChecked: Defaults[.isHiddenFolder]) {
            let hidden = Defaults[.isHiddenFolder]  == true ? false : true
            Defaults[.isHiddenFolder] = hidden
        }
        menu.addCallbackItem("播放视频时静音", isChecked: Defaults[.isMuted]) {
            let hidden = Defaults[.isMuted]  == true ? false : true
            Defaults[.isMuted] = hidden
        }
        menu.addCallbackItem("声音设置") {  [weak self] in
            self?.showPopover()
        }
        menu.addSeparator()
        menu.addCallbackItem("偏好设置",key: ",") {
            Constants.showSettingsWindow()
        }
        menu.addAboutItem()
        menu.addCallbackItem("退出") {
            NSApp.terminate(nil)
        }
    }
    
    
    @objc func togglePopover() {
        if SSMenu.popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }
    
    @objc func showPopover() {
        SSMenu.popover.contentViewController = VolumentSettingController.shared
        if let button = statusItem.button {
            SSMenu.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover() {
        SSMenu.popover.performClose(statusItem.button)
    }
}
