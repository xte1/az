import SwiftUI

struct Movie: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
}

struct ContentView: View {
    @State private var selectedProvider = "Cinejoy"
    
    let providers = ["Cinejoy", "فيديو فيولا", "Akwam", "Wecima", "Krmzi"]
    
    var body: some View {
        ZStack {
            // خلفية سوداء متدرجة
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // HERO BANNER
                    ZStack(alignment: .bottomLeading) {
                        Image("hero_banner") // استبدلها بصورتك
                            .resizable()
                            .scaledToFill()
                            .frame(height: 450)
                            .clipped()
                        
                        LinearGradient(colors: [.clear, .black], startPoint: .center, endPoint: .bottom)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("THE ODYSSEY")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 12) {
                                Text("Adventure 🌐")
                                Text("2026 📅")
                                Text("8.0/10 ★")
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
                            
                            HStack(spacing: 15) {
                                Button(action: {}) {
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
                                
                                Button(action: {}) {
                                    Image(systemName: "plus")
                                        .padding(12)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // قائمة الأفلام الأكثر تداولاً
                    VStack(alignment: .leading) {
                        Text("Trending Movies")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(0..<5) { index in
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 130, height: 190)
                                        .overlay(
                                            Text("Movie \(index + 1)")
                                                .foregroundColor(.white)
                                        )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 100)
            }
            
            // الشريط العلوي مع القوائم المنسدلة (Liquid Glass)
            VStack {
                HStack {
                    // قائمة مزودي الخدمة (الجهة اليسرى/اليمنى)
                    Menu {
                        ForEach(providers, id: \.self) { provider in
                            Button(action: { selectedProvider = provider }) {
                                HStack {
                                    Text(provider)
                                    if selectedProvider == provider {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "tv.fill")
                            Text(selectedProvider)
                                .font(.subheadline)
                                .bold()
                        }
                        .padding(10)
                        .background(.ultraThinMaterial) // Liquid Glass Effect
                        .cornerRadius(20)
                        .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // قائمة الإعدادات والتنزيلات
                    Menu {
                        Button(action: {}) {
                            Label("التنزيلات", systemImage: "arrow.down.circle")
                        }
                        Button(action: {}) {
                            Label("الإعدادات", systemImage: "gearshape")
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .padding(10)
                            .background(.ultraThinMaterial) // Liquid Glass Effect
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 50)
                
                Spacer()
                
                // شريط التنقل السفلي العائم (Floating Liquid Glass Tab Bar)
                HStack(spacing: 25) {
                    TabBarIcon(icon: "house.fill", title: "الرئيسية", isSelected: true)
                    TabBarIcon(icon: "film", title: "أفلام", isSelected: false)
                    TabBarIcon(icon: "play.tv", title: "مسلسلات", isSelected: false)
                    TabBarIcon(icon: "bookmark", title: "المكتبة", isSelected: false)
                    TabBarIcon(icon: "magnifyingglass", title: "", isSelected: false)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial) // Liquid Glass Effect
                .cornerRadius(30)
                .padding(.bottom, 20)
            }
        }
        .ignoresSafeArea()
    }
}

struct TabBarIcon: View {
    let icon: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
            if !title.isEmpty {
                Text(title)
                    .font(.caption2)
            }
        }
        .foregroundColor(isSelected ? .white : .gray)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isSelected ? Color.white.opacity(0.2) : Color.clear)
        .cornerRadius(15)
    }
}
