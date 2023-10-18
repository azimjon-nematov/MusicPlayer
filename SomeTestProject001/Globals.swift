//
//  Globals.swift
//  SomeTestProject001
//
//  Created by MacBook Pro on 16.10.2022.
//

import Foundation
import UIKit
import SDWebImage
import Alamofire

class Globals
{
    
    static let HOST = "https://mp3.tj"
    
    
    static var downloadsVC: TrackListVC!
    
    
    static var CurrentVC: UIViewController!
    
    
    static func isDownloaded(track: MusicModel) -> Bool
    {
        for item in Globals.downloadsVC.musics {
            if item == track { return true }
        }
        
        return false
    }
    
    
    static func getImage(img: String) -> UIImage
    {
        if img != "noimage" && img != "https://mp3.tj/img/noimage.jpg",
           let image = SDImageCache.shared.imageFromDiskCache(forKey: URL(string: img)?.absoluteString) {
            return image
        } else {
            return UIImage(named: "noimage")!
        }
    }
    
    
    static func donwloadTrack(track: MusicModel, _ complated: (()-> Void)? = nil, _ errorCase: (()-> Void)? = nil)
    {
        AF.request(Globals.HOST + "/top/system.php?action=get_media&id=" + track.id).response{ response in
            if let res = response.data,
               let json = try? JSONSerialization.jsonObject(with: res, options: []),
               let object = (json as? [Any])?.first as? [String:Any],
               let link = object["mp3"] as? String
            {
                let destination: DownloadRequest.Destination = { _, _ in
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let fileURL = documentsURL.appendingPathComponent("musuc\(track.id).mp3")

                    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                }
                AF.download((link.contains("http") ? "" : Globals.HOST ) + link, to: destination).response { response in
                    if response.error == nil, let filePath = response.fileURL?.path {
                        var donwloadedTrack = track
                        donwloadedTrack.isDownloaded = true
                        donwloadedTrack.filePath = filePath
                        downloadsVC.musics.append(donwloadedTrack)
                        DataManager.setData(data: downloadsVC.musics, key: DataManager.downloaded)
                        //downloadsVC.tableView.reloadData()
                        complated?()
                        print(filePath)
                    }
                    else {
                        errorCase?()
                        print(response.error ?? "error was nil!")
                    }
                }
            }
        }
    }
    
    
    static func readAllFiles() {
        do {
            let fileManager = FileManager()
            let documentsFolder = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            //let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filesInDirectory = try fileManager.contentsOfDirectory(atPath: documentsFolder.path)
            
            if filesInDirectory.count > 0 {
                for i in 0..<filesInDirectory.count{
                    print(filesInDirectory[i])
                }
            }
        } catch let error {
            print(error)
        }
    }
    
}
