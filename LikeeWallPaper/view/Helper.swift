import SwiftUI

struct HelperButtonView: View {
    @State private var isHelpPresented: Bool = false // 控制帮助界面是否展示
    
    var body: some View {
        Text("查看帮助文档")
            .font(.headline)
            .padding(10)
            .background(Theme.infoTextColor)
            .foregroundColor(.white)
            .cornerRadius(10)
            .onTapGesture {
                openHTMLFile()
            }
    }
    func openHTMLFile() {
            if let filePath = Bundle.main.path(forResource: "helper", ofType: "html") {
                let fileURL = URL(fileURLWithPath: filePath)
                NSWorkspace.shared.open(fileURL) // 用系统默认浏览器打开文件
            } else {
                print("Error: HTML file not found.")
            }
        }

}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        HelperButtonView()
    }
}

