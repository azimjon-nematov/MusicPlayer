import Foundation


class DataManager
{
    
    static let playlists = "playlists"
    static let favorites = "favorites"
    static let downloaded = "downloaded"
    
    
    static func setData(data: [String], key: String) {
        UserDefaults.standard.set(data, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    
    static func setData<T: Encodable>(data: [T], key: String) {
        if let encodedData = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encodedData, forKey: key)
            UserDefaults.standard.synchronize()
        }
        else {
            print("error saving")
            
        }
    }
    
    
    static func getData<T: Decodable>(data: inout [T], key: String) {
        if let objects = UserDefaults.standard.value(forKey: key) as? Data {
            if let gettingData = try? JSONDecoder().decode(Array.self, from: objects) as [T] {
                data = gettingData
            }
            else {
                print("converting")
            }
        }
        else {
            print("error getting")
        }
    }
    
    
    static func deleteFile(fileName: String) {
        do {
            let fileManager = FileManager()
            let fileULR = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)
            
            try fileManager.removeItem(at: fileULR)
        }
        catch {
            print(error)
        }
    }
    
    
    
}
