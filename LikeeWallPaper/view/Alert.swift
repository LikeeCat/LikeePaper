//
//  Alert.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2025/1/15.
//

import AppKit


struct PaperAlert {
    static func showAlert(message: String, informativeText: String = "") {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = message
            alert.informativeText = informativeText
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}
