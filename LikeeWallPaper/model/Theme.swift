//
//  Theme.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2025/1/6.
//

import Foundation
import SwiftUI

struct Theme {
    // 背景色
    static var backgroundColor: Color {
        return Color("BackgroundColor") // 自动根据系统亮暗模式切换颜色
    }
    
    // 文本色
    static var textColor: Color {
        return Color("TextColor") // 自动根据系统亮暗模式切换颜色
    }
    
    // 按钮背景色
    static var buttonBackgroundColor: Color {
        return Color("ButtonBackgroundColor") // 自动根据系统亮暗模式切换颜色
    }
    
    // 强调色
    static var accentColor: Color {
        return Color("AccentColor") // 自动根据系统亮暗模式切换颜色
    }
    
    // 禁用色
    static var disabledColor: Color {
        return Color("DisabledColor") // 自动根据系统亮暗模式切换颜色
    }
}
