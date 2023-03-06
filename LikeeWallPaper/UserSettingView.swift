//
//  PaperSettingView.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2023/2/23.
//

import SwiftUI
import Defaults
struct UserSettingView: View {
    
    
    var body: some View {
        TabView{
            GeneralSettings().tabItem{
                Label("通用设置", systemImage: "gearshape")
            }
            AdvancedSettings().tabItem{
                Label("高级设置", systemImage: "gearshape.2")
            }
        }.windowLevel(.floating + 1)
          .frame(width: 300)
            
    
    }
    
    private struct GeneralSettings: View {
        var body: some View {
            VStack(alignment: .leading){
                Spacer().frame(height: 10)
                DisplaySetting().padding([.leading,.trailing], 20)
                ShowOnAllSpacesSetting().padding([.leading,.trailing], 20)
                Spacer().frame(height: 10)
                Divider()
                Spacer().frame(height: 10)
                hiddenFolderSetting().padding([.leading,.trailing], 20)
                mutedSetting().padding([.leading,.trailing], 20)
                Spacer().frame(height: 10)
            }

        }
    }
    
    private struct AdvancedSettings: View {
        var body: some View {
            VStack(alignment: .leading){
                Spacer().frame(height: 10)
                isStopPlayWhenBattery().padding([.leading,.trailing], 20)
                isStopPlayWhenOtherAppActivity().padding([.leading,.trailing], 20)
                Spacer().frame(height: 10)
            }
            
        }
    }

    
    private struct DisplaySetting: View {
        
        @State var select = 0
        var body: some View {
            Picker(
                "显示屏幕",
                selection: $select
            ) {
                ForEach(0..<NSScreen.screens.count, id: \.self) { j in
                    let screen = NSScreen.screens[j]
                    Text(screen.localizedName).tag(j)
                }
            }
            .onChange(of: select) { newValue in
                PaperManager.sharedPaperManager.updateDefaultScreen(screen: NSScreen.screens[newValue])
            }.onAppear{
                let screen = NSScreen.from(cgDirectDisplayID: Defaults[.defaultScreenSetting].screenId)
                if screen.isNil{
                    select = 0
                }
                else{
                    select = NSScreen.screens.firstIndex(of: screen!) ?? 0
                }
            }.help("修改壁纸的默认显示屏幕")
            
        }
    }
    
    private struct ShowOnAllSpacesSetting: View {
        var body: some View {
            Defaults.Toggle(
                "将壁纸应用在所有的屏幕上",
                key: .isUpdateAll
            )
            .help("默认只会更换主屏幕壁纸显示,打开后,所有的屏幕都会同步更换")
        }
    }
    
    private struct hiddenFolderSetting: View {
        var body: some View {
            Defaults.Toggle(
                "隐藏桌面文件夹",
                key: .isHiddenFolder
            )
            .help("打开后,会隐藏桌面上的文件夹")
        }
    }
    
    private struct mutedSetting: View {
        var body: some View {
            Defaults.Toggle(
                "静音",
                key: .isMuted
            )
            .help("在播放视频时,会进行静音处理")
        }
    }
    
    private struct isStopPlaySetting: View {
        var body: some View {
            Defaults.Toggle(
                "打开其他应用暂停播放视频",
                key: .isStopPlay
            )
            .help("打开其他应用暂停播放视频")
        }
    }
    
    private struct isStopPlayWhenBattery : View {
        var body: some View {
            Defaults.Toggle(
                "未连接电源时暂停播放",
                key: .isStopPlayWhenBattery
            )
            .help("没有连接电源时停止播放视频")
        }
    }
    
    private struct isStopPlayWhenOtherAppActivity : View {
        var body: some View {
            Defaults.Toggle(
                "使用其他应用时停止播放",
                key: .isStopPlayWhenDeactivity
            )
            .help("当前桌面上有其他应用程序活跃时,停止播放视频")
        }
    }
    
    
    
    
}

struct UserSettingView_Previews: PreviewProvider {
    static var previews: some View {
        UserSettingView()
    }
}
