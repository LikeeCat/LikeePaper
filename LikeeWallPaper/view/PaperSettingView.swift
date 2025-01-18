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
                }
                .padding()
            }
            
            if selectedTab == "壁纸中心" {
                PaperView().environmentObject(playList)
                //
            } else if selectedTab == "播放列表" {
                PlayListSettingView().environmentObject(playList)
            }
            Spacer()
        }
        .background(Theme.backgroundColor.edgesIgnoringSafeArea(.all))
        .onAppear{
            print("this is the play list \(playList.papers.count)")
        }
    }
}
@MainActor
private struct PaperView: View{
    @StateObject var papers = Papers.shared // Initialize papers here to be mutable
    @StateObject var display = DisplayMonitorObserver.shared
    @State var selectedIndex: Int =  DisplayMonitorObserver.shared.selectIndex
    @State private var selectedTags: Set<String> = []
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
                        }.padding(.leading, 10)
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
            Divider().frame(width: 1)
            PaperSettingRightView(tags: papers.allTags, onTagSelected: handleTagSelection, selectedIndex: $selectedIndex, models: $display.screens, selectedTags: $selectedTags)
                .frame(maxWidth: 300,maxHeight: .infinity)
        }.background(Theme.backgroundColor)
           
    }
    
    func selectMP4File() {
        let panel = NSOpenPanel()
        panel.title = "选择文件夹"
        panel.message = "请选择包含 mp4 文件的文件夹"
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
                showAlert = true // 显示 Alert
                alertMessage = "已取消选择"
                
            }
        }
    }
    
    // 处理标签点击事件
    private func handleTagSelection(tag: String) {
        withAnimation {
            Papers.shared.filterWithTag(tag: tag)
            selectedTags =  Papers.shared.selectTags
        }
    }
    
    // 处理标签点击事件
    private func addToPlayList(selectPaper: NSImage?) {
        if let selectPaper = selectPaper {
            let matchPaper = papers.all.first { paper in
                paper.cachedImage  == selectPaper
            }
            PlayListManager.updatePlayList(paper: matchPaper)
        }
    }
        
    @MainActor
    private func settingImage(assetUrlString:String){
        PlayListManager.updatePlayMode(mode: .single)
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
