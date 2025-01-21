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
                Divider()
                Spacer().frame(height: 10)
                LocalPaperFolderView().padding([.leading,.trailing], 20)
                Spacer().frame(height: 10)
                Divider()
                Spacer().frame(height: 10)
                hiddenFolderSetting().padding([.leading,.trailing], 20)
                mutedSetting().padding([.leading,.trailing], 20)
                Divider()
                Spacer().frame(height: 10)
                cleanPaperFolderSetting().padding([.leading,.trailing], 20)
                Spacer().frame(height: 10)
                
            }
            
        }
    }
    
    private struct AdvancedSettings: View {
        var body: some View {
            VStack(alignment: .leading){
                Spacer().frame(height: 10)
                isStopPlayWhenBattery().padding([.leading,.trailing], 20)
                Spacer().frame(height: 10)
                isStopPlayWhenOtherAppActivity().padding([.leading,.trailing], 20)
                Spacer().frame(height: 10)
                isLaunchAtStartUP().padding([.leading,.trailing], 20)
                Spacer().frame(height: 10)
            }
            
        }
    }
    
    private struct LocalPaperFolderView: View {
        @State private var showAlert = false // 控制 Alert 显示状态
        @State private var alertMessage: String = "" // Alert 显示的消息
        @State var folderPath  = Defaults[.defaultPaperFolder]
        var body: some View {
            VStack(alignment: .leading){
                HStack{
                    Text("本地文件存储位置")
                    Text("选择")
                        .font(.system(size: 12))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Theme.accentColor
                        )
                        .foregroundColor(
                            Theme.selectTextColor
                        )
                        .clipShape(Capsule())
                        .onTapGesture {
                            selectMP4File()
                        }
                    Spacer()
                }.alert("文件选择", isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(alertMessage)
                }
                HStack{
                    Image(systemName: "externaldrive.fill")
                    Text(folderPath)
                } .padding(10) // 添加内边距，使内容不贴着边框
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Theme.accentColor, lineWidth: 1) // 圆角边框
                    )
            }
            
        }
        
        func selectMP4File() {
            let panel = NSOpenPanel()
            panel.title = "选择文件夹"
            panel.message = "请选择包含 mp4 文件的文件夹"
            panel.prompt = "选择"
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories =  true
            panel.canCreateDirectories = false
            
            panel.begin { response in
                if response == .OK, let selectedFileURL = panel.url {
                    FileBookmarkManager.shared.clearBookmark()
                    folderPath = selectedFileURL.path
                    FileBookmarkManager.shared.saveBookmark(for: selectedFileURL)
                    PaperManager.sharedPaperManager.updatePaperFolder(assetUrl: selectedFileURL.path)
                    showAlert = true // 显示 Alert
                    alertMessage = "您选择的地址将作为本地动态壁纸的来源"
                    Papers.shared.all = Papers.allPapers().info
                    Papers.shared.allTags = Papers.allPapers().tag
                } else {
                    showAlert = true // 显示 Alert
                    alertMessage = "已取消选择"
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
            ).onChange({ newValue in
                PaperManager.sharedPaperManager.isUpdateAll(isUpdateAll: newValue)
            })
            .help("默认只会更换主屏幕壁纸显示,打开后,所有的屏幕都会同步更换")
        }
    }
    
    private struct hiddenFolderSetting: View {
        var body: some View {
            Defaults.Toggle(
                "隐藏桌面文件夹",
                key: .isHiddenFolder
            ).onChange({ newValue in
                PaperManager.sharedPaperManager.hiddenFolder(hiddenFolder: newValue)
            })
            .help("打开后,会隐藏桌面上的文件夹")
        }
    }
    
    private struct cleanPaperFolderSetting: View {
        var body: some View {
            Text("重置所有选择")
                .font(.system(size: 12))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Theme.accentColor
                )
                .foregroundColor(
                    Theme.selectTextColor
                )
                .clipShape(Capsule())
                .onTapGesture {
                    Defaults.removeAll()
                    Papers.shared.all = Papers.allPapers().info
                    Papers.shared.allTags = Papers.allPapers().tag
                }
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
    
    private struct isStopPlayWhenBattery : View {
        var body: some View {
            Defaults.Toggle(
                "未连接电源时暂停播放",
                key: .isStopPlayWhenBattery
            ).onChange({ newValue in
                PaperManager.sharedPaperManager.isStopPlayWhenBattery(isStopPlayWhenBattery: newValue)
            })
            .help("没有连接电源时停止播放视频")
        }
    }
    
    private struct isStopPlayWhenOtherAppActivity : View {
        var body: some View {
            Defaults.Toggle(
                "使用其他应用时停止播放",
                key: .isStopPlayWhenDeactivity
            ).onChange({ newValue in
                PaperManager.sharedPaperManager.isStopPlayWhenDeactivity(isStopPlayWhenDeactivity: newValue)
            })
            .help("当前桌面上有其他应用程序活跃时,停止播放视频")
        }
    }
    
    private struct isLaunchAtStartUP : View {
        var body: some View {
            Defaults.Toggle(
                "是否开机自启动",
                key: .isLaunchAtStartUP
            ).onChange({ newValue in
                 HelperToolManager.shared.handleEvent(install: newValue)
            })
            .help("当前桌面上有其他应用程序活跃时,停止播放视频")
        }
    }
    
    
    
    
}

struct UserSettingView_Previews: PreviewProvider {
    static var previews: some View {
        UserSettingView()
    }
}
