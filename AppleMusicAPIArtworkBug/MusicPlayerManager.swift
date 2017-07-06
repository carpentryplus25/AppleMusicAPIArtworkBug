//
//  MusicPlayerManager.swift
//  DJ Central
//
//  Created by William Thompson on 6/17/17.
//  Copyright © 2017 J.W. Enterprises LLC. All rights reserved.
//

import UIKit
import MediaPlayer

class MusicPlayerManager: NSObject {
    
    static let didUpdateState = NSNotification.Name("didUpdateState")
    
    let musicPlayerController = MPMusicPlayerController.systemMusicPlayer()
    
    
    override init() {
        super.init()
        musicPlayerController.beginGeneratingPlaybackNotifications()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.handleMusicPlayerControllerNowPlayingItemDidChange), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: musicPlayerController)
        notificationCenter.addObserver(self, selector: #selector(handleMusicPlayerControllerPlaybackStateDidChange), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: musicPlayerController)
    }
    
    deinit {
        musicPlayerController.endGeneratingPlaybackNotifications()
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: musicPlayerController)
        notificationCenter.removeObserver(self, name: .MPMusicPlayerControllerPlaybackStateDidChange, object: musicPlayerController)
    }
    
    func beginPlayBack(itemCollection: MPMediaItemCollection) {
        musicPlayerController.setQueue(with: itemCollection)
        musicPlayerController.play()
    }
    
    func beginPlayback(itemId: String) {
        musicPlayerController.setQueueWithStoreIDs([itemId])
        musicPlayerController.play()
    }
    
    func togglePlayPause() {
        if musicPlayerController.playbackState == .playing {
            musicPlayerController.pause()
        }
        else {
            //musicPlayerController.setQueue(with: MPMediaQuery.songs())
            musicPlayerController.play()
        }
    }
    
    func skipToNextItem() {
        musicPlayerController.skipToNextItem()
    }
    
    func skipBackToBeginningOrPreviousItem() {
        if musicPlayerController.currentPlaybackTime < 5 {
            musicPlayerController.skipToPreviousItem()
        }
        else {
            musicPlayerController.skipToBeginning()
        }
    }
    
    @objc func handleMusicPlayerControllerNowPlayingItemDidChange() {
        NotificationCenter.default.post(name: MusicPlayerManager.didUpdateState, object: nil)
    }
    
    @objc func handleMusicPlayerControllerPlaybackStateDidChange() {
        NotificationCenter.default.post(name: MusicPlayerManager.didUpdateState, object: nil)
    }
    
    
    
    
    
    
}
