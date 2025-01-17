//
//  PlayListRightView.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2025/1/13.
//

import SwiftUI
import Defaults
struct PlayListRightView: View {
    
    @Binding var models: [ScreenModel]
    @Binding var selectedIndex: Int // 用来记录选中的索引
    @Binding var currentMode:PlaybackMode
    @State var switchTime =  PlayListManager.getPlayListSwitchTime()
    
    let display = [GridItem(.flexible())]
    let palyModes = PlaybackMode.allCases.filter { mode in
        mode != .single
    }
    
    let tagsConf = [
        GridItem(.adaptive(minimum: 80)) // 自动调整列宽，最小宽度为 80
    ]
    
    var body: some View {
        VStack(alignment: .leading){
            Spacer().frame(height:10)
            Text("循环设置")
                .font(.title3)
                .foregroundColor(Theme.textColor)
                .background(Theme.backgroundColor)
                .cornerRadius(10)
            Spacer().frame(height:10)
            LazyHGrid(rows: tagsConf, spacing: 16) {
                ForEach(palyModes, id: \.self) { mode in
                    PlayTagView(tag: mode, currentMode: $currentMode) { selectMode in
                        // 点击触发父视图中的标签选择处理函数
                        currentMode = selectMode
                        PlayListManager.updatePlayMode(mode: selectMode)
                    }
                }
            }.padding(10)
            Spacer().frame(height:10)
            HStack{
                Image(systemName: "info.circle.fill")
                    .foregroundColor(Theme.SecondaryTextColor)
                Text("点击图片即可切换为单循环")
                    .font(.footnote)
                    .foregroundColor(Theme.SecondaryTextColor)
                    .padding(3)
                Spacer()
            }
            Spacer().frame(height:10)
            Text("切换设置")
                .font(.title3)
                .foregroundColor(Theme.textColor)
                .background(Theme.backgroundColor)
                .cornerRadius(10)
            Spacer().frame(height:10)
            TimeProgressView(progress: $switchTime)
            Spacer().frame(height:10)
            Text("显示设置")
                .font(.title3)
                .foregroundColor(Theme.textColor)
                .background(Theme.backgroundColor)
                .cornerRadius(10)
            Spacer().frame(height:10)
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(130), spacing: 10), count: 2), spacing: 10) {
                ForEach(models.indices, id: \.self){ index in
                    HStack{
                        Image(systemName: "display")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                            .foregroundColor(selectedIndex == index ? Theme.buttonSelectTextColor : Theme.buttonNomalColor)
                            .scaleEffect(selectedIndex == index ? 1.05 : 1)
                            .animation(.easeInOut(duration: 0.2), value: selectedIndex) // 绑定动画到 selectedIndex
                        Text(models[index].name).font(.system(size: 13))
                            .foregroundColor(Theme.textColor)
                            .padding(2)
                            .background(Theme.backgroundColor)
                            .cornerRadius(10)
                        Spacer()
                    }.padding(5).onTapGesture {
                        selectedIndex = index // 设置为选中项
                    }
                }
            }.padding(10)
            Spacer().frame(height:10)
            Defaults.Toggle(
                "将壁纸应用在所有的屏幕上",
                key: .isUpdateAll
            ).onChange({ newValue in
                PaperManager.sharedPaperManager.isUpdateAll(isUpdateAll: newValue)
            })
            Spacer().frame(minHeight: 10)

        }.frame(maxWidth: .infinity, maxHeight: .infinity) //
        
    }
    
    
}



struct PlayTagView: View {
    let tag: PlaybackMode
    @Binding var currentMode: PlaybackMode
    let action: (PlaybackMode) -> Void
    
    var body: some View {
        Text(tag.description())
            .font(.system(size: 14))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                currentMode == tag ? Theme.accentColor : Theme.disabledColor.opacity(0.2)
            )
            .foregroundColor(
                currentMode == tag ? Theme.selectTextColor : Theme.textColor
            )
            .clipShape(Capsule())
            .onTapGesture {
                action(tag) // 执行传递过来的点击事件
            }
    }
}

struct TimeProgressView: View {
    @Binding var progress: Double
    
    var body: some View {
        HStack(spacing: 10) {
            // 进度条
            Slider(
                value: $progress,
                in: 1...24,  // 最小值 1 小时，最大值 24 小时
                step: 1      // 步长为 1 小时
            )
            .accentColor(Theme.accentColor)
            .padding(.leading,10)
            .onChange(of: progress) { newValue in
                print("进度更新为: \(newValue)")
                PlayListManager.updatePlayListSwitchTime(time: newValue)
            }
            // 显示当前时间进度
            Text("\(Int(progress)) 小时")
                .font(.title3)
                .bold().frame(minWidth: 100).padding(.trailing,10)

        }.padding(10)
    }
}

//
//#Preview {
//    PlayListRightView()
//}
