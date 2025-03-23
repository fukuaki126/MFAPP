import SwiftUI

struct HabitTaskView: View {
    @Binding var tasks: [Task]
    @State private var showingCompletionAlert = false
    @State private var selectedTask: Task?

    var body: some View {
        List {
            ForEach(tasks.filter { $0.taskType == .habit }) { task in
                HStack {
                    Text(task.title)
                        .font(.title3)
                    Spacer()
                    
                    Text("経過: \(daysSinceLastCompleted(task))日")
                        .foregroundColor(isAlert(task) ? .red : .gray)
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle()) // HStack全体をタップ可能に
                .onTapGesture {
                    selectedTask = task
                    showingCompletionAlert = true
                }
                .onAppear {
                    // ここで経過日数のチェックを毎回行う
                    _ = daysSinceLastCompleted(task)
                }
            }
            .onDelete { indexSet in
                tasks.remove(atOffsets: indexSet)
                saveTasks()
            }
        }
        .alert("タスクを実行しましたか？", isPresented: $showingCompletionAlert) {
            Button("はい") {
                if let task = selectedTask {
                    completeTask(task)
                }
            }
            Button("いいえ", role: .cancel) {}
        }
    }

    private func completeTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].lastCompletedDate = Date()
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
        
        let currentDate = Date()
        let daysSinceLastCompletion = Calendar.current.dateComponents([.day], from: lastCompletedDate, to: currentDate).day ?? 0

        return daysSinceLastCompletion >= alertDays
    }

    private func saveTasks() {
        UserDefaults.standard.set(try? JSONEncoder().encode(tasks), forKey: "tasks")
    }
}
