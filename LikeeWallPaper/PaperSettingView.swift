//
//  PaperSettingView.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2023/2/23.
//

import SwiftUI
import Defaults
struct PaperSettingView: View {
    var screens = Defaults[.screensSetting]
    
    var body: some View {
        List{
            GeneralSettings()
        }.formStyle(.grouped)
        
    }
}
    
    private struct GeneralSettings: View {
        @State var paperAssetUrl:String = ""

        var body: some View {
            Form {
                Section {
                    HStack{
                        TextField("视频路径", text: $paperAssetUrl).padding(20).cornerRadius(10)
                        Divider()
                        Button("选择本地视频文件") {
                            Task {
                                guard let assetUrl = await chooseLocalWebsite() else{
                                    return
                                }
                                paperAssetUrl = assetUrl.absoluteString
                                
                            }
                        }
                        
                    }
                    
                }
                
                Section{
                    Button("确认") {
                        print("enter ++++++++++++++++++")
                        settingImage(assetUrlString: paperAssetUrl)
                        paperAssetUrl = ""
                        Constants.websitesWindow?.close()

                    }
                }
                
            }
        }
        
        @MainActor
        private func settingImage(assetUrlString:String){
            PaperManager.sharedPaperManager.updatePaper(assetUrlString: assetUrlString, screen: nil)

        }
        
        @MainActor
        private func chooseLocalWebsite() async -> URL?{
            //        guard let hostingWindow else {
            //            return nil
            //        }
            
            let panel = NSOpenPanel()
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.canCreateDirectories = false
            panel.title = "选择本地文件"
            panel.message = "选择本地视频文件作为壁纸"
            panel.prompt = "选择"
            
            // Ensure it's above the window when in "Browsing Mode".
            panel.level = .modalPanel
            
            //        let url = website.wrappedValue.url
            //
            //        if
            //            isEditing,
            //            url.isFileURL
            //        {
            //            panel.directoryURL = url
            //        }
            
            // TODO: Make it a sheet instead when targeting the macOS bug is fixed. (macOS 13.1)
            //        let result = await panel.beginSheet(hostingWindow)
            let result =  await panel.begin()
            
            guard
                result == .OK,
                let url = panel.url
            else {
                return nil
            }
            
            return url
            
            //        guard url.appendingPathComponent("index.html", isDirectory: false).exists else {
            //            await NSAlert.show(title: "Please choose a directory that contains a “index.html” file.")
            //            return await chooseLocalWebsite()
            //        }
            //
            //        do {
            //            try SecurityScopedBookmarkManager.saveBookmark(for: url)
            //        } catch {
            //            await error.present()
            //            return nil
            //        }
            
        }
    }
    
   
    

struct PaperSettingView_Previews: PreviewProvider {
    static var previews: some View {
        PaperSettingView()
    }
}
