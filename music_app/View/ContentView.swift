import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SongsViewModel()
    @State private var lookupId: String = ""

    var body: some View {
        VStack {
            VStack {
                // Search bar
                ClearableTextField(
                    text: $viewModel.searchText,
                    placeholder: "Search artist",
                    onCommit: {
                        viewModel.fetchSongs()
                    }
                )

                // Lookup bar
                HStack {
                    TextField("Lookup by iTunes ID", text: $lookupId)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Lookup") {
                        if let id = Int(lookupId) {
                            viewModel.lookupSong(by: id)
                        }
                    }
                    .padding(.leading, 5)
                }
                .padding(.horizontal)
            }
            .padding(.top)

            Spacer()

            // Conditional view rendering
            if viewModel.songs.isEmpty {
                VStack {
                    Spacer()
                    Text("No songs found. Please try a different search.")
                        .padding()
                    Spacer()
                }
            } else {
                List(viewModel.songs) { song in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(song.trackName)
                            Text(song.artistName)
                            if let collectionName = song.collectionName {
                                Text(collectionName)
                            }
                        }
                        Spacer()
                        if viewModel.currentSong?.id == song.id && viewModel.isPlaying {
                            Image(systemName: "waveform.path.ecg")
                        }
                    }
                    .onTapGesture {
                        viewModel.playSong(song)
                    }
                }
            }

            // Music controls
            if let currentSong = viewModel.currentSong {
                HStack {
                    Button(action: {
                        // Previous button action
                    }) {
                        Image(systemName: "backward.fill")
                    }
                    Button(action: {
                        viewModel.isPlaying ? viewModel.pauseSong() : viewModel.playSong(currentSong)
                    }) {
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                    }
                    Button(action: {
                        // Next button action
                    }) {
                        Image(systemName: "forward.fill")
                    }
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.fetchSongs() // Fetch songs on appear
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
