import SwiftUI
import AVKit

// MARK: - Models
struct TMDBResponse: Codable {
    let results: [Movie]
}

struct Movie: Identifiable, Codable {
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
    }
    
    var fullPosterURL: String {
        if let path = posterPath {
            return "https://image.tmdb.org/t/p/w500\(path)"
        }
        return ""
    }
}

// MARK: - ViewModel
class MovieFetcher: ObservableObject {
    @Published var movies: [Movie] = []
    private let apiKey = "12bae60f08973cb30c741d0844769d9d"
    
    func fetchMovies() {
        let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)&language=ar-SA"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode(TMDBResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.movies = decoded.results
                }
            }
        }.resume()
    }
}

// MARK: - App Entry Point
@main
struct MovieAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Custom Video Player
struct CustomVideoPlayerView: View {
    let movieTitle: String
    @Environment(\.dismiss) var dismiss
    
    @State private var player: AVPlayer? = nil
    @State private var selectedQuality = "1080p"
    @State private var selectedSubtitle = "العربية"
    
    let qualities = ["Auto", "1080p", "720p", "480p"]
    let subtitles = ["إيقاف", "العربية", "English"]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            } else {
                ProgressView()
                    .tint(.white)
            }
            
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text(movieTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Menu {
                        Menu("دقة الفيديو 📶") {
                            ForEach(qualities, id: \.self) { q in
                                Button(action: { selectedQuality = q }) {
                                    HStack {
                                        Text(q)
                                        if selectedQuality == q { Image(systemName: "checkmark") }
                                    }
                                }
                            }
                        }
                        
                        Menu("الترجمة 💬") {
                            ForEach(subtitles, id: \.self) { sub in
                                Button(action: { selectedSubtitle = sub }) {
                                    HStack {
                                        Text(sub)
                                        if selectedSubtitle == sub { Image(systemName: "checkmark") }
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding()
                .background(LinearGradient(colors: [.black.opacity(0.8), .clear], startPoint: .top, endPoint: .bottom))
                
                Spacer()
                
                HStack {
                    Label(selectedQuality, systemImage: "tv")
                    Spacer()
                    Label("الترجمة: \(selectedSubtitle)", systemImage: "captions.bubble")
                }
                .font(.caption)
                .padding()
                .background(.ultraThinMaterial)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding()
            }
        }
        .onAppear {
            if let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") {
                let p = AVPlayer(url: url)
                self.player = p
                p.play()
            }
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("defaultQuality") private var defaultQuality = "1080p"
    @AppStorage("defaultSubtitle") private var defaultSubtitle = "العربية"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("إعدادات التشغيل")) {
                    Picker("الجودة الافتراضية", selection: $defaultQuality) {
                        Text("1080p").tag("1080p")
                        Text("720p").tag("720p")
                        Text("480p").tag("480p")
                    }
                    
                    Picker("الترجمة الافتراضية", selection: $defaultSubtitle) {
                        Text("العربية").tag("العربية")
                        Text("English").tag("English")
                        Text("إيقاف").tag("إيقاف")
                    }
                }
                
                Section(header: Text("عن التطبيق")) {
                    HStack {
                        Text("الإصدار")
                        Spacer()
                        Text("1.0.0 (2026)")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("الإعدادات")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("تم") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Main ContentView
struct ContentView: View {
    @StateObject var fetcher = MovieFetcher()
    @State private var selectedTab = 0
    @State private var selectedProvider = "Cinejoy"
    @State private var showSettings = false
    @State private var showDownloads = false
    @State private var selectedMovieForPlayer: Movie? = nil
    @State private var searchQuery = ""
    
    let providers = ["Cinejoy", "فيديو فيولا", "Akwam", "Wecima", "Krmzi"]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            
            switch selectedTab {
            case 0:
                HomeSubView(fetcher: fetcher, selectedMovie: $selectedMovieForPlayer)
            case 1:
                GridSubView(title: "جميع الأفلام", fetcher: fetcher, selectedMovie: $selectedMovieForPlayer)
            case 2:
                GridSubView(title: "المسلسلات الحصرية", fetcher: fetcher, selectedMovie: $selectedMovieForPlayer)
            case 3:
                LibrarySubView()
            case 4:
                SearchSubView(fetcher: fetcher, searchQuery: $searchQuery, selectedMovie: $selectedMovieForPlayer)
            default:
                HomeSubView(fetcher: fetcher, selectedMovie: $selectedMovieForPlayer)
            }
            
            VStack {
                TopHeaderBar(
                    selectedProvider: $selectedProvider,
                    providers: providers,
                    showDownloads: $showDownloads,
                    showSettings: $showSettings
                )
                Spacer()
            }
            
            CustomTabBar(selectedTab: $selectedTab)
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showDownloads) {
            NavigationView {
                VStack {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("لا توجد تنزيلات حالياً")
                        .foregroundColor(.gray)
                        .padding()
                }
                .navigationTitle("التنزيلات")
                .toolbar { Button("إغلاق") { showDownloads = false } }
            }
        }
        .fullScreenCover(item: $selectedMovieForPlayer) { movie in
            CustomVideoPlayerView(movieTitle: movie.title)
        }
        .onAppear { fetcher.fetchMovies() }
    }
}

// MARK: - UI Components
struct TopHeaderBar: View {
    @Binding var selectedProvider: String
    let providers: [String]
    @Binding var showDownloads: Bool
    @Binding var showSettings: Bool
    
    var body: some View {
        HStack {
            Menu {
                ForEach(providers, id: \.self) { provider in
                    Button(action: { selectedProvider = provider }) {
                        HStack {
                            Text(provider)
                            if selectedProvider == provider { Image(systemName: "checkmark") }
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "tv.fill")
                    Text(selectedProvider)
                        .font(.subheadline)
                        .bold()
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .foregroundColor(.white)
            }
            
            Spacer()
            
            Menu {
                Button(action: { showDownloads = true }) {
                    Label("التنزيلات", systemImage: "arrow.down.circle")
                }
                Button(action: { showSettings = true }) {
                    Label("الإعدادات", systemImage: "gearshape")
                }
            } label: {
                Image(systemName: "gearshape.fill")
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal)
        .padding(.top, 55)
        .background(LinearGradient(colors: [.black.opacity(0.8), .clear], startPoint: .top, endPoint: .bottom))
    }
}

struct HomeSubView: View {
    @ObservedObject var fetcher: MovieFetcher
    @Binding var selectedMovie: Movie?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let firstMovie = fetcher.movies.first {
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: URL(string: firstMovie.fullPosterURL)) { img in
                            img.resizable().scaledToFill()
                        } placeholder: { Color.gray.opacity(0.3) }
                        .frame(height: 450)
                        .clipped()
                        
                        LinearGradient(colors: [.clear, .black], startPoint: .center, endPoint: .bottom)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text(firstMovie.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 12) {
                                Text("أكشن 🌐")
                                Text("\(firstMovie.releaseDate?.prefix(4) ?? "2026") 📅")
                                Text(String(format: "%.1f ★", firstMovie.voteAverage ?? 8.0))
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
                            
                            HStack(spacing: 15) {
                                Button(action: { selectedMovie = firstMovie }) {
                                    HStack {
                                        Image(systemName: "play.fill")
                                        Text("تشغيل")
                                    }
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(25)
                                }
                            }
                        }
                        .padding()
                        .padding(.bottom, 20)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("الأفلام الشائعة")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(fetcher.movies) { movie in
                                Button(action: { selectedMovie = movie }) {
                                    VStack(alignment: .leading) {
                                        AsyncImage(url: URL(string: movie.fullPosterURL)) { image in
                                            image.resizable().scaledToFill()
                                        } placeholder: { Color.gray.opacity(0.3) }
                                        .frame(width: 130, height: 190)
                                        .cornerRadius(12)
                                        .clipped()
                                        
                                        Text(movie.title)
                                            .font(.caption)
                                            .bold()
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                            .frame(width: 130, alignment: .leading)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.top, 100)
            .padding(.bottom, 110)
        }
    }
}

struct GridSubView: View {
    let title: String
    @ObservedObject var fetcher: MovieFetcher
    @Binding var selectedMovie: Movie?
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top, 110)
                
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(fetcher.movies) { movie in
                        Button(action: { selectedMovie = movie }) {
                            VStack {
                                AsyncImage(url: URL(string: movie.fullPosterURL)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: { Color.gray.opacity(0.3) }
                                .frame(height: 160)
                                .cornerRadius(10)
                                .clipped()
                                
                                Text(movie.title)
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .padding()
            }
            .padding(.bottom, 110)
        }
    }
}

struct LibrarySubView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "bookmark.fill")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("المكتبة فارغة")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 8)
            Spacer()
        }
    }
}

struct SearchSubView: View {
    @ObservedObject var fetcher: MovieFetcher
    @Binding var searchQuery: String
    @Binding var selectedMovie: Movie?
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var filteredMovies: [Movie] {
        if searchQuery.isEmpty { return fetcher.movies }
        return fetcher.movies.filter { $0.title.localizedCaseInsensitiveContains(searchQuery) }
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("ابحث عن فيلم...", text: $searchQuery).foregroundColor(.white)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top, 110)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(filteredMovies) { movie in
                        Button(action: { selectedMovie = movie }) {
                            HStack {
                                AsyncImage(url: URL(string: movie.fullPosterURL)) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: { Color.gray.opacity(0.3) }
                                .frame(width: 60, height: 90)
                                .cornerRadius(8)
                                .clipped()
                                
                                Text(movie.title)
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                Spacer()
                            }
                            .padding(8)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            tabButton(icon: "house.fill", title: "الرئيسية", tag: 0)
            tabButton(icon: "film", title: "أفلام", tag: 1)
            tabButton(icon: "play.tv", title: "مسلسلات", tag: 2)
            tabButton(icon: "bookmark", title: "المكتبة", tag: 3)
            tabButton(icon: "magnifyingglass", title: "بحث", tag: 4)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .cornerRadius(30)
        .padding(.horizontal, 15)
        .padding(.bottom, 25)
    }
    
    private func tabButton(icon: String, title: String, tag: Int) -> View {
        Button(action: { selectedTab = tag }) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 18))
                Text(title).font(.caption2)
            }
            .foregroundColor(selectedTab == tag ? .white : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(selectedTab == tag ? Color.white.opacity(0.2) : Color.clear)
            .cornerRadius(18)
        }
    }
}
