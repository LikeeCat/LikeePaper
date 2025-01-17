//
//  PlayListSettingView.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2025/1/10.
//

import SwiftUI
import UniformTypeIdentifiers
struct PlayListSettingView: View {
    @EnvironmentObject var playlist: PaperPlayList
    @StateObject var display = DisplayMonitorObserver.shared
    @State var selectedIndex: Int =  DisplayMonitorObserver.shared.selectIndex
    @State  var playMode = PlayListManager.getPlayMode()
    let minSize = CGSize(width: 250, height: 180) // 最小尺寸

    var body: some View {
        HStack{
                GeometryReader { geometry in
                    let screenWidth = geometry.size.width - 10
                    let columns = Int(screenWidth / minSize.width) // 每排列数
                    let itemWidth = screenWidth / CGFloat(columns) // 动态宽度
                    let itemHeight = itemWidth * (minSize.height / minSize.width) // 动态高度，保持比例
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: columns), spacing: 10) {
                            ForEach(playlist.papers) { paper in
                                ZStack(alignment: .bottomTrailing) {
                                    // 显示图片
                                    AsyncImageView(
                                        cachedImage:  paper.cachedImage,
                                        placeholder: Image(systemName: "photo.circle.fill"),
                                        size: CGSize(width: itemWidth, height: itemHeight),
                                        resolution: paper.resolution,
                                        env: .playList,
                                        local: paper.local,
                                        action: deletePlayList
                                    )
                                    .clipped() // 确保图片内容不超出
                                    .onTapGesture {
                                        let url = paper.path
                                        settingImage(assetUrlString: url)
                                    }
                                    .onDrag {
                                        NSItemProvider(object: paper.id.uuidString as NSString)
                                    }
                                    .onDrop(of: [UTType.text], delegate: DropViewDelegate(item: paper, playlist: Binding(get: {
                                        playlist.papers
                                    }, set: { newPapers in
                                        playlist.papers = newPapers
                                        PlayListManager.rebuildPlayList(papers: playlist.papers)
                                    })))                            }
                            }
                        }.padding(.leading, 10)

                        
                }.frame(maxWidth: .infinity) // 占用剩余宽度
                .padding(.top, 1)
                
            }

            Divider().frame(width: 1)
            PlayListRightView(models: $display.screens, selectedIndex: $selectedIndex,  currentMode: $playMode)
                .frame(maxWidth: 300,maxHeight: .infinity)
            
        }.background(Theme.backgroundColor)
            .onAppear {
                updateWindowDraggableState()
            }
            .onDisappear {
                resetWindowDraggableState()
            }
        
    }
    
    @MainActor
    private func settingImage(assetUrlString:String){
        PlayListManager.updatePlayMode(mode: .single)
        playMode = .single
        PaperManager.sharedPaperManager.updatePaper(assetUrlString: assetUrlString, screen: NSScreen.screens[selectedIndex])
    }
    
    private func deletePlayList(selectPaper: NSImage?) {
        if let selectPaper = selectPaper {
            let matchPaper = playlist.papers.first { paper in
                paper.cachedImage == selectPaper
            }
            PlayListManager.updatePlayList(paper: matchPaper, delete: true)
        }
    }
    
    private func updateWindowDraggableState() {
        if let window = Constants.mainWindow {
            window.isMovableByWindowBackground = false
        }
    }
    
    private func resetWindowDraggableState() {
        if let window = Constants.mainWindow {
            window.isMovableByWindowBackground = true
        }
    }
}

struct DropViewDelegate: DropDelegate {
    let item: PaperInfo
    @Binding var playlist: [PaperInfo]
    
    func performDrop(info: DropInfo) -> Bool {
        // 完成后，更新 playlist 的顺序
        return true
    }
    
    func dropEntered(info: DropInfo) {
        // 查找源索引
        guard let sourceIndex = playlist.firstIndex(where: { $0.id == item.id }) else { return }
        
        // 查找目标索引
        if let itemProvider = info.itemProviders(for: [UTType.text]).first {
            itemProvider.loadObject(ofClass: NSString.self) { object, error in
                if let targetIDString = object as? String,
                   let targetIndex = playlist.firstIndex(where: { $0.id.uuidString == targetIDString }) {
                    DispatchQueue.main.async {
                        if sourceIndex != targetIndex {
                            playlist.swapAt(targetIndex, sourceIndex)
                        }
                    }
                }
            }
        }
    }
}
