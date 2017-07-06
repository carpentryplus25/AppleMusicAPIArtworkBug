//
//  SearchAppleMusicViewController.swift
//  AppleMusicAPIArtworkBug
//
//  Created by William Thompson on 7/6/17.
//  Copyright © 2017 J.W.Enterprises LLC. All rights reserved.
//

import UIKit

class SearchAppleMusicViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let appleMusicManager = AppleMusicManager()
    let imageManager = ImageManager()
    
    var searchController = UISearchController(searchResultsController: nil)
    var musicPlayerManager: MusicPlayerManager!
    var mediaLibraryManager: MediaLibraryManager!
    var authorizationManager: AuthorizationManager!
    var setterQueue = DispatchQueue(label: " SearchAppleMusicTableViewController")
    var mediaItems = [[MediaItem]]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        tableView.tableHeaderView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleAuthorizationManagerAuthorizationDidUpdateNotification), name: AuthorizationManager.authorizationDidUpdateNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleAuthorizationManagerAuthorizationDidUpdateNotification), name: .UIApplicationWillEnterForeground, object: nil)
        authorizationManager = AuthorizationManager(appleMusicManager: appleMusicManager)
        musicPlayerManager = MusicPlayerManager()
        mediaLibraryManager = MediaLibraryManager(authorizationManager: authorizationManager)
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaItems[section].count
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return mediaItems.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("Songs", comment: "Songs")
        } else {
            return NSLocalizedString("Albums", comment: "Albums")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchAppleMusicTableViewCell.identifier, for: indexPath) as? SearchAppleMusicTableViewCell else {return UITableViewCell() }
        let mediaItem = mediaItems[indexPath.section][indexPath.row]
        cell.mediaItem = mediaItem
        cell.delegate = self
        let imageUrl = mediaItem.artwork.imageUrl(CGSize(width: 90, height: 90))
        if let image = imageManager.cachedImage(url: imageUrl) {
            cell.albumArtworkImageView.image = image
            cell.albumArtworkImageView.alpha = 1
        }
        else {
            cell.albumArtworkImageView.alpha = 0
            imageManager.fetchImage(url: imageUrl, completion: {(image) in
                if (cell.mediaItem?.identifier ?? "") == mediaItem.identifier {
                    cell.albumArtworkImageView.image = image
                    UIView.animate(withDuration: 0.3) {
                        cell.albumArtworkImageView.alpha = 1
                    }
                }
            })
        }
        let cloudServiceCapabilities = authorizationManager.cloudServiceCapabilities
        if cloudServiceCapabilities.contains(.addToCloudMusicLibrary) {
            cell.addToPlaylistButton.isEnabled = true
        }
        else {
            cell.addToPlaylistButton.isEnabled = false
        }
        if cloudServiceCapabilities.contains(.musicCatalogPlayback) {
            cell.playButton.isEnabled = true
        }
        else {
            cell.playButton.isEnabled = false
        }
        return cell
    }
    
    func handleAuthorizationManagerAuthorizationDidUpdateNotification() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
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

extension SearchAppleMusicViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchString = searchController.searchBar.text else {
            return
        }
        if searchString == "" {
            self.setterQueue.sync {
                self.mediaItems = []
            }
        } else {
            appleMusicManager.performAppleMusicCatalogSearch(with: searchString, countryCode: authorizationManager.cloudServiceStoreFrontCountryCode, completion: { [weak self] (searchResults, error) in
                guard error == nil else {
                    self?.setterQueue.sync {
                        self?.mediaItems = []
                    }
                    let alertController: UIAlertController
                    guard let error = error as NSError?, let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? Error else {
                        alertController = UIAlertController(title: "Error", message: "Encountered unexpected error", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                        DispatchQueue.main.async {
                            self?.present(alertController, animated: true, completion: nil)
                        }
                        return
                    }
                    alertController = UIAlertController(title: "Error", message: underlyingError.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    DispatchQueue.main.async {
                        self?.present(alertController, animated: true, completion: nil)
                    }
                    return
                }
                self?.setterQueue.sync {
                    self?.mediaItems = searchResults
                }
            })
        }
    }
}

extension SearchAppleMusicViewController : UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        setterQueue.sync {
            self.mediaItems = []
        }
    }
    
}

extension SearchAppleMusicViewController: SearchAppleMusicTableViewCellDelegate {
    func searchAppleMusicTableViewCell(_ searchAppleMusicTableViewCell: SearchAppleMusicTableViewCell, addToPlaylist mediaItem: MediaItem) {
        mediaLibraryManager.addItem(with: mediaItem.identifier)
    }
    
    func searchAppleMusicTableViewCell(_ searchAppleMusicTableViewCell: SearchAppleMusicTableViewCell, playMediaItem mediaItem: MediaItem) {
        musicPlayerManager.beginPlayback(itemId: mediaItem.identifier)
    }
    
}




