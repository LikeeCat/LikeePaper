//
//  AsyncImageView.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2025/1/9.
//

import SwiftUI


struct AsyncImageView: View {
    var cachedImage: NSImage? // 从父视图绑定的图片
    let placeholder: Image
    let size: CGSize
    let resolution: String
    let env: AsyncImageViewEnv
    let local: Bool
    
    enum AsyncImageViewEnv{
        case paperCenter
        case playList
    }
    @State private var displayImage: NSImage?
    @State private var isHovered = false  // 控制按钮显示/隐藏
    let action: (NSImage?, Bool) -> Void
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            ZStack {
                if let displayImage = displayImage {
                    Image(nsImage: displayImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.width, height: size.height)
                        .clipped()
                    // 半透明按钮，动态适配主题色
                    Button(action: {
                        action(cachedImage, local)
                    }) {
                        Text(env == .paperCenter ? "添加至播放列表" : "从播放列表移除")
                            .font(.system(size: 12, weight: .light))// 圆角
                            .foregroundColor(Theme.textColor)
                            .padding(3)// 按钮文本颜色
                    }
                    .background(isHovered ? Theme.accentColor.opacity(0.7) : .clear)
                    .opacity(isHovered ? 1 : 0) // 动态透明度
                    .transition(.opacity)  // 动画效果
                    .padding(.bottom, 20)  // 距离底部 20
                    .position(x: size.width / 2, y: size.height - 10)
                    .cornerRadius(20)
                    let info = local ? "本地" : ""
                    let re =  resolution != "1080p" ? resolution : ""
                    let newInfo = info + (re.isEmpty ? re : "" + re)
                    if !newInfo.isEmpty {
                        Text(newInfo)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(3)
                            .background(Theme.accentColor)
                            .cornerRadius(4)
                            .padding([.trailing, .bottom], 10) // 标签边距
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    }
                    
                } else {
                    placeholder
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .clipped()
                        .frame(width: size.width, height: size.height)
                        .background(Color.gray.opacity(0.2))
                        .onAppear {
                            loadImageIfNeeded()
                        }
                }
            }.onHover { hovering in
                // 监听鼠标是否悬停
                withAnimation {
                    isHovered = hovering
                }
            }
        }
        
    }
    
    private func loadImageIfNeeded() {
        guard displayImage == nil, let cachedImage = cachedImage else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let resizedImage = resizeImage(cachedImage, to: size)
            DispatchQueue.main.async {
                self.displayImage = resizedImage
            }
        }
    }
    
    private func resizeImage(_ image: NSImage, to size: CGSize) -> NSImage {
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: size),
                   from: NSRect(origin: .zero, size: image.size),
                   operation: .copy,
                   fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
}
