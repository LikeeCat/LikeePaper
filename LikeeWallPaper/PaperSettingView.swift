//
//  PaperSettingView.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2023/2/23.
//

import SwiftUI
import Defaults

let item = GridItem.init(.flexible(), spacing: 0, alignment: .center)
private var symbols = NSScreen.screens

struct PaperSettingView: View {
    
    var body: some View {
        GeneralSettings().frame(width: 800,height: 600)
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


private class ScreenModel: ObservableObject {
    @Published var screenToSelected: String = ""
    func update(update:String) {
        // other functionality
        screenToSelected = update
    }
    init(screenName:String) {
        screenToSelected = screenName
    }
}

private struct GeneralSettingsScreenView: View {
    var stared = false
    var name:String = ""
    var body: some View {
        if stared{
            Text(name) + Text(Image(systemName: "star"))
        }
        else{
            Text(name)
        }
    }
    
}


private struct GeneralSettings: View {
    @State var paperAssetUrl:String = ""
    @State var select = false
    @State var isShowAlert = false
    @State var started = false

    @ObservedObject var viewModel: ScreenModel = ScreenModel(screenName: "123")
    @State var models:[[ScreenModel]] = getScreen()
    
    var body: some View {
        VStack{
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
            ForEach(0..<models.count){ colIndex in
                let col = models[colIndex]
                HStack{
                    ForEach(0..<col.count) { index in
                        GeneralSettingsScreenView(stared: started, name:col[index].screenToSelected ).frame(width:100,height: 100).border(.gray,width: 1).tag(index).onTapGesture {
                            started = !started
                        }
                    }

                }
            }
            Spacer().frame(height: 40)
            Button("确认") {
                if paperAssetUrl.isEmpty {
                    NSAlert.showModal(title: "提示",message: "请选择壁纸后重试")
                }
                else{
                    settingImage(assetUrlString: paperAssetUrl)
                    paperAssetUrl = ""
                    Constants.mainWindow?.close()
                }

            }
        }
    }
    
    static func colCount() -> [[NSScreen]]{
        var rows:[[NSScreen]] = []
        var arr:[NSScreen] = []
        for i in 0..<symbols.count{
            if i % 4 == 0{
                arr = []
                arr.append(symbols[i])
                if i == symbols.count - 1{
                    rows.append(arr)
                }
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
    
    func updateScreen(index:Int,col: Int,updateString:String){
        let model = models[col][index]
        model.update(update: updateString)
        models[col][index] = model
    }
    
    static func getScreen() -> [[ScreenModel]]{
        var result:[[ScreenModel]] = []
        for col in colCount() {
            var colresult:[ScreenModel] = []
            for index in col.indices{
                let model = ScreenModel(screenName: col[index].localizedName)
                colresult.append(model)
                }
            
            result.append(colresult)
            }
        return result
            
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
