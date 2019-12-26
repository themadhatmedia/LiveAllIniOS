//
//  Song.swift
//  LiveAllIn
//
//  Created by madhatmedia on 30/11/2019.
//  Copyright © 2019 madhatmedia. All rights reserved.
//

import Foundation

class Song: NSObject, NSCoding {
    
    var title:String
    var audioPath:String
    var imageUrl:String
    var releaseDate:String
    var downloadedPath:String
    var downloadedImagePath:String
    var songType:Int
    var email:String
    
    init(title: String, audioPath: String, downloadedPath:String, downloadedImagePath:String, imageUrl: String, releaseDate: String, songType: Int, email:String) {
        self.title = title
        self.audioPath = audioPath
        self.downloadedPath = downloadedPath
        self.downloadedImagePath = downloadedImagePath
        self.imageUrl = imageUrl
        self.releaseDate = releaseDate
        self.songType = songType
        self.email = email
    }
    
    required convenience init(coder aCoder: NSCoder) {
        let title = aCoder.decodeObject(forKey: "title") as! String
        let audioPath = aCoder.decodeObject(forKey: "audioPath") as! String
        let downloadedPath = aCoder.decodeObject(forKey: "downloadedPath") as! String
        let downloadedImagePath = aCoder.decodeObject(forKey: "downloadedImagePath") as! String
        let imageUrl = aCoder.decodeObject(forKey: "imageUrl") as! String
        let releaseDate = aCoder.decodeObject(forKey: "releaseDate") as! String
        let songType = aCoder.decodeInteger(forKey: "songType")
        let email = aCoder.decodeObject(forKey: "email") as! String
        
        
        self.init(title: title, audioPath:audioPath, downloadedPath:downloadedPath, downloadedImagePath:downloadedImagePath, imageUrl:imageUrl, releaseDate:releaseDate,songType:songType, email:email)
    }
    
    func encode(with acoder: NSCoder) {
        acoder.encode(title,forKey: "title")
        acoder.encode(audioPath,forKey: "audioPath")
        acoder.encode(downloadedPath,forKey: "downloadedPath")
        acoder.encode(downloadedImagePath,forKey: "downloadedImagePath")
        acoder.encode(imageUrl,forKey: "imageUrl")
        acoder.encode(releaseDate,forKey: "releaseDate")
        acoder.encode(songType,forKey: "songType")
        acoder.encode(email,forKey: "email")
    }
}
