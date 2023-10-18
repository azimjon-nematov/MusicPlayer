//
//  MusicCell.swift
//  SomeTestProject001
//
//  Created by MacBook Pro on 28.09.2022.
//

import UIKit

class MusicCell: UITableViewCell {

    
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Author: UILabel!
    @IBOutlet weak var Duration: UILabel!
    @IBOutlet weak var imageview: UIImageView!
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    func setupMusic(music: MusicModel)
    {
        self.Name.text = music.name
        self.Author.text = music.artist
        self.Duration.text = music.time
        self.tag = Int(music.id) ?? 0
        
        self.imageview.sd_setImage(with: URL(string: music.img), placeholderImage: UIImage(named: "noimage"))
    }

}
