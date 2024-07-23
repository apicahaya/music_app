//
//  SongsViewModel.swift
//  music_app
//
//  Created by Agni Muhammad on 22/07/24.
//

import Combine
import Foundation
import AVFoundation

class SongsViewModel: ObservableObject {
    @Published var songs: [Song] = []
    @Published var searchText: String = "Justin Bieber"
    @Published var isPlaying: Bool = false
    @Published var currentSong: Song?
    
    private var cancellable = Set<AnyCancellable>()
    private let searchBaseUrl = "https://itunes.apple.com/search?term="
    private let lookupBaseUrl = "https://itunes.apple.com/lookup?id="
    private var player: AVPlayer?
    
    init() {
        fetchSongs()
    }
    
    func fetchSongs() {
        guard let url = URL(string: searchBaseUrl + searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: SongResponse.self, decoder: JSONDecoder())
            .replaceError(with: SongResponse(results: []))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                            self?.songs = response.results
                        }
            .store(in: &cancellable)
    }
    
    func lookupSong(by id: Int) {
        guard let url = URL(string: lookupBaseUrl + "\(id)") else {return}
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map {$0.data}
            .decode(type: SongResponse.self
                    , decoder: JSONDecoder())
            .replaceError(with: SongResponse(results: []))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                self?.songs = response.results
            }
            .store(in: &cancellable)
    }
    
    func playSong(_ song: Song) {
        if let url = URL(string: song.previewUrl ?? "") {
            player = AVPlayer(url: url)
            player?.play()
            currentSong = song
            isPlaying = true
        }
    }

    func pauseSong() {
        player?.pause()
        isPlaying = false
    }
}

struct SongResponse: Decodable {
    let results: [Song]
}

