import Foundation
import AVKit
import Defaults
import AVFoundation

@MainActor
class PaperPlayerController: NSViewController {
    
    var volume = Defaults[.volume] {
        didSet { playerVolume(volume: volume) }
    }
    
    var cancellables = Set<AnyCancellable>()
    
    var ismuted = Defaults[.isMuted] {
        didSet { playermuted(muted: ismuted) }
    }
    
    private var playerLayer: AVPlayerLayer?
    private var avPlayerLooper: AVPlayerLooper?
    private var queuePlayer: AVQueuePlayer?
    
    var stop: Bool? {
        didSet { playerstop() }
    }
    
    var assetUrl: URL?
    
    var isPlay: Bool {
        playerLayer?.player?.timeControlStatus == .playing
    }
    
    var playerView: PlayerView?
    
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
    
    override func loadView() {
        view = NSView()
    }
    
    private func isURLInSandbox(_ url: URL) -> Bool {
        guard let mainBundlePath = Bundle.main.bundlePath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return false
        }
        return url.path.hasPrefix(mainBundlePath)
    }
    
    func updateAssetUrl(newAsset: URL) {
        var asset: AVAsset?
        
//        if !isURLInSandbox(newAsset) {
//            let userSelectPath = Defaults[.userSelectPath]
//            FileBookmarkManager.shared.accessFileInFolder(using: newAsset.path, userSetting: userSelectPath == self.assetUrl!.path) { fileURL in
//                if let url = fileURL {
//                    asset = AVAsset(url: url)
//                    self.playWithAsset(aset: asset!, url: url)
//                }
//            }
//        } else {
            asset = AVAsset(url: newAsset)
            playWithAsset(aset: asset!, url: newAsset)
//        }
    }
    
    private func playWithAsset(aset: AVAsset, url: URL) {
        if let assetUrl = assetUrl, assetUrl == url {
            queuePlayer?.play()
            return
        }
        
        assetUrl = url
        let playerItem = AVPlayerItem(asset: aset)

        queuePlayer = AVQueuePlayer(playerItem: playerItem)

        avPlayerLooper = AVPlayerLooper(player: queuePlayer!, templateItem: playerItem)
        
//        // 5. 保持现有的 AVPlayerLayer
//        if let playerLayer = playerLayer {
//        } else {
//            // 如果没有现有的 playerLayer，则初始化一个新的并添加到视图
//            playerLayer = AVPlayerLayer(player: queuePlayer)
//            playerLayer?.videoGravity = .resize
//            playerLayer?.frame = view.bounds
//            view.layer?.addSublayer(playerLayer!)
//        }
//
        
        playerLayer?.player = queuePlayer

        if let cacheImage = getBackGroundImage(){
            playerView?.layer?.contents = cacheImage
            playerView?.layer?.contentsGravity = .resize  // 适配图片填充

            queuePlayer?.play()
        }
      
    }
    
    
    private func getBackGroundImage() -> NSImage?{
        let papers = Papers.allPapers().info.filter { paper in
            paper.path == assetUrl?.absoluteString
        }
        if papers.isEmpty {
            return nil
        }
        
        return papers[0].cachedImage
    }
    
    private func preparePlayerEnv() {
        if let assetUrl = assetUrl {
//            if !isURLInSandbox(assetUrl) {
//                let userSelectPath = Defaults[.userSelectPath]
//                FileBookmarkManager.shared.accessFileInFolder(using: assetUrl.path, userSetting: userSelectPath == assetUrl.path) { fileURL in
//                    if let url = fileURL {
//                        let nowAsset = AVAsset(url: url)
//                        setAVAssetEnv(asset: nowAsset)
//                    }
//                }
//            } else {
                let asset = AVAsset(url: assetUrl)
                setAVAssetEnv(asset: asset)
//            }
        }
    }
    
    private func setAVAssetEnv(asset: AVAsset) {
        let playerItem = AVPlayerItem(asset: asset)
        
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        self.queuePlayer = queuePlayer

        avPlayerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)

        let playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer.videoGravity = .resize
        self.playerLayer = playerLayer  // 让 playerLayer 被强引用
        if let cacheImage = getBackGroundImage(){
            playerView = PlayerView(player: playerLayer, frame: .zero, cacheImage: cacheImage)
            if playerView.isNil == false{
                self.view = playerView!
            }
        }
       
    }
    
    
    func setupEvent() {
        Defaults.publisher(keys: .isMuted, options: [])
            .sink { [self] in
                self.ismuted = Defaults[.isMuted]
            }.store(in: &cancellables)
        
        Defaults.publisher(keys: .volume, options: [])
            .sink { [self] in
                self.volume = Defaults[.volume]
            }.store(in: &cancellables)
    }
    
    func playerplay() {
        if isPlay { return }
        playerLayer?.player?.play()
        playerVolume(volume: self.volume)
        playermuted(muted: self.ismuted)
    }
    
    func playerpause() {
        playerLayer?.player?.pause()
    }
    
    func playerstop() {
        playerpause()
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        playerLayer?.frame = view.bounds
    }

    
    func playermuted(muted: Bool) {
        playerLayer?.player?.isMuted = muted
    }
    
    func playerVolume(volume: Float) {
        playerLayer?.player?.volume = volume
    }
    
    func releasePlayer() {
        queuePlayer?.pause()
        queuePlayer?.removeAllItems()
        queuePlayer = nil
        avPlayerLooper = nil
        playerLayer?.player = nil
        playerLayer = nil
        assetUrl = nil
        cancellables.removeAll()
        print("Player resources have been released.")
    }
    
    deinit {
        print("PaperPlayerController is being deinitialized.")
    }
}

