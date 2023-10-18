//
//  MusicViewController.swift
//  SomeTestProject001
//
//  Created by MacBook Pro on 16.10.2022.
//

import UIKit
import AVFoundation

class MusicViewController: UIViewController {
    
    @IBOutlet weak var musicName: UILabel!
    @IBOutlet weak var musicArtist: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var PlayPause: UIButton!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    
    var playingMusic: MusicModel!
    let player = MusicPlayer.instance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player.playerVC = self
        imageView.image = Globals.getImage(img: playingMusic.img)
        musicName.text = playingMusic.name
        musicArtist.text = playingMusic.artist
        //downloadButton.imageView?.image = playingMusic.isDownloaded ? UIImage(named: "downloaded")! : UIImage(named: "download")!
        DispatchQueue.main.async {
            if self.playingMusic.isDownloaded || Globals.isDownloaded(track: self.playingMusic) {
                self.downloadButton.setImage(UIImage(named: "downloaded"), for: .normal)
            } else {
                self.downloadButton.setImage(UIImage(named: "download"), for: .normal)
            }
        }
        downloadButton.setImage(UIImage(named: playingMusic.isDownloaded ? "downloaded" : "download"), for: .normal)
        PlayPause.setImage(player.isPlaying ? UIImage(named: "pause")! : UIImage(named: "play")!, for: .normal)
        if let duration = player.player.currentItem?.asset.duration.seconds
        {
            slider.maximumValue = Float(duration)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        MainTabBarVC.miniPlayer.hidePlayer()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        MainTabBarVC.miniPlayer.showPlayer()
    }
    
    
    @IBAction func downloadMusic(_ sender: UIButton){
        if !playingMusic.isDownloaded
        {
            DispatchQueue.main.async
            {
                sender.imageView?.image = UIImage(named: "loading")!
                sender.rotate()
                Globals.donwloadTrack(track: self.playingMusic) {
                    sender.stopRotating()
                    self.playingMusic.isDownloaded = true
                    sender.imageView?.image = UIImage(named: "downloaded")!
                } _: {
                    sender.stopRotating()
                    sender.imageView?.image = UIImage(named: "download")!
                }

            }
        }
    }
    
    @IBAction func addToPlaylist(_ sender: UIBarButtonItem) {
        
    }
    
    
    @IBAction func PlayPauseAction(_ sender: UIButton) {
        player.isPlaying ? player.Pause() : player.Play()
    }
    
    
    @IBAction func Next(_ sender: Any) {
        if player.Next() {
            
        }
    }
    
    
    @IBAction func Prev(_ sender: UIButton) {
        if player.Prev() {
            
        }
    }
    
    @IBAction func FavButtonAction(_ sender: Any) {
        
    }
    
    
    @IBAction func changeSlider(sender: UISlider) {
        let interval = CMTime(seconds: Double(slider.value ), preferredTimescale: 1000)
        self.player.player.seek(to: interval)
    }
    
    
}
