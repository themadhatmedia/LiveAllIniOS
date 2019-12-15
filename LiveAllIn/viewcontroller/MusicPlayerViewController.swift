//
//  MusicPlayerViewController.swift
//  LiveAllIn
//
//  Created by madhatmedia on 29/11/2019.
//  Copyright © 2019 madhatmedia. All rights reserved.
//

import UIKit
import AVFoundation

class MusicPlayerViewController: UIViewController {
    
    @IBOutlet weak var songImage: UIImageView!
    
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var nextButt: UIButton!
    @IBOutlet weak var previousButt: UIButton!
    
    var audioQueue: AVQueuePlayer?
    var loadingAlert: UIAlertController?
    
    var audioQueueObserver: NSKeyValueObservation?
    var audioSession: AVAudioSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if playerItems.count > 0 {
        audioQueue = AVQueuePlayer(items: playerItems)
        
        for _ in 0..<currentIndex {
           audioQueue?.advanceToNextItem()
        }
            
        audioQueue?.play()
        
        playButton.isHidden = true
        pauseButton.isHidden = false
        
        audioSession = AVAudioSession.sharedInstance()
        //self.loadingOverlay()
        
        do {
            try audioSession?.setCategory(AVAudioSession.Category.playback)
        } catch {
            print(error)
        }
        
        let imageString = actualLocalSongList[currentIndex].downloadedImagePath
            
        songImage.image = getImageFromDirectory(imageString)
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // Change `2.0`
            self.backButton.isEnabled = true
        }
            
        playerObserver()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func getImageFromDirectory(_ imageName: String) -> UIImage? {
        let imageURl = URL(string: imageName)
        
        if let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsUrl.appendingPathComponent(imageURl!.lastPathComponent)
            do {
                let imageData = try Data(contentsOf: fileURL)
                return UIImage(data: imageData)
            } catch {
                print("Not able to load image")
            }
        }
        return nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        print("playerItems.removeAll() \(playerItems.count)")
        playerItems.removeAll()
        print("playerItems.removeAll() \(playerItems.count)")
        self.dismiss(animated: true, completion: nil)
    }
    
    func playerObserver(){
        self.audioQueueObserver = self.audioQueue?.observe(\.currentItem, options: [.new]) {
            [weak self] (player, _) in
            
            self!.songImage.image = UIImage(named: "")
            
            print("media item changed...")
            
            currentIndex+=1
        
            if currentIndex <= actualLocalSongList.count-1 {
                let imageString =  actualLocalSongList[currentIndex].downloadedImagePath
                
                //print("imageString: \(imageString)")
                self!.songImage.image = self!.getImageFromDirectory(imageString)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0`
                self!.dismissAlert()
            }
        }
    }
    
    func loadingOverlay(){
        loadingAlert = UIAlertController(title: nil, message: "Playing song...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        self.loadingAlert!.view.addSubview(loadingIndicator)
        
        DispatchQueue.main.async {
            self.present(self.loadingAlert!, animated: true, completion: nil)
        }
    }
    
    func dismissAlert() {
        DispatchQueue.main.async {
            self.loadingAlert?.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func previousAction(_ sender: Any) {
        if currentIndex != 0 {
            loadingAlert = nil
            currentIndex=currentIndex-1
            controlAction()
        }
    }
    
    deinit {
        print("released music")
    }
    
    func controlAction(){
        audioQueue?.pause()
        
        loadingOverlay()
        resetPlayerItems()
        
        for _ in 0..<currentIndex {
            audioQueue?.advanceToNextItem()
        }
        
        let imageString =  actualLocalSongList[currentIndex].downloadedImagePath
        
        songImage.image = getImageFromDirectory(imageString)
        
        audioQueue?.play()
        playerObserver()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dismissAlert()
        }
    }
    
    @IBAction func pauseAction(_ sender: Any) {
        audioQueue?.pause()
        playButton.isHidden = false
        pauseButton.isHidden = true
    }
    
    @IBAction func playAction(_ sender: Any) {
        audioQueue?.play();
        playButton.isHidden = true
        pauseButton.isHidden = false
    }
  
    @IBAction func nextAction(_ sender: Any) {
        loadingAlert = nil
        if currentIndex < actualLocalSongList.count-1 {
            currentIndex=currentIndex+1
            
            controlAction()
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        audioQueue?.pause()
        audioQueue = nil
        loadingAlert = nil
        audioQueueObserver = nil
        audioSession = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    func resetPlayerItems() {
        playerItems.removeAll()
        
        print("reset_playerItems \(playerItems.count)")
        
        audioQueue = nil
        
        if actualLocalSongList.count > 0 {
            for song in actualLocalSongList {
                let songURL = URL(string: song.downloadedPath)
                
                let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                let destinationFileUrl = documentsUrl!.appendingPathComponent(songURL!.lastPathComponent)
                
                playerItems.append(AVPlayerItem(url: destinationFileUrl))
            }
        }
        
        audioQueue = AVQueuePlayer(items: playerItems)
    }
    
    func addDidFinishObserver() {
        audioQueue?.items().forEach { item in
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        }
    }
    
    func removeDidFinishObserver() {
        audioQueue?.items().forEach { item in
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        if audioQueue?.currentItem == audioQueue?.items().last {
            print("last item finished")
        } else {
            print("item \(currentIndex) finished")
            currentIndex += 1
        }
    }
}
