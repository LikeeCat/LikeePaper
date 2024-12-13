//
//  DesktopWindow.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2023/2/22.
//
import Cocoa
import Defaults
import Combine
@MainActor

final class DesktopWindow: NSWindow {

    var cancellables = Set<AnyCancellable>()

    var hiddenFolder =  Defaults[.isHiddenFolder]{
        didSet {
            if hiddenFolder == true {
                level = .desktopIcon + 1
                makeKey()
                orderBack(self)
                
            } else {
                level = .desktop
                makeKeyAndOrderFront(self)
            }
        }
    }
    
    var targetDisplay: Display? {
        didSet {
            setFrame()
        }
    }

    
    convenience init(display: Display?) {
        self.init(
            contentRect: .zero,
            styleMask: [
                .borderless
            ],
            backing: .buffered,
            defer: false
        )

        self.targetDisplay = display
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .desktop
        self.isRestorable = false
        self.canHide = false
        self.displaysWhenScreenProfileChanges = true
        self.collectionBehavior = [
            .stationary,
            .ignoresCycle,
            .fullScreenNone // This ensures that if Plash is launched while an app is fullscreen (fullscreen is a separate space), it will not show behind that app and instead show in the primary space.
        ]

        disableSnapshotRestoration()
        setFrame()
        setupEvent()
    }
    
    func setupEvent(){
        Defaults.publisher(keys:.isHiddenFolder,options: [])
            .sink { [self] in
                self.hiddenFolder = Defaults[.isHiddenFolder]
            }.store(in: &cancellables)
    }
    
    private func setFrame() {
        print("this is the target display +++ \(String(describing: targetDisplay))")
        guard let screen = targetDisplay?.screen ?? .main else {
            return
        }

        var frame = screen.visibleFrameWithoutStatusBar
        frame.size.height += 1 // Probably not needed, but just to ensure it covers all the way up to the menu bar on older Macs (I can only test on M1 Mac)


        setFrame(frame, display: true)
    }
    
}


