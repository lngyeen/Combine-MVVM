//
//  MusicCell.swift
//  Combine-MVVM
//
//  Created by Nguyen Truong Luu on 12/28/21.
//

import Combine
import Kingfisher
import Reusable
import UIKit

class MusicCell: UITableViewCell, NibLoadable, Reusable {
    // MARK: - Properties

    // Outlets
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    var subscriptions = [AnyCancellable]()
    // ViewModel
    var musicViewModel: MusicViewModel? {
        didSet {
            bindingToView()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions.removeAll()
    }
    
    // MARK: - Lifecycle

    private func bindingToView(setupSubscribers: Bool = true) {
        guard let musicViewModel = musicViewModel else { return }
        
        isLiked = musicViewModel.isLiked
        nameLabel.text = musicViewModel.name
        artistNameLabel.text = musicViewModel.artistName
        thumbnailImageView.kf.setImage(with: URL(string: musicViewModel.artworkUrl100)!)
        isLiked = musicViewModel.lastLikeStatus
        
        if setupSubscribers {
            // musicUpdatedTrigger
            musicViewModel
                .outputs
                .musicUpdatedTrigger
                .sink(receiveValue: { [weak self] newViewModel in
                    self?.bindingToView(setupSubscribers: false)
                }).store(in: &subscriptions)
        }
    }
    
    @IBAction func likeButtonTap(_ sender: Any) {
        toggleLikeButton()
        musicViewModel?.inputs.likeButtonTrigger.send(isLiked)
    }
    
    private var isLiked = false {
        didSet {
            updateLikeButton()
        }
    }
    
    private func updateLikeButton() {
        likeButton.setTitle(isLiked ? "Liked" : "Like", for: .normal)
        likeButton.setTitleColor(isLiked ? .red : .blue, for: .normal)
    }
    
    private func toggleLikeButton() {
        isLiked.toggle()
    }
}
