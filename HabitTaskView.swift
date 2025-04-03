import SwiftUI

struct HabitTaskView: View {
    @Binding var tasks: [Task]
    @Binding var selectedTaskIndex: Int
    @State private var isEditPresented = false

    var body: some View {
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
                        ForEach(tasks.indices, id: \.self) { index in
                            if tasks[index].taskType == .habit {
                                HStack {
                                    // ✅ チェックマークボタン（完了フラグを切り替え）
                                    Button(action: {
                                        toggleCompletion(for: index)
                                    }) {
                                        Image(systemName: tasks[index].isCompleted ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(tasks[index].isCompleted ? .green : .gray)
                                            .font(.system(size: 30))
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    // ✅ タスク全体をタップで編集画面に遷移
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(tasks[index].title)
                                                .font(.title3)
                                            Text("経過: \(daysSinceLastCompleted(tasks[index]))日")
                                                .foregroundColor(isAlert(tasks[index]) ? .red : .gray)
                                        }
                                        Spacer()
                                    }
                                    .contentShape(Rectangle()) // ✅ HStack全体をタップ可能にする
                                    .onTapGesture {
                                        selectedTaskIndex = index
                                        isEditPresented = true
                                    }
                                }
                                .padding(.vertical, 8)
                                .onAppear {
                                    NotificationManager.shared.scheduleHabitTaskNotification(task: tasks[index])
                                }
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
        .fullScreenCover(isPresented: $isEditPresented) {
            EditHabitTaskView(task: $tasks[selectedTaskIndex])
        }
    }

    private func toggleCompletion(for index: Int) {
        tasks[index].isCompleted.toggle()
        tasks[index].lastCompletedDate = tasks[index].isCompleted ? Date() : nil
        
        if tasks[index].isCompleted {
            NotificationManager.shared.cancelNotification(task: tasks[index])
        } else {
            NotificationManager.shared.scheduleHabitTaskNotification(task: tasks[index])
        }
        
        saveTasks()
    }

    private func daysSinceLastCompleted(_ task: Task) -> Int {
        guard let lastDate = task.lastCompletedDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
    }

    private func isAlert(_ task: Task) -> Bool {
        guard let lastCompletedDate = task.lastCompletedDate,
              let alertDays = task.alertDays else { return false }
        let daysSinceLastCompletion = daysSinceLastCompleted(task)
        return daysSinceLastCompletion >= alertDays
    }

    private func saveTasks() {
        UserDefaults.standard.set(try? JSONEncoder().encode(tasks), forKey: "tasks")
    }
}
