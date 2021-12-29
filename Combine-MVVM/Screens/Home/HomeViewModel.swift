//
//  HomeViewModel.swift
//  Combine-MVVM
//
//  Created by Nguyen Truong Luu on 12/28/21.
//

import Combine
import Foundation

protocol HomeViewModelOutputs {
    var musics: [MusicViewModel] { get }
    var musicsPublisher: Published<[MusicViewModel]>.Publisher { get }
    
    var isLoading: Bool { get }
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    
    var error: PassthroughSubject<String, Never> { get }
    var reloadCell: PassthroughSubject<IndexPath, Never> { get }
}

protocol HomeViewModelInputs {
    var fetchData: PassthroughSubject<Void, Never> { get }
    var reset: PassthroughSubject<Void, Never> { get }
}

protocol HomeViewModelProtocol: HomeViewModelOutputs, HomeViewModelInputs {
    var inputs: HomeViewModelInputs { get }
    var outputs: HomeViewModelOutputs { get }
    
    func numberOfRows(in section: Int) -> Int
    func music(at indexPath: IndexPath) -> MusicViewModel
}

final class HomeViewModel: HomeViewModelProtocol {
    var inputs: HomeViewModelInputs { self }
    var outputs: HomeViewModelOutputs { self }
    
    // MARK: - Outputs

    @Published var musics: [MusicViewModel] = []
    var musicsPublisher: Published<[MusicViewModel]>.Publisher { $musics }
    
    @Published var isLoading: Bool = false
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    
    var error = PassthroughSubject<String, Never>()
    var reloadCell = PassthroughSubject<IndexPath, Never>()
    
    // MARK: - Inputs

    var fetchData = PassthroughSubject<Void, Never>()
    var reset = PassthroughSubject<Void, Never>()
    var likeMusic = PassthroughSubject<IndexPath, Never>()
    
    // MARK: - Properties

    var subscriptions = [AnyCancellable]()
    var musicsCancellable = [AnyCancellable]()
  
    // MARK: - Init

    init() {
        bindingInputs()
    }
  
    // MARK: - Private functions
    
    private func bindingInputs() {
        // fetchData
        inputs.fetchData
            .sink { [weak self] _ in
                self?.fetchMusics()
            }.store(in: &subscriptions)
        
        // reset
        inputs.reset
            .sink { [weak self] _ in
                self?.musics = []
                self?.fetchMusics()
            }.store(in: &subscriptions)
    }

    private func fetchMusics() {
        musicsCancellable = []
    
        API.Music.getNewMusic(limit: 100)
            .handleEvents(
                receiveSubscription: { _ in
                    self.isLoading = true
                },
                receiveCompletion: { _ in
                    self.isLoading = false
                })
            .map(\.feed.results)
            .replaceError(with: [])
            .map { musics in
                musics.map { MusicViewModel(music: $0) }
            }
            .sink(receiveValue: { viewModels in
                self.setupLikeTriggers(viewModels)
                self.musics = viewModels
            })
            .store(in: &musicsCancellable)
    }
    
    private func setupLikeTriggers(_ newViewModels: [MusicViewModel]) {
        // like trigger
        for musicViewModel in newViewModels {
            let music = musicViewModel.music
            musicViewModel
                .outputs
                .likeTrigger
                .filter { isLiked in isLiked != music.isLiked }
                .map { _ in API.Music.likeMusic(music: music) }
                .switchToLatest()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("Error \(error)")
                    default: break
                    }
                }, receiveValue: { [weak musicViewModel] newMusic in
                    if music.isLiked != newMusic.isLiked {
                        musicViewModel?.updateMusic(newMusic)
                    }
                }).store(in: &musicViewModel.subscriptions)
        }
    }
}

// MARK: - TableView

extension HomeViewModel {
    func numberOfRows(in section: Int) -> Int {
        musics.count
    }
  
    func music(at indexPath: IndexPath) -> MusicViewModel {
        musics[indexPath.row]
    }
}
