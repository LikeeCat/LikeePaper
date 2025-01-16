//
//  PaperManager.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2023/2/21.
//

import Foundation
import AVKit
import Defaults

import AVFoundation

extension AVPlayer.TimeControlStatus: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .paused: return "paused"
        case .waitingToPlayAtSpecifiedRate: return "waitingToPlayAtSpecifiedRate"
        case .playing: return "playing"
        @unknown default: return "unknown"
        }
    }
}


@MainActor
class PaperPlayerController:NSViewController{
    
    //property
    var volume = Defaults[.volume]{
        didSet{
            playerVolume(volume: volume)
        }
    }
    
    var cancellables = Set<AnyCancellable>()
    
    var ismuted = Defaults[.isMuted]{
        didSet{
            playermuted(muted: ismuted)
        }
    }
    
    //player ref
    private var playerLayer:AVPlayerLayer?
    private var avPlayerLooper:AVPlayerLooper?
    private var queuePlayer: AVQueuePlayer?
    
    //play setting
    var stop:Bool?{
        didSet{
            playerstop()
        }
    }
    
    var isPlay:Bool {
        get{
            playerLayer?.player?.timeControlStatus == .playing
        }
    }
    
    var assetUrl:URL?
    
    convenience init(volume: Float = Defaults[.volume], ismuted: Bool = Defaults[.isMuted], playerLayer: AVPlayerLayer? = nil, avPlayerLooper: AVPlayerLooper? = nil, queuePlayer: AVQueuePlayer? = nil, stop: Bool? = nil, assetUrl: URL? = nil) {
        self.init()
        self.volume = volume
        self.ismuted = ismuted
        self.playerLayer = playerLayer
        self.avPlayerLooper = avPlayerLooper
        self.queuePlayer = queuePlayer
        self.stop = stop
        self.assetUrl = assetUrl
        preparePlayerEnv()
        setupEvent()
    }
    
    func createPlayerView() -> PlayerView{
        let playerView = PlayerView(player: nil, frame: .zero)
        return playerView
    }
    
    private func isURLInSandbox(_ url: URL) -> Bool {
        guard let mainBundlePath = Bundle.main.bundlePath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return false
        }
        // 检查目标路径是否以 Main Bundle 的路径开头
        return url.path.hasPrefix(mainBundlePath)
    }
    func updateAssetUrl(newAsset: URL) {
        // 1. 创建新的 AVAsset 和 AVPlayerItem
        var asset: AVAsset?
        
        if !isURLInSandbox(newAsset) {
            FileBookmarkManager.shared.accessFileInFolder(using: newAsset.path) { fileURL in
                if let url = fileURL {
                    asset = AVAsset(url: url)
                    playWithAsset(aset: asset!, url: url)
                }
            }
            
        } else {
            asset = AVAsset(url: newAsset)
            playWithAsset(aset: asset!, url: newAsset)
        }
        
        
    }
    

    private func playWithAsset(aset: AVAsset , url: URL) {
        // Check if the new asset is the same as the previous one
            // If it's the same, just start looping
        if let assetUrl = assetUrl {
            if assetUrl == url {
                queuePlayer?.play()
                return

            }
        }
        
        // Update the previous asset reference
        assetUrl = url
        
        let playerItem = AVPlayerItem(asset: aset)
        
        // 2. 添加过渡遮罩视图
        let transitionView = NSView(frame: view.bounds)
        transitionView.wantsLayer = true
        transitionView.layer?.backgroundColor = NSColor.black.cgColor
        view.addSubview(transitionView)
        
    
        queuePlayer = AVQueuePlayer(playerItem: playerItem)
        avPlayerLooper = AVPlayerLooper(player: queuePlayer!, templateItem: playerItem)
        
        // 5. 保持现有的 AVPlayerLayer
        if let playerLayer = playerLayer {
            playerLayer.player = queuePlayer
        } else {
            // 如果没有现有的 playerLayer，则初始化一个新的并添加到视图
            playerLayer = AVPlayerLayer(player: queuePlayer)
            playerLayer?.videoGravity = .resize
            playerLayer?.frame = view.bounds
            view.layer?.addSublayer(playerLayer!)
        }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 1  // 总时长为 1 秒
            
            // 使用自定义的 timingFunction，使得前半部分慢，后半部分快
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut) // 也可以尝试其他函数，如 .easeIn 或 .easeOut
            
            transitionView.animator().alphaValue = 0
        }) {
            // 动画结束后移除遮罩视图
            transitionView.removeFromSuperview()
        }

        
        // 7. 开始播放
        queuePlayer?.play()
    }
    //MARK: -创建播放内容
    private func preparePlayerEnv(){
        
        if !isURLInSandbox(self.assetUrl!) {
            FileBookmarkManager.shared.accessFileInFolder(using: self.assetUrl!.path) { fileURL in
                if let url = fileURL {
                    let nowAsset = AVAsset(url: url)
                    setAVAssetEnv(asset: nowAsset)
                }
            }
            
        } else {
            let asset = AVAsset(url: self.assetUrl!)
            setAVAssetEnv(asset: asset)
        }
        
    }
    
    private func setAVAssetEnv(asset: AVAsset){
        let playerItem = AVPlayerItem(asset: asset)
        queuePlayer = AVQueuePlayer(playerItem: playerItem)
        avPlayerLooper = AVPlayerLooper(player: queuePlayer!, templateItem: playerItem)
        playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer?.videoGravity = .resize
        let player = PlayerView(player: playerLayer, frame: .zero)
        view = player
    }
    
    override func loadView() {
        view = NSView()
    }
    
    func setupEvent(){
        Defaults.publisher(keys:.isMuted,options: [])
            .sink { [self] in
                self.ismuted = Defaults[.isMuted]
            }.store(in: &cancellables)
        
        Defaults.publisher(keys:.volume,options: [])
            .sink { [self] in
                self.volume = Defaults[.volume]
            }.store(in: &cancellables)
    }
}

extension PaperPlayerController{
    
    //MARK: 播放器相关
    func   playerplay(){
        
        if isPlay{
            return
        }
        playerLayer?.player?.play()
        playerVolume(volume: self.volume)
        playermuted(muted: self.ismuted)
    }
    
    
    func playerpause(){
        playerLayer?.player?.pause()
    }
    
    func updatePlayer(){
        //        let rate = playerLayer?.player?.rate == 1 ? 0 : 1
        //        if rate == 1{
        //            playerplay()
        //        }
        //        else{
        //            playerstop()
        //        }
    }
    
    func playerstop(){
        playerpause()
    }
    
    func playermuted(muted:Bool){
        playerLayer?.player?.isMuted = muted
    }
    
    func playerVolume(volume:Float){
        playerLayer?.player?.volume = volume
    }
    
    
}
