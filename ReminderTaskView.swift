import SwiftUI

struct ReminderTaskView: View {
    @Binding var tasks: [Task]
    @State private var showingCompletionAlert = false
    @State private var selectedTask: Task?
    
    var body: some View {
        List {
            ForEach(tasks.filter { $0.taskType == .reminder }) { task in
                HStack {
                    Button(action: {
                        if task.isCompleted {
                            toggleCompletion(task)
                        } else {
                            selectedTask = task
                            showingCompletionAlert = true
                        }
                    }) {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.isCompleted ? .green : .gray)
                    }
                    
                    Text(task.title)
                        .font(.title3)
                        .foregroundColor(task.isCompleted ? .gray : .primary)
                        .onTapGesture {
                            // タスク編集画面を開く
                        }
                    Spacer()
                    if let dueDate = task.dueDate {
                        Text(formatDate(dueDate))
                            .foregroundColor(.gray)
                    }
                }
            }
            .onDelete { indexSet in
                tasks.remove(atOffsets: indexSet)
                saveTasks()
            }
            .swipeActions {
                Button("編集") {
                    // 編集画面を開く
                }
                .tint(.blue)
                
                Button("削除", role: .destructive) {
                    // 削除処理
                }
            }
        }
        .alert("完了にしますか？", isPresented: $showingCompletionAlert) {
            Button("はい") {
                if let task = selectedTask {
                    toggleCompletion(task)
                }
            }
            Button("いいえ", role: .cancel) {}
        }
    }
    
    private func toggleCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
    
    private func saveTasks() {
        UserDefaults.standard.set(try? JSONEncoder().encode(tasks), forKey: "tasks")
    }
}
