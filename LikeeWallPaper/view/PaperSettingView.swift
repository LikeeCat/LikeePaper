//
//  PaperSettingView.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2023/2/23.
//

import SwiftUI
import Defaults

let item = GridItem.init(.flexible(), spacing: 0, alignment: .center)
private var screens = NSScreen.screens

struct PaperSettingView: View {
    
    var body: some View {
        HStack{
            PaperView().background(Theme.backgroundColor)
        }
    }
}

@MainActor
private struct PaperView: View{
    @State var papers = Papers.allPapers()  // Initialize papers here to be mutable
    @State var models:[ScreenModel] = getScreen()
    @State var selectedIndex:Int = getSelectedScreen()
    
    let columns = [GridItem(.adaptive(minimum: 250), spacing: 3)]
    
    var body: some View{
        HStack{
            ScrollView{
                LazyVGrid(columns: columns, spacing: 3) {
                    ForEach(0..<papers.count){ index in
                        if let url = papers[index].image as? URL {
                            ZStack(alignment: .bottomTrailing) {
                                // 显示图片
                                Image(nsImage: NSImage(contentsOf: url)!)
                                    .resizable()
                                    .frame(width: 250, height: 180)
                                    .scaledToFill()
                                    .onTapGesture {
                                        let url = papers[index].path
                                        settingImage(assetUrlString: url)
                                    }
                                if papers[index].resolution != "1080p" {
                                    Text(papers[index].resolution)
                                        .font(.subheadline)
                                        .foregroundColor(.white)  // 设置文本颜色为白色
                                        .padding(3)  // 内边距
                                        .background(Theme.accentColor)  // 设置背景色
                                        .cornerRadius(4)  // 圆角
                                        .padding(3)
                                    }
                                }
                                

                            
                        }
                    }
                }
                .padding(.horizontal)
            }.background(Theme.backgroundColor)
                .frame(maxWidth: .infinity) // 占用剩余空间
                .layoutPriority(0)
                .padding(.top,1)
            Divider().frame(width: 1)
            PaperSettingRightView(selectedIndex: $selectedIndex, models: $models)
                .layoutPriority(1) //
        }
    }
    
    
    private func reloadPapers() {
        // Fetch or reload your papers data here
        self.papers = Papers.allPapers()
    }
    private static func getScreen() -> [ScreenModel]{
        var result:[ScreenModel] = []
        for screen in screens {
            let model = ScreenModel(screenName: screen.localizedName)
            result.append(model)
        }
        return result
        
    }
    
    private static func getSelectedScreen() -> Int{
        let models =  getScreen()
        let setting = Defaults[.defaultScreenSetting]
        return models.firstIndex { model in
            model.name == setting.screenName
        } ?? 0
    }
    
    
    
    @MainActor
    private func settingImage(assetUrlString:String){
        PaperManager.sharedPaperManager.updatePaper(assetUrlString: assetUrlString, screen: screens[selectedIndex])
    }
    
    //        HStack{
    //
    //        }.onAppear{
    ////            if Defaults[.defaultPaperFolder].isEmpty{
    ////                Task {
    ////                    guard let assetUrl = await chooseLocalWebsite() else{
    ////                        return
    ////                    }
    ////                    updatePaperFolder(url: assetUrl.path)
    ////                }
    ////            }
    //        }
    //    }
    
    @MainActor
    private func chooseLocalWebsite() async -> URL?{
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.title = "选择文件夹"
        panel.message = "请选择一个包含视频文件的文件夹作为播放源"
        panel.prompt = "选择"
        panel.level = .modalPanel
        // TODO: Make it a sheet instead when targeting the macOS bug is fixed. (macOS 13.1)
        let result =  await panel.begin()
        guard
            result == .OK,
            let url = panel.url
        else {
            return nil
        }
        
        return url
    }
    
    private func updatePaperFolder(url:String){
        PaperManager.sharedPaperManager.updatePaperFolder(assetUrl:url)
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
    
    
    @MainActor
    private func chooseLocalWebsite() async -> URL?{
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.title = "选择文件"
        panel.message = "请选择一个视频文件"
        panel.prompt = "选择"
        panel.level = .modalPanel
        // TODO: Make it a sheet instead when targeting the macOS bug is fixed. (macOS 13.1)
        let result =  await panel.begin()
        guard
            result == .OK,
            let url = panel.url
        else {
            return nil
        }
        
        return url
    }
    
    
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
    
    
    
    @MainActor
    private func settingImage(assetUrlString:String){
        PaperManager.sharedPaperManager.updatePaper(assetUrlString: assetUrlString, screen: nil)
    }
    
}




struct PaperSettingView_Previews: PreviewProvider {
    static var previews: some View {
        PaperSettingView()
    }
}
