//
//  PaperManager.swift
//  LikeeWallPaper
//
//  Created by likeecat on 2023/2/21.
//

import Foundation
import AVKit
import Defaults
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
    
    func updateAssetUrl(newAsset:URL){
        let asset = AVAsset(url: newAsset)
        let playerItem = AVPlayerItem(asset: asset)
        queuePlayer?.removeAllItems()
        queuePlayer = AVQueuePlayer(playerItem: playerItem)
        avPlayerLooper = AVPlayerLooper(player: queuePlayer!, templateItem: playerItem)
        playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer?.videoGravity = .resize
        playerLayer?.videoGravity = .resizeAspectFill
        let player = PlayerView(player: playerLayer, frame: .zero)
        view = player
    }

    //MARK: -创建播放内容
    private func preparePlayerEnv(){
        let asset = AVAsset(url: self.assetUrl!)
        let playerItem = AVPlayerItem(asset: asset)
        queuePlayer = AVQueuePlayer(playerItem: playerItem)
        avPlayerLooper = AVPlayerLooper(player: queuePlayer!, templateItem: playerItem)
        playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer?.videoGravity = .resize
        playerLayer?.videoGravity = .resizeAspectFill
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
    func playerplay(){
        playerLayer?.player?.play()
        playerVolume(volume: self.volume)
        playermuted(muted: self.ismuted)
    }
    
    func playerpause(){
        playerLayer?.player?.pause()
    }
    
    func playerstop(){
        pause()
    }
    
    func playermuted(muted:Bool){
        playerLayer?.player?.isMuted = muted
    }
    
    func playerVolume(volume:Float){
        playerLayer?.player?.volume = volume
    }
    

}
