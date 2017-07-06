//
//  MediaLibraryManager.swift
//  DJ Central
//
//  Created by William Thompson on 6/17/17.
//  Copyright © 2017 J.W. Enterprises LLC. All rights reserved.
//

import Foundation
import MediaPlayer

class MediaLibraryManager: NSObject {
    
    static let playlistUUIDKey = "playlistUUIDKey"
    static let libraryDidUpdate = Notification.Name("libraryDidUpdate")
    let authorizationManager: AuthorizationManager
    var mediaPlaylist: MPMediaPlaylist!
    
    init(authorizationManager: AuthorizationManager) {
        self.authorizationManager = authorizationManager
        super.init()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleAuthorizationManagerAuthorizationDidUpdateNotification), name: AuthorizationManager.authorizationDidUpdateNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleMediaLibraryDidChangeNotification), name: .MPMediaLibraryDidChange, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleMediaLibraryDidChangeNotification), name: .UIApplicationWillEnterForeground, object: nil)
        handleAuthorizationManagerAuthorizationDidUpdateNotification()
    }
    
    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: AuthorizationManager.authorizationDidUpdateNotification, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.MPMediaLibraryDidChange, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func createPlaylistIfNeeded() {
        guard mediaPlaylist == nil else {
            return
        }
        let playlistUUID: UUID
        var playlistCreationMetadata: MPMediaPlaylistCreationMetadata!
        let userDefaults = UserDefaults.standard
        if let playlistUUIDString = userDefaults.string(forKey: MediaLibraryManager.playlistUUIDKey) {
            guard let uuid = UUID(uuidString: playlistUUIDString) else {
                print("Failed to create UUID from existing UUID string: \(playlistUUIDString)")
                return
            }
            playlistUUID = uuid
        }
        else {
            playlistUUID = UUID()
            playlistCreationMetadata = MPMediaPlaylistCreationMetadata(name: "DJ-Central Playlist")
            playlistCreationMetadata.descriptionText = "This playlist was created using \(Bundle.main.infoDictionary!["CFBundleName"]!)"
            userDefaults.setValue(playlistUUID.uuidString, forKey: MediaLibraryManager.playlistUUIDKey)
            userDefaults.synchronize()
        }
        MPMediaLibrary.default().getPlaylist(with: playlistUUID, creationMetadata: playlistCreationMetadata) { (playlist, error) in
            guard error == nil else {
                print("An error occurred while retrieving/creating playlist: \(error!.localizedDescription)")
                return
            }
            self.mediaPlaylist = playlist
            NotificationCenter.default.post(name: MediaLibraryManager.libraryDidUpdate, object: nil)
        }
    }
    
    func addItem(with Identifier: String) {
        guard let mediaPlaylist = mediaPlaylist else {
            print("Playlist has not been created")
            return
        }
        mediaPlaylist.addItem(withProductID: Identifier, completionHandler: { (error) in
            guard error == nil else {
                print("An error occurred while adding an item to the playlist: \(error!.localizedDescription)")
                return
            }
            NotificationCenter.default.post(name: MediaLibraryManager.libraryDidUpdate, object: nil)
        })
    }
    
    @objc func handleAuthorizationManagerAuthorizationDidUpdateNotification() {
        if MPMediaLibrary.authorizationStatus() == .authorized {
            createPlaylistIfNeeded()
        }
    }
    
    @objc func handleMediaLibraryDidChangeNotification() {
        if MPMediaLibrary.authorizationStatus() == .authorized {
            createPlaylistIfNeeded()
        }
        NotificationCenter.default.post(name: MediaLibraryManager.libraryDidUpdate, object: nil)
    }
}
