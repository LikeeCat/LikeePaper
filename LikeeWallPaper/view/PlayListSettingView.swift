//
//  PlayListSettingView.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2025/1/10.
//

import SwiftUI
struct PlayListSettingView: View {
    @EnvironmentObject var playlist: PaperPlayList
    let columns = [GridItem(.adaptive(minimum: 250), spacing: 3)]

    var body: some View {
        HStack{
            ScrollView {
                LazyVGrid(columns: columns, spacing: 3) {
                    ForEach(playlist.papers) { paper in
//                        ZStack(alignment: .bottomTrailing) {
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
//                                settingImage(assetUrlString: url)
                            }
                            

                            
                            
                            
//                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity) // 占用剩余宽度
            .padding(.top, 1)
            Divider().frame(width: 1)
        }.background(Theme.backgroundColor)

    }
    
    private func deletePlayList(selectPaper: NSImage?) {
        if let selectPaper = selectPaper {
            let matchPaper = playlist.papers.first { paper in
                paper.cachedImage == selectPaper
            }
            PlayListManager.updatePlayList(paper: matchPaper, delete: true)
        }
    }
}
