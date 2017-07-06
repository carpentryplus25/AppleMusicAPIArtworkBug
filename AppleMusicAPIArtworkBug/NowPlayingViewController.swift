//
//  NowPlayingViewController.swift
//  AppleMusicAPIArtworkBug
//
//  Created by William Thompson on 7/6/17.
//  Copyright © 2017 J.W.Enterprises LLC. All rights reserved.
//

import UIKit

class NowPlayingViewController: UIViewController {

    @IBOutlet weak var skipBackward: UIButton!
    @IBOutlet weak var skipForward: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var songArtistNameLabel: UILabel!
    @IBOutlet weak var songAlbumLabel: UILabel!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    var appleMusicManager = AppleMusicManager()
    var musicPlayerManager = MusicPlayerManager()
    lazy var authorizationManager: AuthorizationManager = {
        return AuthorizationManager(appleMusicManager: self.appleMusicManager)
    }()
    lazy var mediaLibraryManager: MediaLibraryManager = {
        return MediaLibraryManager(authorizationManager: self.authorizationManager)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorizationManager.requestMediaLibrayAuthorization()
        NotificationCenter.default.addObserver(self, selector: #selector(handleMusicPlayerDidUpdate), name: MusicPlayerManager.didUpdateState, object: nil)
        updateUserInterface()
        updatePlayButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        authorizationManager.requestCloudServiceCapabilities()
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playAction(_ sender: Any) {
        musicPlayerManager.togglePlayPause()
    }

    @IBAction func skipToNextAction(_ sender: Any) {
        musicPlayerManager.skipToNextItem()
    }
    
    @IBAction func skipToBeginningOrPrevousAction(_ sender: Any) {
        musicPlayerManager.skipBackToBeginningOrPreviousItem()
    }
    
    func updatePlayButton() {
        let playbackState = musicPlayerManager.musicPlayerController.playbackState
        switch playbackState {
        case .interrupted, .paused, .stopped:
            playPauseButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
        case .playing:
            playPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
        default:
            break
        }
        if playbackState == .stopped {
            skipForward.isEnabled = false
            skipBackward.isEnabled = false
            playPauseButton.isEnabled = false
        } else {
            skipForward.isEnabled = true
            skipBackward.isEnabled = true
            playPauseButton.isEnabled = true
        }
    }
    
    func updateUserInterface() {
        if let currentItem = musicPlayerManager.musicPlayerController.nowPlayingItem {
            artworkImageView.image = currentItem.artwork?.image(at: artworkImageView.frame.size)
            songAlbumLabel.text = currentItem.albumTitle
            songTitleLabel.text = currentItem.title
            songArtistNameLabel.text = currentItem.artist
        } else {
            artworkImageView.image = nil
            songArtistNameLabel.text = " "
            songTitleLabel.text = " "
            songAlbumLabel.text = " "
        }
    }
    
    func handleMusicPlayerDidUpdate() {
        DispatchQueue.main.async {
            self.updatePlayButton()
            self.updateUserInterface()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
