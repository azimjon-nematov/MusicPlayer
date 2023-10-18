//
//  MainTabBarVC.swift
//  SomeTestProject001
//
//  Created by MacBook Pro on 03.10.2022.
//

import UIKit
import Alamofire

class MainTabBarVC: UITabBarController {

    static var miniPlayer: MiniPlayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let nav = ((self.viewControllers?.last) as? UINavigationController) {
            let trackListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TrackListVC") as! TrackListVC
            trackListVC.plist = "downloads"
            nav.viewControllers = [trackListVC]
            Globals.downloadsVC = trackListVC
            DataManager.getData(data: &trackListVC.musics, key: DataManager.downloaded)
        }
        
        MainTabBarVC.miniPlayer = MiniPlayer(tabBarVC: self)
    }

    
}

//viewControllers?.forEach {
   //$0.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
//}
