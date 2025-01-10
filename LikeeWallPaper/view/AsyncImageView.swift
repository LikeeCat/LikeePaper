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

    @State private var displayImage: NSImage?

    var body: some View {
        Group {
            if let displayImage = displayImage {
                Image(nsImage: displayImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .clipped()
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
