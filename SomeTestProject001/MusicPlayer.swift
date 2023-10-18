import Foundation
import AVFoundation
import AVKit
import MediaPlayer
import SDWebImage
import Alamofire

class MusicPlayer
{
    
    static var instance: MusicPlayer = { return MusicPlayer() }()
    
    var session: AVAudioSession!
    var player: AVPlayer!
    var trackVC: TrackListVC?
    var playerVC: MusicViewController?
    var playingMusic: MusicModel?
    var playingIndex: Int?
    var isPlaying: Bool = false
    
    
    private init() {
        setupAVAudioSession()
        setupCommandCenter()
        player = AVPlayer()
    }
    
    
    private func setupAVAudioSession() {
        self.session = AVAudioSession.sharedInstance()
        do {
            try self.session.setCategory(AVAudioSession.Category.playback)
            try self.session.setActive(true)
            debugPrint("AVAudioSession is Active and Category Playback is set")
            UIApplication.shared.beginReceivingRemoteControlEvents()
        }
        catch let error {
            print("*** Unable to set up the audio session: \(error.localizedDescription) ***")
        }
    }

    
    private func setupCommandCenter() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: "My player"]

        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        
        commandCenter.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            MusicPlayer.instance.Play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            MusicPlayer.instance.Pause()
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            return self.Next() ? .success : .commandFailed
        }
        commandCenter.previousTrackCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            return self.Prev() ? .success : .commandFailed
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { (remoteEvent) -> MPRemoteCommandHandlerStatus in
            guard let player = MusicPlayer.instance.player,
                  let event = remoteEvent as? MPChangePlaybackPositionCommandEvent
            else { return .commandFailed }
            player.seek(to: CMTime(seconds: event.positionTime, preferredTimescale: CMTimeScale(1000)), completionHandler: { (success) in
               if success {
                   MusicPlayer.instance.player.rate = player.rate
                   print(event.positionTime)
               }
            })
            return .success
        }
        
    }

    
    func OpenAndPlay(VC: TrackListVC, index: Int) {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.nextTrackCommand.isEnabled = index - 1 < VC.musics.count
        commandCenter.previousTrackCommand.isEnabled = index >= 0
        if let playerVC = playerVC {
            playerVC.nextButton.isEnabled = index - 1 < VC.musics.count
            playerVC.prevButton.isEnabled = index >= 0
        }
        
        self.trackVC = VC
        self.playingIndex = index
        self.playingMusic = VC.musics[index]
        if VC.musics[index].isDownloaded {
            //self.Open(path: "file://" + VC.musics[index].filePath)
            print(VC.musics[index].filePath)
            self.Open(path: "musuc\(VC.musics[index].id).mp3")
            self.Play()
        }
        else {
            AF.request(Globals.HOST + "/top/system.php?action=get_media&id=" + VC.musics[index].id).response{ response in
                if let res = response.data,
                   let json = try? JSONSerialization.jsonObject(with: res, options: []),
                   let object = (json as? [Any])?.first as? [String:Any],
                   let link = object["mp3"] as? String
                {
                    if let url = URL(string: (link.contains("http") ? "" : Globals.HOST ) + link) {
                        self.Open(url: url)
                        self.Play()
                        print("playing from web \(url.absoluteString)")
                    }
                }
            }
        }
    }
    
    
    func Open(path: String) {
        guard let documentsFolder = try? FileManager.default.url(
            for: .documentDirectory,
               in: .userDomainMask,
               appropriateFor: nil,
               create: false)
        else { return }
        let videoURL = documentsFolder.appendingPathComponent(path)
        self.player = AVPlayer(url: videoURL)
        MainTabBarVC.miniPlayer.showPlayer()
        setNowPlayingInfo()
        print("playing from file \(path)")
    }
    
    
    func Open(url: URL) {
        self.player = AVPlayer(url: url)
        MainTabBarVC.miniPlayer.showPlayer()
        setNowPlayingInfo()
    }
    
    
    @objc func Play() {
        self.player.play()
        self.isPlaying = true
        MainTabBarVC.miniPlayer.PlayPauseButton.setImage(UIImage(named: "pause")!, for: .normal)
        if let playerVC = playerVC {
            playerVC.PlayPause.setImage(UIImage(named: "pause")!, for: .normal)
        }
    }
    
    
    @objc func Pause() {
        self.player.pause()
        self.isPlaying = false
        MainTabBarVC.miniPlayer.PlayPauseButton.setImage(UIImage(named: "play")!, for: .normal)
        if let playerVC = playerVC {
            playerVC.PlayPause.setImage(UIImage(named: "play")!, for: .normal)
        }
    }
    
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        _ = self.Next()
    }
    
    
    @objc func Next() -> Bool {
        guard let VC = trackVC, let index = playingIndex
        else { return false }
        
        if index + 1 < VC.musics.count {
            OpenAndPlay(VC: VC, index: index + 1)
            VC.tableView.selectRow(at: IndexPath(row: index + 1, section: 0), animated: true, scrollPosition: .none)
        }
        else if VC.hasNext {
            VC.getNextFromSite({
                self.OpenAndPlay(VC: VC, index: index + 1)
                VC.tableView.selectRow(at: IndexPath(row: index + 1, section: 0), animated: true, scrollPosition: .none)
            })
        }
        return true
    }
    
    
    @objc func Prev() -> Bool {
        guard let VC = trackVC, let index = playingIndex
        else { return false }
        
        if index - 1 >= 0 {
            OpenAndPlay(VC: VC, index: index - 1)
            VC.tableView.selectRow(at: IndexPath(row: index - 1, section: 0), animated: true, scrollPosition: .none)
        }
        return true
    }
    
    
    fileprivate func setNowPlayingInfo() {
        var nowPlayingInfo = [String:Any]()
        if let track = playingMusic {
            nowPlayingInfo[MPMediaItemPropertyTitle] = track.name
            MainTabBarVC.miniPlayer.trackName.text = track.name
            nowPlayingInfo[MPMediaItemPropertyArtist] = track.artist
            MainTabBarVC.miniPlayer.artistName.text = track.artist
            let image = Globals.getImage(img: track.img)
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            MainTabBarVC.miniPlayer.trackImage.image = image
            if let playerVC = playerVC {
                playerVC.musicName.text = track.name
                playerVC.musicArtist.text = track.artist
                playerVC.imageView.image = image
                playerVC.slider.maximumValue = Float(player.currentItem?.asset.duration.seconds ?? Double(playerVC.slider.maximumValue))
            }
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.player.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.player.currentItem?.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.player.rate
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
        let interval = CMTime(seconds: 0.05, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        self.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { elapsedTime in
            let seconds = MusicPlayer.instance.player.currentTime().seconds
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seconds
            if let dur = MusicPlayer.instance.player.currentItem?.asset.duration.seconds {
                MainTabBarVC.miniPlayer.duration.progress = Float(seconds / dur)
                if let playerVC = self.playerVC, playerVC.slider.state == .normal{
                    playerVC.slider.value = Float(seconds)
                }
            }
        })
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem
        )
    }
    
   
}
