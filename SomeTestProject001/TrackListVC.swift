//
//  ViewController.swift
//  SomeTestProject001
//
//  Created by MacBook Pro on 27.09.2022.
//

import UIKit
import Fuzi
import Alamofire
import SDWebImage
import Foundation
import AVFoundation

class TrackListVC: UIViewController {
    
    var player: MusicPlayer = MusicPlayer.instance
    
    var plist = "popular"
    private var lastRequest = "/pop/top?"
    private var page = 1
    
    var hasNext = false
    var musics: [MusicModel] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var tableView: UITableView!
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTabBarAppearance()
        
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = navigationController!.navigationBar.barTintColor
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if(plist == "popular") {
            setSearchController()
            getFromSite(link: "/pop/top?")
        }
        else if plist == "downloads" {
            title = "Скаченные"            
        }
        else
        {
            DataManager.getData(data: &musics, key: "playlist\(plist)")
        }
        self.refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        self.refreshControl.tintColor = UIColor(hex: 0x3f3f3f)
        self.tableView.refreshControl = self.refreshControl
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        Globals.CurrentVC = self
    }
    
    
    @objc func refreshTableView(_ sender: Any) {
        self.refreshControl.endRefreshing()
        if(plist == "popular") {
            getFromSite(link: self.lastRequest)
        }
        else {
            musics.removeAll()
            DataManager.getData(data: &musics, key: plist == "downloads" ? DataManager.downloaded : "playlist\(plist)")
            tableView.reloadData()
        }
    }
    
    
    func setTabBarAppearance() {
        tabBarController?.tabBar.tintColor = UIColor(hex: 0x3f3f3f)
        tabBarController?.tabBar.unselectedItemTintColor = UIColor(hex: 0x808080)
    }
    
    
    func setSearchController() {
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.searchBar.sizeToFit()
        searchController.searchBar.returnKeyType = .search
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        self.navigationItem.searchController = searchController
    }
    
    
    func getNextFromSite(_ complated: (()-> Void)? = nil) {
        if !self.hasNext { return }
        AF.request(Globals.HOST + self.lastRequest + "&page=\(self.page + 1)").responseString { response in
            guard let res = response.value, let doc = try? HTMLDocument(string: res, encoding: String.Encoding.utf8) else {
                print("🔴pizdec")
                return
            }
            self.ExtractTracks(doc: doc)
            self.page = self.page + 1
            complated?()
        }
    }
    
    
    func getFromSite(link: String) {
        
        AF.request(Globals.HOST + link).responseString { response in
            guard let res = response.value, let doc = try? HTMLDocument(string: res, encoding: String.Encoding.utf8) else {
                print("🔴pizdec")
                return
            }
            self.musics.removeAll()
            self.tableView.reloadData()
            self.lastRequest = link
            self.page = 1
            self.ExtractTracks(doc: doc)
            self.player.playingIndex = nil
        }
        
        
    }
    
    
    func ExtractTracks(doc: HTMLDocument) {
        for anchor in doc.xpath("//div[@class='list-group-item']/article") {
            var track = MusicModel()
            track.img = Globals.HOST + (anchor.xpath("div[@class='pos-rlt pull-left m-r']/a/img").first?["src"] ?? "/img/noimage.jpg")

            let anch = anchor.xpath("div[@class='clear']").first
            track.name = anch?.xpath("a").first?.stringValue ?? "Unknown"
            track.id = String(anch?.xpath("a").first?["href"]?.split(separator: "/").last ?? "0")
            track.time = anch?.xpath("small").first?.stringValue ?? "00:00"
            track.artist = anch?.xpath("div/a").first?.stringValue ?? "Author"
            
            if Globals.isDownloaded(track: track) {
                track.isDownloaded = true
            }
            
            self.musics.append(track)
        }
        self.hasNext = doc.xpath("//a[@class='next page-numbers']").first != nil
        self.tableView.reloadData()
    }
    
    
}



extension TrackListVC: UISearchResultsUpdating
{
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let search = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        else { return }
        
        getFromSite(link: search == "" ? "/pop/top?" : "/index.php?do=poisk&s=" + search)
    }
    
}




extension TrackListVC: UITableViewDataSource, UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.musics.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "musicCell", for: indexPath) as! MusicCell
        cell.setupMusic(music: self.musics[indexPath.row])
        if self.player.playingMusic == self.musics[indexPath.row]
        {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            self.player.playingIndex = indexPath.row
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.player.OpenAndPlay(VC: self, index: indexPath.row)
        DispatchQueue.main.async {
            self.player.OpenAndPlay(VC: self, index: indexPath.row)
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if plist == "popular" && indexPath.row + 1 == self.musics.count {
            //self.getNextFromSite()
            DispatchQueue.main.async {
                self.getNextFromSite()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        
        let delete = UIContextualAction(style: .destructive, title: "Удалить") { _, _, _ in

            //self.tableView.deleteRows(at: [indexPath], with: .fade)
            
            if self.plist == "downloads" {
                let track = self.musics.remove(at: indexPath.row)
                DataManager.deleteFile(fileName: "musuc\(track.id).mp3")
                DataManager.setData(data: self.musics, key: DataManager.downloaded)
            } else {
                self.musics.remove(at: indexPath.row)
                DataManager.setData(data: self.musics, key: "playlist\(self.plist)")
                var playlists = [PlaylistModel]()
                DataManager.getData(data: &playlists, key: DataManager.playlists)
                for i in 0..<playlists.count {
                    if String(playlists[i].getID()) == self.plist {
                        playlists[i].musicCount -= 1
                        break
                    }
                }
                DataManager.setData(data: playlists, key: DataManager.playlists)
            }
            
            tableView.reloadData()
            tableView.reloadSections([0], with: .fade)
        }
        
        let addToPlaylist = UIContextualAction(style: .normal, title: "Добавить в плейлсит") { _, _, _ in
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlaylistController") as! PlaylistController
            vc.addingMusic = self.musics[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if self.plist == "popular" || self.plist == "downloads" {
            actions.append(addToPlaylist)
        }
        if self.plist != "popular" {
            actions.append(delete)
        }
        
        return UISwipeActionsConfiguration(actions: actions)
        
    }
    
    
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        if plist != "popular" {
//            return UISwipeActionsConfiguration(actions: [])
//        }
//
//
//        let addToPlaylist = UIContextualAction(style: .destructive, title: "Добавить в плейлсит") { _, _, _ in
//            
//            if self.plist == "downloads" {
//                let track = self.musics.remove(at: indexPath.row)
//                DataManager.deleteFile(fileName: "musuc\(track.id).mp3")
//                DataManager.setData(data: self.musics, key: DataManager.downloaded)
//            } else {
//                self.musics.remove(at: indexPath.row)
//                DataManager.setData(data: self.musics, key: "playlist\(self.plist)")
//                var playlists = [PlaylistModel]()
//                DataManager.getData(data: &playlists, key: DataManager.playlists)
//                for i in 0..<playlists.count {
//                    if String(playlists[i].getID()) == self.plist {
//                        playlists[i].musicCount -= 1
//                        break
//                    }
//                }
//                DataManager.setData(data: playlists, key: DataManager.playlists)
//
//            }
//        }
//
//        return UISwipeActionsConfiguration(actions: [addToPlaylist])
//
//    }
    
    
}



//DispatchQueue.main.asyncAfter(deadline: .now()+2) {
    //let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "secondVC")
    //self.navigationController?.pushViewController(vc, animated: true)
//}
