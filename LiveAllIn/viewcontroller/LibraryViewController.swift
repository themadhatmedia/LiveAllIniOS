//
//  LibraryViewController.swift
//  LiveAllIn
//
//  Created by madhatmedia on 20/11/2019.
//  Copyright © 2019 madhatmedia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import SwiftKeychainWrapper
import AVFoundation

var playerItems: [AVPlayerItem] = []

var currentIndex = 0
var actualLocalSongList : [SongList] = []

class LibraryViewController: UIViewController,
    UITableViewDataSource,
    UITableViewDelegate  {
    
    @IBOutlet weak var tableView: UITableView!

    var downloadedSongList : [SongList] = []
    var instrumentalSongList : [SongList] = []
    var backgroundSongList : [SongList] = []
    var christmasSongList : [SongList] = []
    var availableSongList : [SongList] = []
    var storedSongList : [SongList] = []
    
    var sections = [SectionHeader]()
    var plans: [String] = []
    var userEmail: String = ""
    
    var db: Firestore!
    var store: Storage!
    var storeRef: StorageReference!
    
    var loadingAlert:UIAlertController?
    var loadingIndicator:UIActivityIndicatorView?
    
    private var listener : ListenerRegistration!
    
    deinit {
        print("released lib")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userEmail = KeychainWrapper.standard.string(forKey: KeychainString.userEmail) ?? ""
        //initializeFirebase()
        print("viewDidLoad")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupLoading()
        initializeFirebase()
        
        print("viewDidAppear")
    }
    
    func setupLoading(){
        loadingAlert = UIAlertController(title: nil, message: "Loading songs...", preferredStyle: .alert)
        
        loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator?.hidesWhenStopped = true
        loadingIndicator?.style = UIActivityIndicatorView.Style.gray
        loadingIndicator?.startAnimating();
        do {
            try loadingAlert!.view.addSubview(loadingIndicator!)
        } catch let error {
            print("error: \(error)")
            
            dismissAlert()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.listener.remove()
        loadingAlert?.dismiss(animated: false, completion: nil)
        loadingAlert = nil
        
        print("lib disappear")
    }
    
    func initializeFirebase() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        store = Storage.storage()
        storeRef = store.reference()
        
        if Auth.auth().currentUser == nil {

        } else {
            getUserProfile(userEmail: userEmail)
        }
    }

    func getUserProfile(userEmail: String) {
        loadingOverlay()
            db.collection(FirebaseCollection.Users)
            .document(userEmail).getDocument { (document, error) in
            if let document = document, document.exists {
                
                //self.dismissAlert()
                
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                
                //print("Document data: \(dataDescription)")
                self.plans = document.data()?["planName"] as! [String]
                 //self.plans = document.data()?["planName"] as! String
                self.checkDownloadSongs()
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func loadingOverlay() {
        DispatchQueue.main.async {
            self.tableView.allowsSelection = true
            self.present(self.loadingAlert!, animated: false, completion: nil)
        }
    }
    
    func downloadingOverlay(){
        loadingAlert = UIAlertController(title: nil, message: "Downloading song...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        DispatchQueue.main.async {
            self.loadingAlert?.view.addSubview(loadingIndicator)
            self.tableView.allowsSelection = true
            self.present(self.loadingAlert!, animated: true, completion: nil)
        }
    }
    
    func dismissAlert() {
        DispatchQueue.main.async {
            self.loadingAlert?.dismiss(animated: false, completion: nil)
        }
    }
    
    func checkDownloadSongs(){
        
        if UserDefaults.standard.object(forKey: "encodedData") != nil {
            let decoded = UserDefaults.standard.object(forKey: "encodedData") as! Data
            let decodedSongs = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Song]
            
            playerItems = []
            downloadedSongList = []
            instrumentalSongList = []
            backgroundSongList = []
            christmasSongList = []
            actualLocalSongList = []
            
            for dec in decodedSongs {
                let title = dec.title
                let audioPath = dec.audioPath
                let imageUrl = dec.imageUrl
                let releaseDate = dec.releaseDate
                let downloadedPath = dec.downloadedPath
                let downloadedImagePath = dec.downloadedImagePath
                let songType = dec.songType
                let email = dec.email
                let audioUrl = ""
                let imagePath = ""
                let plan_name = [String]()
                
                
                print("title: \(title)")
                print("email: \(email)")
                print("downloadedImagePath: \(downloadedImagePath)")
                
                storedSongList += [SongList(title: title, audioPath: audioPath, audioUrl: audioUrl, imagePath: imagePath, imageUrl: imageUrl,plan_name: plan_name,releaseDate: releaseDate, songType: songType, downloadedPath:downloadedPath, downloadedImagePath:downloadedImagePath, email:email)]
                
                if self.userEmail.elementsEqual(email) {
                    switch(songType) {
                    case 0:
                        if !downloadedSongList.contains(where: { $0.title == title }) {
                            downloadedSongList += [SongList(title: title, audioPath: audioPath, audioUrl: audioUrl, imagePath: imagePath, imageUrl: imageUrl,plan_name: plan_name,releaseDate: releaseDate, songType: songType, downloadedPath:downloadedPath, downloadedImagePath:downloadedImagePath, email:email)]
                        }
                        break
                    case 1:
                        if !instrumentalSongList.contains(where: { $0.title == title }) {
                            instrumentalSongList += [SongList(title: title, audioPath: audioPath, audioUrl: audioUrl, imagePath: imagePath, imageUrl: imageUrl,plan_name: plan_name,releaseDate: releaseDate, songType: songType, downloadedPath:downloadedPath, downloadedImagePath:downloadedImagePath, email:email)]
                        }
                        break
                    case 2:
                        if !backgroundSongList.contains(where: { $0.title == title }) {
                            backgroundSongList += [SongList(title: title, audioPath: audioPath, audioUrl: audioUrl, imagePath: imagePath, imageUrl: imageUrl,plan_name: plan_name,releaseDate: releaseDate, songType: songType, downloadedPath:downloadedPath,downloadedImagePath:downloadedImagePath, email:email)]
                        }
                        break
                    case 3:
                        if !christmasSongList.contains(where: { $0.title == title }) {
                            christmasSongList += [SongList(title: title, audioPath: audioPath, audioUrl: audioUrl, imagePath: imagePath, imageUrl: imageUrl,plan_name: plan_name,releaseDate: releaseDate, songType: songType, downloadedPath:downloadedPath,downloadedImagePath:downloadedImagePath, email:email)]
                        }
                        break
                    default:
                        if !downloadedSongList.contains(where: { $0.title == title }) {
                            downloadedSongList += [SongList(title: title, audioPath: audioPath, audioUrl: audioUrl, imagePath: imagePath, imageUrl: imageUrl,plan_name: plan_name,releaseDate: releaseDate, songType: songType, downloadedPath:downloadedPath,downloadedImagePath:downloadedImagePath, email:email)]
                        }
                        break
                    }
                }
            }
            getSongList()
        } else {
            print("There is an issue")
            getSongList()
        }
    }
    
    func getSongList() {
        
        if downloadedSongList.count > 0 {
            for song in downloadedSongList {
                if !actualLocalSongList.contains(where: { $0.title == song.title }) {
                    actualLocalSongList += [SongList(title: song.title, audioPath: song.audioPath, audioUrl: song.audioUrl, imagePath: song.imagePath, imageUrl: song.imageUrl,plan_name: song.plan_name,releaseDate: song.releaseDate, songType: song.songType, downloadedPath:song.downloadedPath,downloadedImagePath:song.downloadedImagePath, email:song.email)]
                }
            }
        }
        
        if instrumentalSongList.count > 0 {
            for song in instrumentalSongList {
                if !actualLocalSongList.contains(where: { $0.title == song.title }) {
                    actualLocalSongList += [SongList(title: song.title, audioPath: song.audioPath, audioUrl: song.audioUrl, imagePath: song.imagePath, imageUrl: song.imageUrl,plan_name: song.plan_name,releaseDate: song.releaseDate, songType: song.songType, downloadedPath:song.downloadedPath,downloadedImagePath:song.downloadedImagePath, email:song.email)]
                }
            }
        }
        
        if backgroundSongList.count > 0 {
            for song in backgroundSongList {
                if !actualLocalSongList.contains(where: { $0.title == song.title }) {
                    actualLocalSongList += [SongList(title: song.title, audioPath: song.audioPath, audioUrl: song.audioUrl, imagePath: song.imagePath, imageUrl: song.imageUrl,plan_name: song.plan_name,releaseDate: song.releaseDate, songType: song.songType, downloadedPath:song.downloadedPath,downloadedImagePath:song.downloadedImagePath, email:song.email)]
                }
            }
        }
        
        if christmasSongList.count > 0 {
            for song in christmasSongList {
                if !actualLocalSongList.contains(where: { $0.title == song.title }) {
                    actualLocalSongList += [SongList(title: song.title, audioPath: song.audioPath, audioUrl: song.audioUrl, imagePath: song.imagePath, imageUrl: song.imageUrl,plan_name: song.plan_name,releaseDate: song.releaseDate, songType: song.songType, downloadedPath:song.downloadedPath,downloadedImagePath:song.downloadedImagePath, email:song.email)]
                }
            }
        }
        
        if actualLocalSongList.count > 0 {
            for song in actualLocalSongList {
                let songURL = URL(string: song.downloadedPath)
                
                let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                let destinationFileUrl = documentsUrl!.appendingPathComponent(songURL!.lastPathComponent)
                
                playerItems.append(AVPlayerItem(url: destinationFileUrl))
            }
        }
        
        self.listener = db.collection(FirebaseCollection.SongsList)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                self.availableSongList = []
                
                if document.documents.count != 0 {
                    for document in document.documents {
                        let title = document.get("title") as! String
                        let audioPath = document.get("audioPath") as! String
                        let audioUrl = document.get("audioUrl") as! String
                        let imagePath = document.get("imagePath") as! String
                        let imageUrl = document.get("imageUrl") as! String
                        let plan_name = document.get("plan_name") as! [String]
                        let releaseDate = document.get("releaseDate") as! String
                        let songType = document.get("songType") as! Int
                        
//                        if plan_name.contains(self.plans) {
//                            if !self.downloadedSongList.contains(where: { $0.title == title }) {
//                                if !self.instrumentalSongList.contains(where: { $0.title == title }) {
//                                    if !self.backgroundSongList.contains(where: { $0.title == title }) {
//                                        if !self.christmasSongList.contains(where: { $0.title == title }) {
//                                            self.availableSongList += [SongList(title: title, audioPath: audioPath, audioUrl:audioUrl, imagePath:imagePath, imageUrl:imageUrl,plan_name:plan_name,releaseDate:releaseDate, songType:songType, downloadedPath:"",downloadedImagePath:"")]
//                                        }
//                                    }
//                                }
//                            }
//                        }
                        
                        
                        for plan in self.plans {
                            if plan_name.contains(plan) {
                                if !self.downloadedSongList.contains(where: { $0.title == title }) {
                                    if !self.instrumentalSongList.contains(where: { $0.title == title }) {
                                        if !self.backgroundSongList.contains(where: { $0.title == title }) {
                                            if !self.christmasSongList.contains(where: { $0.title == title }) {
                                                self.availableSongList += [SongList(title: title, audioPath: audioPath, audioUrl:audioUrl, imagePath:imagePath, imageUrl:imageUrl,plan_name:plan_name,releaseDate:releaseDate, songType:songType, downloadedPath:"",downloadedImagePath:"", email: "")]
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        
                        self.availableSongList  = self.availableSongList.sorted(by: { $0.title < $1.title })

                        self.sections = [SectionHeader(sectionName:"Downloaded Songs", songs:self.downloadedSongList),
                                         SectionHeader(sectionName:"Instrumental", songs:self.instrumentalSongList),
                                         SectionHeader(sectionName:"Intrumental with Background Vocals", songs:self.backgroundSongList),
                                         SectionHeader(sectionName:"Christmas Songs", songs:self.christmasSongList),
                                         SectionHeader(sectionName:"Available Songs", songs:self.availableSongList)]
                        DispatchQueue.main.async {
                            self.tableView.allowsSelection = true
                            self.tableView.reloadData()
                            self.dismissAlert()
                        }
                    }
                } else {
                    self.dismissAlert()
                }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items = self.sections[section].songs
        return items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let numberOfRows = self.sections[section].songs.count
        if numberOfRows == 0 {
            return ""
        } else {
            return self.sections[section].sectionName
        }
    }
    
    private func tableView (tableView:UITableView , heightForHeaderInSection section:Int) -> Float {
        let title = self.tableView(tableView, titleForHeaderInSection: section)
        if title == "" {
            return 0.0
        }
        
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        weak var cell = tableView.dequeueReusableCell(withIdentifier: "LibraryTableViewCell", for: indexPath) as! LibraryTableViewCell
        
        if self.sections[indexPath.section].sectionName.elementsEqual("Available Songs") {
            
            let items = self.sections[indexPath.section].songs
            
            if items.count > 0 {
                cell?.songTitle?.text = items[indexPath.row].title
            }
            cell?.getLabel.isHidden = false
        } else {
            let items = self.sections[indexPath.section].songs
            
            if items.count > 0 {
                cell?.songTitle?.text = items[indexPath.row].title
            }
        
            cell?.getLabel.isHidden = true
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.allowsSelection = false
        
        if self.sections[indexPath.section].sectionName.elementsEqual("Available Songs") {
            let items = self.sections[indexPath.section].songs
            
            if items.count > 0 {
                downloadFromURL(song: items[indexPath.row])
            }
        } else {
            let items = self.sections[indexPath.section].songs
            
            currentIndex = indexPath.row
            
            if indexPath.section == 1 {
                currentIndex = self.sections[0].songs.count + indexPath.row
            } else if indexPath.section == 2 {
               currentIndex = self.sections[0].songs.count + self.sections[1].songs.count + indexPath.row
            } else if indexPath.section == 3 {
                currentIndex = self.sections[0].songs.count + self.sections[1].songs.count + self.sections[2].songs.count +  indexPath.row
            }
            
            DispatchQueue.main.async {
                weak var musicViewController = self.storyboard?.instantiateViewController(withIdentifier: "MusicPlayerViewController") as? MusicPlayerViewController
                self.present(musicViewController!, animated: false)
            }
        }
    }
    
    func downloadFromURL(song: SongList) {
        downloadingOverlay()
    
        let songURL = URL(string: song.audioUrl)
        let imageURLDownloadURL = URL(string: song.imageUrl)
        
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let songDestination = documentsUrl!.appendingPathComponent(songURL!.lastPathComponent)
        
        let imageDestination = documentsUrl!.appendingPathComponent(imageURLDownloadURL!.lastPathComponent)
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let songRequest = URLRequest(url:songURL!)
        let imageRequest = URLRequest(url:imageURLDownloadURL!)
        
        let songTask = session.downloadTask(with: songRequest) { (tempLocalSongUrl, response, error) in
            if let tempLocalSongUrl = tempLocalSongUrl, error == nil {
                if let statusSongCode = (response as? HTTPURLResponse)?.statusCode {
                    //print("Successfully downloaded song. Status code: \(statusSongCode)")
                    do {
                        try FileManager.default.copyItem(at: tempLocalSongUrl, to: songDestination)
                        //print("songDestination: \(songDestination)")
                        
                        let imageDownloadTask = session.downloadTask(with: imageRequest) { (tempLocalImageUrl, response, error) in
                            if let tempLocalImageUrl = tempLocalImageUrl, error == nil {
                                if let statusImageCode = (response as? HTTPURLResponse)?.statusCode {
                                    //print("Successfully downloaded image. Status code: \(statusImageCode)")
                                    
                                    do {
                                        try FileManager.default.copyItem(at: tempLocalImageUrl, to: imageDestination)
                                        //print("imageDestination: \(imageDestination)")
                                        
                                        DispatchQueue.main.async {
                                            self.dismissAlert()
                                        }
                                        
                                        var songsIn = [Song.init(title: song.title, audioPath:song.audioPath, downloadedPath:"\(songDestination)",downloadedImagePath:"\(imageDestination)", imageUrl: song.imageUrl, releaseDate:song.releaseDate, songType:song.songType, email:self.userEmail)]
                                        
                                        for innserSong in self.storedSongList {
                                            songsIn.append(Song.init(title:innserSong.title, audioPath:innserSong.audioPath, downloadedPath:innserSong.downloadedPath, downloadedImagePath:innserSong.downloadedImagePath, imageUrl: innserSong.imageUrl, releaseDate:innserSong.releaseDate, songType:innserSong.songType, email:innserSong.email))
                                        }
                                        
                                        playerItems = []
                                        
                                        let encoded = NSKeyedArchiver.archivedData(withRootObject: songsIn)
                                        UserDefaults.standard.set(encoded, forKey: "encodedData")
                                        
                                        self.checkDownloadSongs()
                                    } catch (let writeError) {
                                        print("Error creating a file \(songDestination) : \(writeError)")
                                    }
                                }
                            } else {}
                        }
                        imageDownloadTask.resume()
                    } catch (let writeError) {
                        print("Error creating a file \(songDestination) : \(writeError)")
                    }
                }
            } else {}
        }
        songTask.resume()
    }
}
