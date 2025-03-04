//
//  PaperSettingRightView.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2025/1/6.
//
import SwiftUI
import Defaults
private var screens = NSScreen.screens


class ScreenModel: ObservableObject {
    @Published var screenToSelected: String = ""
    var name: String
    func update(update:String) {
        // other functionality
        screenToSelected = update
    }
    init(screenName:String) {
        screenToSelected = screenName
        name = screenName
    }
}

struct TagView: View {
    let tag: String
    let selectedTags: Set<String>
    let action: () -> Void
    
    var body: some View {
        Text(tag)
            .font(.system(size: 14))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                selectedTags.contains(tag) ? Theme.accentColor : Theme.disabledColor.opacity(0.2)
            )
            .foregroundColor(
                selectedTags.contains(tag) ? Theme.selectTextColor : Theme.textColor
            )
            .clipShape(Capsule())
            .onTapGesture {
                action() // 执行传递过来的点击事件
            }
    }
}



struct PaperSettingRightView: View{
    // 标签数据（来自父视图）
    let tags: Set<String>
    
    // 选中的标签，使用 @Binding 将数据传递回父视图
    let onTagSelected: (String) -> Void

    @Binding var selectedIndex: Int // 用来记录选中的索引
    @Binding var models: [ScreenModel]
    @Binding var selectedTags:Set<String>
    let display = [GridItem(.flexible())]
    let tagsConf = [
        GridItem(.adaptive(minimum: 80)) // 自动调整列宽，最小宽度为 80
    ]
    
    var body: some View {
        VStack(alignment: .leading){
            Text("壁纸筛选")
                .font(.title3)
                .foregroundColor(Theme.PrimaryTextColor)
                .padding(10)
                .cornerRadius(10)
            ScrollView{
                LazyVGrid(columns: tagsConf, spacing: 16) {
                    ForEach(Array(tags).sorted(), id: \.self) { tag in
                        TagView(tag: tag, selectedTags: selectedTags) {
                            // 点击触发父视图中的标签选择处理函数
                            onTagSelected(tag)
                        }
                    }
                }

            }.frame(minHeight: 180).padding(5)
            Text("显示设置")
                .font(.title3)
                .foregroundColor(Theme.PrimaryTextColor)
                .padding(10)
                .cornerRadius(10)
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
                            .foregroundColor(Theme.SecondaryTextColor)
                            .padding(2)
                            .cornerRadius(10)
                        Spacer()
                    }.padding(5).onTapGesture {
                        selectedIndex = index // 设置为选中项
                    }
                }
            }.padding(5)
            Defaults.Toggle(
                "将壁纸应用在所有的屏幕上",
                key: .isUpdateAll
            ).onChange({ newValue in
                PaperManager.sharedPaperManager.isUpdateAll(isUpdateAll: newValue)
            }).padding(.leading,10)
            
            HelperButtonView()
                .padding(.leading, 5)
                .padding(.vertical, 10)

            Spacer().frame(minHeight: 10)

        }

        
    }
    
    
    
    
}


//struct PaperSettingRightView_Previews: PreviewProvider {
//    static var previews: some View {
//        PaperSettingRightView(selectedIndex: 0, models: [])
//    }
//}
