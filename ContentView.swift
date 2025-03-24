import SwiftUI

struct ContentView: View {
    @State private var tasks: [Task] = []
    @State private var showingAddTaskView = false
    @State private var selectedTab = 0 // 選択されたタブを管理

    init() {
        // タブバーのデフォルトの背景色を設定
        UITabBar.appearance().backgroundColor = UIColor.systemGray6
    }

    var body: some View {
        NavigationView {
            VStack {
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
            .background(Color(selectedTab == 0 ? UIColor.systemRed.withAlphaComponent(0.2) : UIColor.systemBlue.withAlphaComponent(0.2)))
            //.navigationTitle("タスク管理")
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
