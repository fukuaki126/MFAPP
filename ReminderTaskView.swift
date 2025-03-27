import SwiftUI

struct ReminderTaskView: View {
    @Binding var tasks: [Task]

    var body: some View {
        ZStack {
            // 背景色を統一（リストが空でも適用）
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)

            VStack {
                if tasks.filter({ $0.taskType == .reminder }).isEmpty {
                    Text("リマインダーがありません")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(tasks.indices, id: \.self) { index in
                            if tasks[index].taskType == .reminder {
                                HStack {
                                    // ✅ チェックマークボタン（タップしても遷移しない）
                                    Button(action: {
                                        tasks[index].isCompleted.toggle()
                                    }) {
                                        Image(systemName: tasks[index].isCompleted ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(tasks[index].isCompleted ? .green : .gray)
                                            .font(.system(size: 30))
                                    }
                                    .buttonStyle(PlainButtonStyle()) // ✅ タップ時の遷移を防ぐ

                                    // ✅ NavigationLink（タイトルや日付をタップで編集画面へ）
                                    NavigationLink(destination: EditTaskView(task: $tasks[index])) {
                                        VStack(alignment: .leading) {
                                            Text(tasks[index].title)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            if let dueDate = tasks[index].dueDate {
                                                Text(formatDate(dueDate))
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .onDelete { indexSet in
                            tasks.remove(atOffsets: indexSet)
                            saveTasks()
                        }
                    }
                    .listStyle(PlainListStyle()) // ✅ List の背景を透明化
                    .background(Color.clear)
                }
            }
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
