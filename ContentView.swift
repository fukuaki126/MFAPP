import SwiftUI
import GoogleMobileAds

struct ContentView: View {
    @State private var tasks: [Task] = []
    @State private var showingAddTaskView = false
    @State private var selectedTab = 0 // 選択されたタブを管理
    
    // 広告ユニットID
    let adUnitID = "your-admob-ad-unit-id" // ここに実際のAdMobの広告ユニットIDを入れてください

    init() {
        UITabBar.appearance().backgroundColor = UIColor.systemGray2
    }

    var body: some View {
        NavigationView {
            VStack {
                // バナー広告を追加
                BannerAdView(adUnitID: adUnitID)
                    .frame(height: 50) // バナー広告の高さ

                TabView(selection: $selectedTab) { // タブの選択状態を監視
                    HabitTaskView(tasks: $tasks)
                        .tabItem {
                            Image(systemName: "repeat")
                            Text("習慣タスク")
                        }
                        .tag(0)

                    ReminderTaskView(tasks: $tasks)
                        .tabItem {
                            Image(systemName: "bell.fill")
                            Text("リマインダー")
                        }
                        .tag(1)
                }
                .accentColor(selectedTab == 0 ? .red : .blue) // タブの選択状態に応じて色変更
            }
            .navigationBarItems(trailing: Button(action: {
                showingAddTaskView = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
            })
            .sheet(isPresented: $showingAddTaskView) {
                AddTaskView(tasks: $tasks)
            }
            .onAppear {
                NotificationManager.shared.requestAuthorization()
                loadTasks()
            }
        }
    }

    private func loadTasks() {
        if let savedData = UserDefaults.standard.data(forKey: "tasks"),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: savedData) {
            tasks = decodedTasks
        }
    }
}

struct BannerAdView: View {
    var adUnitID: String
    
    var body: some View {
        BannerAdController(adUnitID: adUnitID)
            .frame(width: UIScreen.main.bounds.width, height: 50) // バナーのサイズを調整
    }
}

struct BannerAdController: UIViewControllerRepresentable {
    var adUnitID: String
    
    func makeUIViewController(context: Context) -> GADBannerViewController {
        return GADBannerViewController(adUnitID: adUnitID)
    }
    
    func updateUIViewController(_ uiViewController: GADBannerViewController, context: Context) {}
}

class GADBannerViewController: UIViewController {
    var adUnitID: String
    var bannerView: BannerView! // GADBannerViewがBannerViewに変更されました
    
    init(adUnitID: String) {
        self.adUnitID = adUnitID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = self
        view.addSubview(bannerView)
        
        let request = Request() // GADRequest -> Request
        bannerView.load(request)
    }
}
