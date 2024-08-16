//
//  ContentView.swift
//  Song
//
//  Created by Mohammad Tofik Sheikh on 14/08/24.
//

import SwiftUI

struct ContentView: View {
    @State private var songs: [Song] = []
    @State private var isLoading: Bool = true
    @State private var isRefreshing: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading...")
                        .scaleEffect(1.5, anchor: .center)  // Scales the loading indicator
                } else {
                    List(songs) { song in
                        NavigationLink(destination: SongDetailView(song: song)) {
                            SongRow(song: song)
                        }
                    }
                    .refreshable {
                        await refreshData()
                    }
                }
            }
            .onAppear {
                Task {
                    await fetchData()
                }
            }
            .navigationTitle("Songs")
        }
    }
    
    // NOTE: - Fetch data from API
    private func fetchData() async {
        let urlString = "https://itunes.apple.com/search?term=Justin+beiber"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(SearchResult.self, from: data)
            DispatchQueue.main.async {
                self.songs = result.results
                self.isLoading = false
            }
        } catch {
            print("Failed to fetch data: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    private func refreshData() async {
        isRefreshing = true
        await fetchData()
        DispatchQueue.main.async {
            self.isRefreshing = false
        }
    }
}

// NOTE: - SongRow View
// Encapsulating the row content for better readability and reusability
struct SongRow: View {
    let song: Song

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: song.artworkUrl100)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            } placeholder: {
                ProgressView()
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(song.collectionName ?? "Unknown Artist")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                HStack {
                    Text(song.trackName)
                        .font(.headline)
                    Spacer()
                    Text(song.trackTimeMillis.formattedDuration())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 5)
    }
}

// NOTE: - Song Detail View
// Displays detailed information about the selected song
struct SongDetailView: View {
    let song: Song
    
    var body: some View {
        VStack {
            Spacer()
            
            // Album Cover
            AsyncImage(url: URL(string: song.artworkUrl100)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                    .cornerRadius(20)
                    .shadow(radius: 10)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 300, height: 300)
                    .cornerRadius(20)
                    .shadow(radius: 10)
            }
            
            Spacer().frame(height: 40)
            
            // NOTE Song Information
            VStack(alignment: .center, spacing: 8) {
                Text(song.trackName)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text(song.collectionName ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Duration: \(song.trackTimeMillis.formattedDuration())")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            Spacer().frame(height: 40)
            
            // Player Slider
            VStack {
                Slider(value: .constant(0.5))
                    .accentColor(.blue)
                HStack {
                    Text("1:30")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("3:45")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer().frame(height: 20)
            
            // Player Controls
            HStack(spacing: 60) {
                Button(action: {
                    
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                }
                
                Button(action: {
                    
                }) {
                    Image(systemName: "playpause.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                }
                
                Button(action: {

                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                }
            }
            
            Spacer().frame(height: 50)
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
        )
        .cornerRadius(20)
        .shadow(radius: 10)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// NOTE: - Models

struct SearchResult: Decodable {
    let results: [Song]
}

struct Song: Decodable, Identifiable {
    let id = UUID()
    let trackName: String
    let artworkUrl100: String
    let trackTimeMillis: Int
    let collectionName: String?
}

// NOTE: - Extensions
// Utility extension to format track duration
extension Int {
    func formattedDuration() -> String {
        let seconds = self / 1000
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

// NOTE: - Preview
// Preview provider for SwiftUI preview
#Preview {
    ContentView()
}
