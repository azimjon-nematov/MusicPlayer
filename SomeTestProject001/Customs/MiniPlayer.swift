//
//  MiniPlayer.swift
//  SomeTestProject001
//
//  Created by MacBook Pro on 12.10.2022.
//

import UIKit

@IBDesignable
class MiniPlayer: UIView {

    var view: UIView!
    var isVisiable: Bool = false
    var mainTabBar: MainTabBarVC!
    
    static let tabBarHeight: CGFloat = 50.0
    static let miniPlayerHeight: CGFloat = 70.0
    
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var duration: UIProgressView!
    @IBOutlet weak var PlayPauseButton: UIButton!
    
    
    func hidePlayer() {
        self.isHidden = true
        self.isVisiable = false
        mainTabBar.viewControllers?.forEach {
           $0.additionalSafeAreaInsets = UIEdgeInsets(
              top: 0,
              left: 0,
              bottom: MiniPlayer.tabBarHeight,
              right: 0
           )
        }
    }
    
    
    func showPlayer() {
        self.isHidden = false
        self.isVisiable = true
        mainTabBar.viewControllers?.forEach {
           $0.additionalSafeAreaInsets = UIEdgeInsets(
              top: 0,
              left: 0,
              bottom: MiniPlayer.tabBarHeight + MiniPlayer.miniPlayerHeight,
              right: 0
           )
        }
    }
    
    
    convenience init(tabBarVC: MainTabBarVC) {
        //self.init(frame: CGRect(x: 0.0, y: y, width: tabBarVC.tabBar.frame.width, height: 70.0))
        self.init(frame: CGRect.zero)
        self.mainTabBar = tabBarVC
        tabBarVC.view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor.constraint(equalTo: tabBarVC.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: tabBarVC.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: tabBarVC.view.safeAreaLayoutGuide.bottomAnchor, constant: -MiniPlayer.tabBarHeight).isActive = true
        self.heightAnchor.constraint(equalToConstant: MiniPlayer.miniPlayerHeight).isActive = true
        self.hidePlayer()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(view)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
    }
    
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "MiniPlayer", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    
    @IBAction func PlayPauseTap(_ sender: UIButton) {
        MusicPlayer.instance.isPlaying ? MusicPlayer.instance.Pause() : MusicPlayer.instance.Play()
    }

    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let track = MusicPlayer.instance.playingMusic else { return}
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MusicViewController") as! MusicViewController
        vc.playingMusic = track
        mainTabBar.present(vc, animated: true, completion: nil)
    }

    
}
