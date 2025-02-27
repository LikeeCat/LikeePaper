//
//  PaperView.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2023/2/21.
//


import AVKit
class PlayerView: NSView {

    //player setting
    var playerLayer:AVPlayerLayer?

    init(player: AVPlayerLayer?,frame:CGRect, cacheImage: NSImage){
        super.init(frame: frame)
        self.playerLayer = player
        
        
        if layer == nil{
           layer =  CALayer()
           layer?.contents = cacheImage  // 设置背景图片
           layer?.contentsGravity = .resizeAspectFill  // 适配图片填充
        }
        
        if player != nil{
            layer?.addSublayer(playerLayer!)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        playerLayer?.frame = bounds
        
    }

}



