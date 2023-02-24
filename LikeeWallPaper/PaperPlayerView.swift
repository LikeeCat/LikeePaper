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

    init(player: AVPlayerLayer?,frame:CGRect){
        super.init(frame: frame)
        self.playerLayer = player
        if layer == nil{
            layer =  CALayer()
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



//import AVKit
//import AppKit
//class PlayerView: NSView {
//
//    var playerLayer:AVPlayerLayer?
//    var avPlayerLooper:AVPlayerLooper?
//    var queuePlayer: AVQueuePlayer?
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        let assetUrl = Bundle.main.url(forResource: "resource/5_15488489003480", withExtension: ".mp4")!
//        let asset = AVAsset(url: assetUrl)
//        let playerItem = AVPlayerItem(asset: asset)
//        //  this is the queue
//        queuePlayer = AVQueuePlayer(playerItem: playerItem)
//        // this is the AVPlayerLooper
//        avPlayerLooper = AVPlayerLooper(player: queuePlayer!, templateItem: playerItem)
//        //this is the avplayer layer
//        playerLayer = AVPlayerLayer(player: queuePlayer!)
//        playerLayer?.videoGravity = .resize
//        playerLayer?.videoGravity = .resizeAspectFill
//        setupImage(url: assetUrl)
//        if layer == nil{
//            layer = CALayer()
//        }
//        layer?.addSublayer(playerLayer!)
//    }
//
//    func setupImage(url:URL){
//        let image = getFirstFrameWithUrl(url: url)
//        layer?.contents = image
//        layer?.contentsGravity = .resizeAspectFill
//    }
//
//    func play(){
//        queuePlayer?.play()
//    }
//
//    func pause(){
//        queuePlayer?.pause()
//    }
//
//    func stop(){
//        pause()
//    }
//
//    func getFirstFrameWithUrl(url:URL)->CGImage?{
//        let asset = AVAsset(url: Bundle.main.url(forResource: "resource/5_15488489003480", withExtension: ".mp4")!)
//        let imageGen = AVAssetImageGenerator(asset: asset)
//        guard let firstFrame = try? imageGen.copyCGImage(at: CMTime(value: 0, timescale: 1), actualTime: nil) else {
//                  return nil
//        }
//       return firstFrame
//
//    }
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func layout() {
//        super.layout()
//        playerLayer?.frame = bounds
//    }
//
//}
