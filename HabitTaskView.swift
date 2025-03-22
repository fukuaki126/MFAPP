import SwiftUI

struct HabitTaskView: View {
    @Binding var tasks: [Task]
    
    var body: some View {
        List {
            ForEach(tasks.filter { $0.taskType == .habit }) { task in
                HStack {
                    Text(task.title)
                        .font(.title3)
                    Spacer()
                    Text("経過: \(daysSinceLastCompleted(task))日")
                        .foregroundColor(.gray)
                }
                .onTapGesture {
                    // タスク編集画面を開く
                }
            }
            .onDelete { indexSet in
                tasks.remove(atOffsets: indexSet)
                saveTasks()
                    
            }
        }
    }

    private func daysSinceLastCompleted(_ task: Task) -> Int {
        guard let lastDate = task.lastCompletedDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
    }
    
    private func saveTasks() {
        UserDefaults.standard.set(try? JSONEncoder().encode(tasks), forKey: "tasks")
    }
}
