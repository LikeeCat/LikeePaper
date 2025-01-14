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
    @State var models: [ScreenModel] = ScreenInfo.getScreen()
    @State var selectedIndex: Int = ScreenInfo.getSelectedScreen()
    
    let columns = [GridItem(.adaptive(minimum: 250), spacing: 3)]
    
    var body: some View {
        HStack{
            ScrollView {
                LazyVGrid(columns: columns, spacing: 3) {
                    ForEach(playlist.papers) { paper in
                        // 显示图片
                        AsyncImageView(
                            cachedImage:  paper.cachedImage,
                            placeholder: Image(systemName: "photo.circle.fill"),
                            size: CGSize(width: 250, height: 180),
                            resolution: paper.resolution,
                            env: .playList,
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
                        })))
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity) // 占用剩余宽度
            .padding(.top, 1)
            Divider().frame(width: 1)
            PlayListRightView(models: $models, selectedIndex: $selectedIndex,  currentMode: PlayListManager.getPlayMode())
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
