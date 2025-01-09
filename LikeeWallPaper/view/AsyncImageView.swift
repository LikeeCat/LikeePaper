//
//  AsyncImageView.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2025/1/9.
//

import SwiftUI

struct AsyncImageView: View {
    let cachedImage: NSImage? // 已缓存的图片
    let placeholder: Image // 占位图
    let size: CGSize // 图片显示的尺寸

    @State private var displayImage: NSImage? // 当前展示的图片

    var body: some View {
        
        if let displayImage = displayImage {
            Image(nsImage: displayImage).resizable()
            .scaledToFill()
            .frame(width: 250, height: 180) // 适配实际尺寸
            .clipped()
            .onAppear {
                loadImage()
            }
        }
        else{
            ZStack{
                placeholder.resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35) // 适配实际尺寸
                    .clipped()
                    .onAppear {
                        loadImage()
                    }
            }.frame(width: 250, height: 180)
            
        }
           

    }

    private func loadImage() {
        guard let cachedImage = cachedImage else { return }

        // 异步加载和缩放图片
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
