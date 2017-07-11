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
    var imageManager = ImageManager()
    lazy var authorizationManager: AuthorizationManager = {
        return AuthorizationManager(appleMusicManager: self.appleMusicManager)
    }()
    lazy var mediaLibraryManager: MediaLibraryManager = {
        return MediaLibraryManager(authorizationManager: self.authorizationManager)
    }()
    var setterQueue = DispatchQueue(label: "NowPlayingViewController")
    var artwork: Artwork?
    var json: [String: Any] = [:]
    var mediaItem = [[MediaItem]]()
        
    
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
            guard let developerToken = appleMusicManager.fetchDeveloperToken() else {
                print("oops")
                return
            }
            artworkImageView.image = currentItem.artwork?.image(at: artworkImageView.frame.size)
            songAlbumLabel.text = currentItem.albumTitle
            songTitleLabel.text = currentItem.title
            songArtistNameLabel.text = currentItem.artist
            let searchTerm = songAlbumLabel.text
            let searchTypes = "albums"
            var searchURLComponents = URLComponents()
            searchURLComponents.scheme = "https"
            searchURLComponents.host = "api.music.apple.com"
            searchURLComponents.path = "/v1/catalog/"
            searchURLComponents.path += "\(authorizationManager.cloudServiceStoreFrontCountryCode)"
            searchURLComponents.path += "/search"
            searchURLComponents.queryItems = [
                URLQueryItem(name: "term", value: searchTerm),
                URLQueryItem(name: "types", value: searchTypes)
            ]
            var request = URLRequest(url: searchURLComponents.url!)
            request.httpMethod = "GET"
            request.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
            let dataTask = URLSession.shared.dataTask(with: request) {
                (data, response, error) in
                print(response!)
                if let searchData = data {
                    let results = try! self.appleMusicManager.processMediaItemSections(searchData)
                    self.mediaItem = results
                    let album = self.mediaItem[0][0]
                    let albumArtworkURL = album.artwork.imageUrl(self.artworkImageView.frame.size)
                    if let image = self.imageManager.cachedImage(url: albumArtworkURL) {
                        self.artworkImageView.image = image
                    }
                    else {
                        self.imageManager.fetchImage(url: albumArtworkURL) {(image) in
                            self.artworkImageView.image = image
                        }
                    }
                }
            }
            dataTask.resume()
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
