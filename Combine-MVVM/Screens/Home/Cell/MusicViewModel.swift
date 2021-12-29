//
//  MusicViewModel.swift
//  Combine-MVVM
//
//  Created by Nguyen Truong Luu on 12/29/21.
//

import Combine
import Foundation

protocol MusicViewModelInputs {
    var likeButtonTrigger: PassthroughSubject<Bool, Never> { get }
}

protocol MusicViewModelOutputs {
    var likeTrigger: AnyPublisher<Bool, Never> { get }
    var musicUpdatedTrigger: AnyPublisher<MusicViewModel, Never> { get }
}

class MusicViewModel: MusicViewModelInputs, MusicViewModelOutputs {
    var inputs: MusicViewModelInputs { return self }
    var outputs: MusicViewModelOutputs { return self }
    
    // MARK: - Inputs
    
    let likeButtonTrigger = PassthroughSubject<Bool, Never>()
    
    // MARK: - Outputs
    
    var likeTrigger: AnyPublisher<Bool, Never> { return likePublishSubject.eraseToAnyPublisher() }
    var musicUpdatedTrigger: AnyPublisher<MusicViewModel, Never> { return musicUpdatedPublishSubject.eraseToAnyPublisher() }
    
    // MARK: - Properties
    
    var subscriptions = Set<AnyCancellable>()
    
    var lastLikeStatus: Bool = false
    var id: String { music.id }
    var name: String { music.name }
    var artworkUrl100: String { music.artworkUrl100 }
    var artistName: String { music.artistName }
    var isLiked: Bool { music.isLiked }
    
    // MARK: - Private properties
    
    private(set) var music: Music
    private let musicUpdatedPublishSubject = PassthroughSubject<MusicViewModel, Never>()
    private let likePublishSubject = PassthroughSubject<Bool, Never>()
    
    init(music: Music) {
        self.music = music
        lastLikeStatus = music.isLiked
        likeButtonTrigger
            .handleEvents(receiveOutput: { [weak self] isLiked in
                self?.lastLikeStatus = isLiked
            })
            .debounce(for: 0.4, scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] isLiked in
                self?.likePublishSubject.send(isLiked)
            }).store(in: &subscriptions)
    }
    
    func updateMusic(_ music: Music) {
        self.music = music
        lastLikeStatus = music.isLiked
        musicUpdatedPublishSubject.send(self)
    }
}
