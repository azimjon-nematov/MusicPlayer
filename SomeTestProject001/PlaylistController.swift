//
//  PlaylistController.swift
//  SomeTestProject001
//
//  Created by MacBook Pro on 01.10.2022.
//

import UIKit

class PlaylistController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var playlists: [PlaylistModel] = []
    var addingMusic: MusicModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataManager.getData(data: &playlists, key: DataManager.playlists)
        if playlists.count == 0 {
            playlists.insert(PlaylistModel.CreateFavorites(), at: 0)
        }
        
        self.collectionView.register(UINib(nibName: "PlaylistCell", bundle: nil), forCellWithReuseIdentifier: "PlaylistCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        if addingMusic != nil {
            title = "Выберите плейлист"
        } else {
            let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
            self.collectionView.addGestureRecognizer(lpgr)
        }
    }
    
    
    @IBAction func AddPlaylist(_ sender: UIBarButtonItem) {
        let addingAlert = UIAlertController(title: "Добавление плейлиста", message: nil, preferredStyle: .alert)
        addingAlert.addTextField(configurationHandler: nil)
        
        addingAlert.addAction(UIAlertAction(title: "Добавить", style: .default, handler: {_ in
            if let txt = addingAlert.textFields?.first?.text,
               !txt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            {
                self.playlists.append(PlaylistModel(name: txt))
                DataManager.setData(data: self.playlists, key: DataManager.playlists)
                self.collectionView.reloadData()
            }
        }))
        addingAlert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        self.present(addingAlert, animated: true)
    }
    
    
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let p = gestureRecognizer.location(in: self.collectionView)
            guard let indexPath = self.collectionView.indexPathForItem(at: p) else { return }
                
            let alert = UIAlertController(title: playlists[indexPath.item].name, message: nil, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Переименовать", style: .default) { _ in
                self.renamePlaylist(index: indexPath.item)
            })
            
            alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { _ in
                let track = self.playlists.remove(at: indexPath.item)
                DataManager.setData(data: self.playlists, key: DataManager.playlists)
                DataManager.setData(data: [MusicModel](), key: "playlist\(track.getID())")
                self.collectionView.reloadData()
            })
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        
        }
    }
    
    
    @objc func renamePlaylist(index : Int) {
        let editAlert = UIAlertController(title: "Радактировение плейлиста", message: nil, preferredStyle: .alert)
        editAlert.addTextField{ textField in
            textField.text = self.playlists[index].name
        }
        
        editAlert.addAction(UIAlertAction(title: "Редактировать", style: .default, handler: {_ in
            if let txt = editAlert.textFields?.first?.text, !txt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self.playlists[index].name = txt
                DataManager.setData(data: self.playlists, key: DataManager.playlists)
                self.collectionView.reloadData()
            }
        }))
        editAlert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        self.present(editAlert, animated: true)
    }
}






extension PlaylistController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count;
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaylistCell", for: indexPath) as! PlaylistCell
        cell.setupCell(playlistModel: self.playlists[indexPath.item])
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = UIScreen.main.bounds.width / 2.0 - 15
         return CGSize(width: size, height: size + 42.0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
  
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let track = self.addingMusic {
            
            var tracks: [MusicModel] = []
            DataManager.getData(data: &tracks, key: "playlist\(self.playlists[indexPath.item].getID())")
            if tracks.firstIndex(of: track) == nil {
                tracks.append(track)
                self.playlists[indexPath.item].musicCount += 1
                if self.playlists[indexPath.item].image != "noimage" && track.img != "noimage" {
                    self.playlists[indexPath.item].image = track.img
                }
                DataManager.setData(data: tracks, key: "playlist\(self.playlists[indexPath.item].getID())")
                DataManager.setData(data: playlists, key: DataManager.playlists)
                let alert = UIAlertController(title: "Трек добавлен", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel,  handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
                
            } else {
                let alert = UIAlertController(title: "Этот трек уже в плейлисте", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }
            
        } else {
            
            let trackListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TrackListVC") as! TrackListVC
            trackListVC.plist = String(self.playlists[indexPath.item].getID())
            trackListVC.title = playlists[indexPath.item].name
            self.navigationController?.pushViewController(trackListVC, animated: true)
            
        }
    }
}









//    @available(iOS 13.0, *)
//    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
//        return configureContextMenu()
//    }
//
//    @available(iOS 13.0, *)
//    func configureContextMenu() -> UIContextMenuConfiguration
//    {
//        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
//
//            let rename = UIAction(title: "Переименовать", image: nil, identifier: nil, discoverabilityTitle: nil, state: .off) { _ in
//                print("asdasdadadasdadasdasd")
//            }
//            let delete = UIAction(title: "Удалить", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off) { _ in
//                print("delete action")
//            }
//
//            return UIMenu(title: "what to do?", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [rename, delete])
//        }
//        return context
//    }
