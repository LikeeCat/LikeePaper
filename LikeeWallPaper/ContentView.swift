//
//  ContentView.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2023/2/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        PaperSettingView().frame(minWidth: 855, minHeight: 600)

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
