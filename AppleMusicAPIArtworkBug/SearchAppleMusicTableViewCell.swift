//
//  SearchAppleMusicTableViewCell.swift
//  AppleMusicAPIArtworkBug
//
//  Created by William Thompson on 7/6/17.
//  Copyright © 2017 J.W.Enterprises LLC. All rights reserved.
//

import UIKit

class SearchAppleMusicTableViewCell: UITableViewCell {

    static let identifier = "SearchAppleMusicTableViewCell"
    
    @IBOutlet weak var albumArtworkImageView: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var addToPlaylistButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    weak var delegate: SearchAppleMusicTableViewCellDelegate?
    var mediaItem: MediaItem? {
        didSet {
            songTitleLabel.text = mediaItem?.name ?? ""
            songArtistLabel.text = mediaItem?.artistName ?? ""
            albumArtworkImageView.image = nil
            
        }
    }
    
    @IBAction func playMediaItem(_ sender: UIButton) {
        if let mediaItem = mediaItem {
            delegate?.searchAppleMusicTableViewCell(self, playMediaItem: mediaItem)
        }
    }
    
    @IBAction func addToPlaylist(_ sender: UIButton) {
        if let mediaItem = mediaItem {
            delegate?.searchAppleMusicTableViewCell(self, addToPlaylist: mediaItem)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

protocol SearchAppleMusicTableViewCellDelegate: class {
    func searchAppleMusicTableViewCell(_ searchAppleMusicTableViewCell: SearchAppleMusicTableViewCell, addToPlaylist mediaItem: MediaItem)
    
    func searchAppleMusicTableViewCell(_ searchAppleMusicTableViewCell: SearchAppleMusicTableViewCell, playMediaItem mediaItem: MediaItem)
}
