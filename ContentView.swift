import SwiftUI
import GoogleMobileAds

class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    MobileAds.shared.start(completionHandler: nil)

    return true
  }
}

class TaskManager: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var selectedTaskIndex: Int = 0
}

struct ContentView: View {
    //@State private var tasks: [Task] = []
    @State private var showingAddTaskView = false
    @State private var selectedTab = 1 // ✅ 初期タブを「カレンダー」に設定
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    //@State private var selectedTaskIndex = 0
    @StateObject private var taskManager = TaskManager()
    let adUnitID = "ca-app-pub-3940256099942544/2435281174"

    init() {
        UITabBar.appearance().backgroundColor = UIColor.systemGray2
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // バナー広告
                HStack {
                    BannerAdView(adUnitID: adUnitID)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                }
                
                // ヘッダー（メニューボタン & プラスボタン）
                HStack {
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Button(action: { showingAddTaskView = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .imageScale(.large)
                            .foregroundColor(.blue)
                            .padding(.trailing)
                    }
                }
                .frame(height: 50)

                // ✅ 初期表示がカレンダーになる
                TabView(selection: $selectedTab) {
                    HabitTaskView(tasks: $taskManager.tasks, selectedTaskIndex: $taskManager.selectedTaskIndex)
                        .tabItem {
                            Image(systemName: "repeat")
                            Text("習慣タスク")
                        }
                        .tag(0)

                    CalendarView() // ✅ 初期表示されるビュー
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("カレンダー")
                        }
                        .tag(1)

                    ReminderTaskView(tasks: $taskManager.tasks, selectedTaskIndex: $taskManager.selectedTaskIndex)
                        .tabItem {
                            Image(systemName: "bell.fill")
                            Text("リマインダー")
                        }
                        .tag(2)
                }
                .accentColor(selectedTab == 1 ? .red : .blue) // カレンダーに合わせた色変更
            }
            .sheet(isPresented: $showingAddTaskView) {
                AddTaskView(tasks: $taskManager.tasks)
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
            taskManager.tasks = decodedTasks
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
