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

struct PaperSettingRightView: View{
    
    @Binding var selectedIndex: Int // 用来记录选中的索引
    @Binding var models: [ScreenModel]

    let display = [GridItem(.flexible())]

    
    var body: some View {
        VStack{
            Text("显示设置").font(.title)
            Spacer().frame(height: 10)
            LazyHGrid(rows: display, spacing: 10) {
                ForEach(models.indices, id: \.self){ index in
                    VStack{
                        Image(systemName: "display")
                            .resizable()
                            .frame(width: 100, height: 100, alignment: .center)
                            .foregroundColor(Color(.gray))
                            .scaleEffect(selectedIndex == index ? 1.2 : 1)
                            .shadow(color: selectedIndex == index ? .white : .black, radius: selectedIndex == index ? 2 : 1, x: 0, y: 2) // 选中时修改阴影
                            .animation(.easeInOut(duration: 0.2), value: selectedIndex) // 绑定动画到 selectedIndex
                        Spacer().frame(height: 10)
                        Text(models[index].name)
                        Spacer().frame(height: 5)
                    }.onTapGesture {
                        selectedIndex = index // 设置为选中项
                    }
                }
            }
            Defaults.Toggle(
                "将壁纸应用在所有的屏幕上",
                key: .isUpdateAll
            ).onChange({ newValue in
                PaperManager.sharedPaperManager.isUpdateAll(isUpdateAll: newValue)
            })
            
        }

        
    }
    
    

    
}
