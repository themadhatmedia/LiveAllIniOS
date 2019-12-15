class SongList {
    var title = ""
    var audioPath = ""
    var audioUrl = ""
    var imagePath = ""
    var imageUrl = ""
    var plan_name: [String] = []
    var releaseDate = ""
    var songType = 0
    var downloadedPath = ""
    var downloadedImagePath = ""
    
    init(title:String, audioPath:String, audioUrl:String, imagePath: String, imageUrl: String, plan_name: [String], releaseDate: String, songType:Int, downloadedPath: String, downloadedImagePath:String ) {
        self.title = title
        self.audioPath = audioPath
        self.audioUrl = audioUrl
        self.imagePath = imagePath
        self.imageUrl = imageUrl
        self.plan_name = plan_name
        self.releaseDate = releaseDate
        self.songType = songType
        self.downloadedPath = downloadedPath
        self.downloadedImagePath = downloadedImagePath
    }
}
