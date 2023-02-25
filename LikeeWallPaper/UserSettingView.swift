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
            
            
        }   .formStyle(.grouped)
            .frame(width: 400, height: 500)
            .fixedSize()

        
    }
    
    private struct GeneralSettings: View {
        var body: some View {
            Form {
                Section {
                    DisplaySetting()
                    ShowOnAllSpacesSetting()
                }
                Section {
                    hiddenFolderSetting()
                    isStopPlaySetting()
                    mutedSetting()
                }
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
                select = NSScreen.screens.firstIndex(of: screen!) ?? 0
            }
            
        }
    }

    private struct ShowOnAllSpacesSetting: View {
        var body: some View {
            Defaults.Toggle(
                "将壁纸应用在所有的屏幕上",
                key: .isUpdateAll
            )
                .help("While disabled, Plash will display the website on the space that is active at launch.")
        }
    }
    
    private struct hiddenFolderSetting: View {
        var body: some View {
            Defaults.Toggle(
                "隐藏桌面文件夹",
                key: .isHiddenFolder
            )
                .help("While disabled, Plash will display the website on the space that is active at launch.")
        }
    }
    
    private struct mutedSetting: View {
        var body: some View {
            Defaults.Toggle(
                "静音",
                key: .isMuted
            )
                .help("While disabled, Plash will display the website on the space that is active at launch.")
        }
    }
    
    private struct isStopPlaySetting: View {
        var body: some View {
            Defaults.Toggle(
                "打开其他应用暂停播放视频",
                key: .isStopPlay
            )
                .help("While disabled, Plash will display the website on the space that is active at launch.")
        }
    }

}

struct UserSettingView_Previews: PreviewProvider {
    static var previews: some View {
        UserSettingView()
    }
}
