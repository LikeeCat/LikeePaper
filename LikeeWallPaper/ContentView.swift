//
//  ContentView.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2023/2/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        PaperSettingView().frame(minWidth: 800, minHeight: 600) // 最小窗口大小
            .onAppear {
                // 获取窗口对象，并设置可缩放
                if let window = NSApplication.shared.windows.first {
                    window.styleMask.insert(.resizable) // 启用窗口缩放
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
