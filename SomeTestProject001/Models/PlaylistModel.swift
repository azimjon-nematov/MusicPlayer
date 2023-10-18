import Foundation
import UIKit


struct PlaylistModel : Codable, Hashable
{
    
    private static var maxId = -1
    
    private var id: Int
    
    var name: String
    
    var image: String
    
    var musicCount: Int
    
    
    init() {
        self.id = -1
        self.name = "Unknown"
        self.image = "noimage"
        self.musicCount = 0
    }
    
    
    init(name: String) {
        self.id = PlaylistModel.CreateID()
        self.name = name
        self.image = "noimage"
        self.musicCount = 0
    }
    
    
    init(name: String, image: String, musicCount: Int) {
        self.id = PlaylistModel.CreateID()
        self.name = name
        self.image = image
        self.musicCount = musicCount
    }
    
    
    static func CreateID() -> Int {
        maxId += 1
        return maxId
    }
    
    
    static func CreateFavorites() -> PlaylistModel {
        var fav = self.init()
        fav.name = "Избранные"
        fav.id = 0
        if maxId == -1 { maxId = 0 }
        return fav
    }
    
    
    static func ==(lhs: PlaylistModel, rhs: PlaylistModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    func getID() -> Int {
        return id
    }
    
    
}
