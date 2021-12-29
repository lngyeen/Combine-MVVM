//
//  API.Music.swift
//  Combine-MVVM
//
//  Created by Nguyen Truong Luu on 12/28/21.
//

import Combine
import Foundation

extension API.Music {
    // MARK: - Endpoint

    enum EndPoint {
        // case
        case newMusisc(limit: Int)
    
        var url: URL? {
            switch self {
            case .newMusisc(let limit):
                let urlString = API.Config.baseURL + "/api/v2/us/music/most-played/\(limit)/albums.json"
                return URL(string: urlString)
            }
        }
    }
  
    struct MusicResponse: Decodable {
        var feed: MusicResults
    
        struct MusicResults: Decodable {
            var results: [Music]
            var updated: String
        }
    }
  
    // MARK: - Domains

    static func getNewMusic(limit: Int = 10) -> AnyPublisher<MusicResponse, API.APIError> {
        guard let url = EndPoint.newMusisc(limit: limit).url else {
            return Fail(error: API.APIError.errorURL).eraseToAnyPublisher()
        }
    
        return API.request(url: url)
            .decode(type: MusicResponse.self, decoder: JSONDecoder())
            .mapError { error -> API.APIError in
                switch error {
                case is URLError:
                    return .errorURL
                case is DecodingError:
                    return .errorParsing
                default:
                    return error as? API.APIError ?? .unknown
                }
            }
            .eraseToAnyPublisher()
    }
    
    static func likeMusic(music: Music) -> AnyPublisher<Music, API.APIError> {
        let newMusic = music
        newMusic.isLiked.toggle()
        let subject = CurrentValueSubject<Music, API.APIError>(newMusic)
        return subject
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
