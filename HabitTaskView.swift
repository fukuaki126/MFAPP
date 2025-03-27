import SwiftUI

struct HabitTaskView: View {
    @Binding var tasks: [Task]

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    if tasks.filter({ $0.taskType == .habit }).isEmpty {
                        Text("習慣タスクがありません")
                            .font(.title3)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List {
                            ForEach(tasks.filter { $0.taskType == .habit }) { task in
                                HStack {
                                    // ✅ チェックマークボタン（完了フラグを切り替え）
                                    Button(action: {
                                        toggleCompletion(for: task)
                                    }) {
                                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(task.isCompleted ? .green : .gray)
                                            .font(.system(size: 30))
                                    }
                                    .buttonStyle(PlainButtonStyle()) // デフォルトのボタンスタイルを解除

                                    // ✅ タイトルや経過日数をタップで編集画面に遷移
                                    NavigationLink(destination: EditHabitTaskView(tasks: $tasks, taskToEdit: task)) {
                                        VStack(alignment: .leading) {
                                            Text(task.title)
                                                .font(.title3)
                                            Text("経過: \(daysSinceLastCompleted(task))日")
                                                .foregroundColor(isAlert(task) ? .red : .gray)
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                                .onAppear {
                                    _ = daysSinceLastCompleted(task)
                                    NotificationManager.shared.scheduleHabitTaskNotification(task: task)
                                }
                            }
                            .onDelete { indexSet in
                                tasks.remove(atOffsets: indexSet)
                                saveTasks()
                            }
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.clear)
                    }
                }
            }
        }
    }

    private func toggleCompletion(for task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            if tasks[index].isCompleted {
                tasks[index].lastCompletedDate = Date()
                NotificationManager.shared.cancelNotification(task: tasks[index])
            } else {
                tasks[index].lastCompletedDate = nil
                NotificationManager.shared.scheduleHabitTaskNotification(task: tasks[index])
            }
            saveTasks()
        }
    }

    private func daysSinceLastCompleted(_ task: Task) -> Int {
        guard let lastDate = task.lastCompletedDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
    }

    func isAlert(_ task: Task) -> Bool {
        guard let lastCompletedDate = task.lastCompletedDate,
              let alertDays = task.alertDays else {
            return false
        }
        let daysSinceLastCompletion = Calendar.current.dateComponents([.day], from: lastCompletedDate, to: Date()).day ?? 0
        return daysSinceLastCompletion >= alertDays
    }

    private func saveTasks() {
        UserDefaults.standard.set(try? JSONEncoder().encode(tasks), forKey: "tasks")
    }
}
