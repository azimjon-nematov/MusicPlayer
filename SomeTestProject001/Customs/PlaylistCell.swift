//
//  PlaylistCell.swift
//  SomeTestProject001
//
//  Created by MacBook Pro on 01.10.2022.
//

import UIKit
import SDWebImage

class PlaylistCell: UICollectionViewCell {

    @IBOutlet weak var playlistImage: UIImageView!
    @IBOutlet weak var playlistName: UILabel!
    @IBOutlet weak var playlistMusicCount: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    func setupCell(playlistModel: PlaylistModel) {
        playlistImage.image = Globals.getImage(img: playlistModel.image)
        playlistName.text = playlistModel.name
        playlistMusicCount.text = "musics \(playlistModel.musicCount)"
    }
    
    
}
