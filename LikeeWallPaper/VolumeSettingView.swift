//
//  VolumeSettingView.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2023/2/25.
//

import SwiftUI
import Defaults
struct VolumeSettingView: View {
    var body: some View {
        VStack(alignment: .leading){
            Spacer().frame(height: 10)
            Text("播放声音设置").font(.title3).padding(.leading,20)
            Divider()
            Spacer().frame(height: 10)
            VolumeSettingSlider().padding([.leading,.trailing],20)
            Spacer().frame(height: 10)
            mutedSetting().padding(.leading,20)
            Spacer().frame(height: 20)
            HStack{
                Spacer()
                Button("确定") {
                    AppState.shared.closePopover()
                }.frame(width:70)
                Spacer()
            }
            Spacer().frame(height: 10)
            
        }.frame(width: 300,height: 160)
    }
}

private struct mutedSetting: View {
    var body: some View {
        Defaults.Toggle(
            "静音",
            key: .isMuted
        )
        .help("在播放视频时,关闭声音")
    }
}


private struct VolumeSettingSlider: View {
    @Default(.volume) private var volume
    
    var body: some View {
        Slider(
            value: $volume,
            in: 0.0...1,
            step: 0.1
        ) {
            Text("音量大小")
        }.onChange(of: volume) { newValue in
            Defaults[.volume] = newValue
        }
        
    }
}



struct VolumeSettingView_Previews: PreviewProvider {
    static var previews: some View {
        VolumeSettingView()
    }
}
