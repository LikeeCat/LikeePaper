//
//  PaperSettingView.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2023/2/23.
//

import SwiftUI
import Defaults

let item = GridItem.init(.flexible(), spacing: 0, alignment: .center)

struct PaperSettingView: View {
    
    var body: some View {
        FilterView().background(Theme.backgroundColor)
    }
}

struct FilterView: View {
    @State private var selectedTab: String = "壁纸中心"
    @State var papers = Papers.shared.all // Initialize papers here to be mutable
    @StateObject var playList = PaperPlayList.shared
    
    // 定义筛选项
    let tabs = ["壁纸中心", "播放列表"]
    
    var body: some View {
        ZStack(alignment: .topTrailing){
            VStack {
                // 筛选框
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(tabs, id: \.self) { tab in
                            Text(tab)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(selectedTab == tab ? Theme.accentColor : Theme.disabledColor.opacity(0.2))
                                .foregroundColor(selectedTab == tab ? Theme.selectTextColor : Theme.textColor)
                                .cornerRadius(16)
                                .onTapGesture {
                                    withAnimation {
                                        selectedTab = tab
                                    }
                                }
                        }
                        Spacer()
                        Text(PhilosophicalQuotes.randomQuote())
                            .font(.system(size: 20, weight: .bold, design: .rounded)) // 超大字体
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                                   Color(red: 1.0, green: 0.8, blue: 0.6), // 温暖的米黄色
                                                   Color(red: 1.0, green: 0.9, blue: 0.7)  // 轻微的浅橙色
                                               ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                    }
                    .padding(.top, 10)
                    .padding(.leading, 10)
                }.frame(width: .infinity)
                
                if selectedTab == "壁纸中心" {
                    PaperView().environmentObject(playList)
                    //
                } else if selectedTab == "播放列表" {
                    PlayListSettingView().environmentObject(playList)
                }
            }
            .background(Theme.backgroundColor.edgesIgnoringSafeArea(.all))
            .onAppear{
                print("this is the play list \(playList.papers.count)")
            }
            
            Text("LivePaper")
                .font(.system(size: 30, weight: .bold, design: .rounded)) // 超大字体
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                                        Color(red: 0.6, green: 0.6, blue: 0.6), // 中性灰色，低调且不干扰
                                        Color(red: 0.9, green: 0.9, blue: 0.9)  // 轻微的灰白色
                                    ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(10)
                .frame(maxWidth: 180, alignment: .topTrailing) // 定位到右上角
                .offset(x: -20, y: -20) // 微调位置
                
        }
    }
}
@MainActor
private struct PaperView: View{
    @StateObject var papers = Papers.shared // Initialize papers here to be mutable
    @StateObject var display = DisplayMonitorObserver.shared
    @State var selectedIndex: Int =  DisplayMonitorObserver.shared.selectIndex
//    @State private var selectedTags: Set<String> = []
    @EnvironmentObject var paperList: PaperPlayList // 自动获取共享对象
    
    @State private var showAlert = false // 控制 Alert 显示状态
    @State private var alertMessage: String = "" // Alert 显示的消息
    
    
    let minSize = CGSize(width: 250, height: 180) // 最小尺寸
    
    
    var body: some View{
        HStack{
            GeometryReader { geometry in
                let screenWidth = geometry.size.width - 10
                let columns = Int(screenWidth / minSize.width) // 每排列数
                let itemWidth = screenWidth / CGFloat(columns) // 动态宽度
                let itemHeight = itemWidth * (minSize.height / minSize.width) // 动态高度，保持比例
                ZStack(alignment: .bottomTrailing) {
                    ScrollView {
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: columns), spacing: 10) {
                            ForEach(papers.all) { paper in
                                ZStack(alignment: .bottomTrailing) {
                                    // 显示图片
                                    AsyncImageView(
                                        cachedImage:  paper.cachedImage,
                                        placeholder: Image(systemName: "photo.circle.fill"),
                                        size: CGSize(width: itemWidth, height: itemHeight),
                                        resolution: paper.resolution, env: .paperCenter,
                                        local: paper.local,
                                        action: addToPlayList

                                    )
                                    .clipped() // 确保图片内容不超出
                                    .onTapGesture {
                                        let url = paper.path
                                        settingImage(assetUrlString: url)
                                    }
                                }
                            }
                        }
                    }.frame(minHeight: 0, maxHeight: .infinity) // 确保 `ScrollView` 内容可以超出屏幕范围
                        .padding(.top, 1)
                    
                    Image(systemName: "plus.circle")
                        .resizable() // 允许调整大小
                        .scaledToFit()
                        .background(Theme.accentColor)
                        .foregroundColor(.white)
                        .frame(width: 35, height: 35) // 设置尺寸
                        .clipShape(Circle()) // 裁切成圆形
                        .padding([.trailing, .bottom], 10) // 标签边距
                        .shadow(color: Color.primary.opacity(0.3), radius: 1, x: 3, y: 3) // 添加阴影
                        .onTapGesture {
                            selectMP4File()
                        }
                }.alert("文件选择", isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(alertMessage)
                }
            }
            .padding(10)
            .background(Theme.contentBackgroundColor)
            .cornerRadius(12)
            .padding(5)

            PaperSettingRightView(tags: papers.allTags, onTagSelected: handleTagSelection, selectedIndex: $selectedIndex, models: $display.screens, selectedTags: $papers.selectTags)
                .frame(maxWidth: 300,maxHeight: .infinity)
                .padding(10)
                .background(Theme.settingsBackgroundColor)
                .cornerRadius(12)
                .padding(5)

        }.background(Theme.backgroundColor)
           
    }
    
    func selectMP4File() {
        let panel = NSOpenPanel()
        panel.title = "选择文件夹"
        panel.message = "请选择包含 mp4 or mov 格式文件的文件夹"
        panel.prompt = "选择"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories =  true
        panel.canCreateDirectories = false
        
        panel.begin { response in
            if response == .OK, let selectedFileURL = panel.url {
                FileBookmarkManager.shared.clearBookmark()
                FileBookmarkManager.shared.saveBookmark(for: selectedFileURL)
                PaperManager.sharedPaperManager.updatePaperFolder(assetUrl: selectedFileURL.path)
                showAlert = true // 显示 Alert
                alertMessage = "您选择的地址将作为本地动态壁纸的来源"
                Papers.shared.reloadAll()
                
            } else {
                showAlert = false // 显示 Alert
            }
        }
    }
    
    // 处理标签点击事件
    private func handleTagSelection(tag: String) {
        withAnimation {
            Papers.shared.filterWithTag(tag: tag)
        }
    }
    
    // 处理标签点击事件
    private func addToPlayList(selectPaper: NSImage?, local: Bool) {
        if let selectPaper = selectPaper {
            let matchPaper = papers.all.first { paper in
                paper.cachedImage  == selectPaper && paper.local == local
            }
            PlayListManager.updatePlayList(paper: matchPaper, local: local)
        }
    }
        
    @MainActor
    private func settingImage(assetUrlString:String){
        PlayListManager.updatePlayMode(mode: .single, envType: .paperCenter)
        PaperManager.sharedPaperManager.updatePaper(assetUrlString: assetUrlString, screen: DisplayMonitorObserver.shared.defaultScreens[selectedIndex])
    }
    
    @MainActor
    private func chooseLocalWebsite() async -> URL?{
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.title = "选择文件夹"
        panel.message = "请选择.mp4 文件进行导入"
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

struct PaperSettingView_Previews: PreviewProvider {
    static var previews: some View {
        PaperSettingView()
    }
}
