//
//  PaperSettingView.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2023/2/23.
//

import SwiftUI
import Defaults

let item = GridItem.init(.flexible(), spacing: 0, alignment: .center)
private var symbols = ["主屏幕", "副屏幕:2", "副屏幕:3", "副屏幕:4", "副屏幕:5", "副屏幕:6", "副屏幕:7"  ]

struct PaperSettingView: View {
    var screens = Defaults[.screensSetting]
    
    var body: some View {
        GeneralSettings().frame(width: 500,height: 700)
    }
}

private struct SelectImageView: View {
    
    var videoPath: String
    var selected = false
    var body: some View {
        if selected && videoPath.count > 0{
            Image(nsImage: getSelectImage(path: videoPath)).resizable().frame(width: 192*2, height: 168*2, alignment: .center).scaledToFill()
        }else{
            
            Image(systemName: "plus").resizable().frame(width: 100, height: 100, alignment: .center).scaledToFit().foregroundColor(Color(.gray))
            
        }
    }
    
    @MainActor func getSelectImage(path:String) -> NSImage{
        let url = URL(string: path)
        let imgPath = AppState.getFirstFrameWithUrl(url: url!)
        let image = NSImage(contentsOf: imgPath!)
        return image!
    }
}

private struct GeneralSettings: View {
    @State var paperAssetUrl:String = ""
    @State var select = false
    
    private let gridItemLayout:[GridItem] = [GridItem](repeating: item, count: symbols.count / 5)
    
    var body: some View {
        VStack{
            Text("选择壁纸")
            Spacer().frame(height: 20)
            SelectImageView(videoPath: paperAssetUrl, selected: select).onTapGesture {
                Task {
                    guard let assetUrl = await chooseLocalWebsite() else{
                        select = false
                        return
                    }
                    paperAssetUrl = assetUrl.absoluteString
                    select = true
                }
            }.frame(width: 400,height: 350).border(.gray,width: 1)
            Spacer().frame(height: 20)
            Text("选择屏幕")
            Spacer().frame(height: 20)
            ForEach(0..<colCount().count,id: \.self){
                let col = colCount()[$0]
                HStack{
                    ForEach(0..<col.count, id:\.self){
                        Text(col[$0]).frame(width:80,height: 60).border(.gray,width: 1)
                    }
                }
            }
            Spacer().frame(height: 40)
            Button("确认") {
                settingImage(assetUrlString: paperAssetUrl)
                paperAssetUrl = ""
                Constants.mainWindow?.close()
            }
        }
    }
    
    func colCount() -> [[String]]{
        var rows:[[String]] = []
        var arr:[String] = []
        for i in 0..<symbols.count{
            if i % 4 == 0{
                arr = []
                arr.append(symbols[i])
            }
            else if (i + 1) % 4 == 0 || i == symbols.count - 1 {
                arr.append(symbols[i])
                rows.append(arr)
            }
            else{
                arr.append(symbols[i])
            }
        }
        return rows
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
