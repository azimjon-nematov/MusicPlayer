
import Foundation


struct MusicModel : Codable, Hashable
{
    
    var id: String
    
    var name: String
    
    var artist: String
    
    var time: String
    
    var img: String
    
    var isDownloaded = false
    
    var filePath: String = ""
    
    init() {
        id = ""
        name = ""
        artist = ""
        time = ""
        img = ""
    }
    
    
    static func ==(lhs: MusicModel, rhs: MusicModel) -> Bool {
        return lhs.id == rhs.id
    }
    
}
