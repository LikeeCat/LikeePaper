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

		
		menu.addMoreAppsItem()

		return menu
	}

	

	func updateMenu() {
        menu.removeAllItems()
        menu.addCallbackItem("隐藏桌面文件", isChecked: Defaults[.isHiddenFolder]) {  [weak self] in
            let hidden = Defaults[.isHiddenFolder]  == true ? false : true
            Defaults[.isHiddenFolder] = hidden
        }
        
        menu.addCallbackItem("播放视频时静音", isChecked: Defaults[.isMuted]) {  [weak self] in
            let hidden = Defaults[.isMuted]  == true ? false : true
            Defaults[.isMuted] = hidden
        }

        
        menu.addCallbackItem("挑选本地壁纸") {
            Constants.openWebsitesWindow()
        }

        menu.addCallbackItem("偏好设置") {
            Constants.showSettingsWindow()
        }
        
        menu.addAboutItem()
        menu.addSeparator()
        menu.addMoreAppsItem()
        menu.addCallbackItem("退出") {
            NSApp.terminate(nil)
        }
        print("enter here ++++++++")
	}
}
